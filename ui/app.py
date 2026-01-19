import os
import queue
import subprocess
import threading
import time
import uuid
from pathlib import Path

from flask import Flask, Response, jsonify, redirect, render_template, request, url_for


PROJECT_ROOT = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = PROJECT_ROOT / "scripts"

ALLOWED_ACTIONS = {"deploy", "audit", "consolidate", "cleanup", "all"}

app = Flask(__name__)

# job_id -> {"action": str, "created": float, "status": str}
JOBS: dict[str, dict] = {}
# job_id -> Queue[str]
LOG_QUEUES: dict[str, "queue.Queue[str]"] = {}


def _powershell_exe() -> str:
    # Prefer pwsh if available, else Windows PowerShell
    return os.environ.get("POWERSHELL_EXE", "powershell")


def _run_job(job_id: str, action: str) -> None:
    q = LOG_QUEUES[job_id]
    JOBS[job_id]["status"] = "running"

    ps1 = SCRIPTS_DIR / "run_audit.ps1"
    cmd = [_powershell_exe(), "-ExecutionPolicy", "Bypass", "-File", str(ps1), action]

    q.put(f"[ui] Starting job {job_id} action={action}\n")
    q.put(f"[ui] Command: {' '.join(cmd)}\n\n")

    try:
        proc = subprocess.Popen(
            cmd,
            cwd=str(PROJECT_ROOT),
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            bufsize=1,
        )
        assert proc.stdout is not None
        for line in proc.stdout:
            q.put(line)
        rc = proc.wait()
        if rc == 0:
            JOBS[job_id]["status"] = "success"
            q.put(f"\n[ui] ✅ Job finished successfully (exit={rc})\n")
        else:
            JOBS[job_id]["status"] = "failed"
            q.put(f"\n[ui] ❌ Job failed (exit={rc})\n")
    except Exception as e:
        JOBS[job_id]["status"] = "failed"
        q.put(f"\n[ui] ❌ Exception: {e}\n")
    finally:
        # marker for SSE loop
        q.put(None)  # type: ignore[arg-type]


@app.get("/")
def index():
    return render_template("index.html")


@app.post("/run/<action>")
def run_action(action: str):
    if action not in ALLOWED_ACTIONS:
        return jsonify({"error": "invalid_action", "allowed": sorted(ALLOWED_ACTIONS)}), 400

    job_id = uuid.uuid4().hex
    JOBS[job_id] = {"action": action, "created": time.time(), "status": "queued"}
    LOG_QUEUES[job_id] = queue.Queue()

    t = threading.Thread(target=_run_job, args=(job_id, action), daemon=True)
    t.start()

    return redirect(url_for("job", job_id=job_id))


@app.get("/job/<job_id>")
def job(job_id: str):
    if job_id not in JOBS:
        return "Job not found", 404
    return render_template("job.html", job_id=job_id, job=JOBS[job_id])


@app.get("/api/job/<job_id>")
def job_api(job_id: str):
    if job_id not in JOBS:
        return jsonify({"error": "not_found"}), 404
    return jsonify({"job_id": job_id, **JOBS[job_id]})


@app.get("/logs/<job_id>")
def logs(job_id: str):
    if job_id not in LOG_QUEUES:
        return "Job not found", 404

    q = LOG_QUEUES[job_id]

    def event_stream():
        while True:
            item = q.get()
            if item is None:
                yield "event: done\ndata: done\n\n"
                break
            # SSE data must not contain bare newlines; split lines
            for part in str(item).splitlines(True):
                data = part.replace("\r", "")
                yield f"data: {data}\n"
            yield "\n"

    return Response(event_stream(), mimetype="text/event-stream")


def main():
    host = os.environ.get("UI_HOST", "127.0.0.1")
    port = int(os.environ.get("UI_PORT", "5050"))
    app.run(host=host, port=port, debug=False, threaded=True)


if __name__ == "__main__":
    main()

