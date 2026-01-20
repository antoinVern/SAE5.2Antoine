#!/usr/bin/env python3
import os
import re
import shutil
import subprocess
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

PROJECT_DIR = os.environ.get("PROJECT_DIR", "/project")
COMPOSE_FILE = os.environ.get("COMPOSE_FILE", os.path.join(PROJECT_DIR, "docker-compose.yml"))
PROJECT_NAME = os.environ.get("COMPOSE_PROJECT_NAME", "project")
CRITICAL_PORTS = [15000, 15002, 18080, 13306]

def run(cmd, cwd=None):
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, cwd=cwd)
        return {
            "success": p.returncode == 0,
            "code": p.returncode,
            "out": (p.stdout or "").strip(),
            "err": (p.stderr or "").strip(),
        }
    except Exception as e:
        return {"success": False, "code": -1, "out": "", "err": str(e)}

def compose(args):
    """
    Utilise docker compose v2 si disponible, sinon docker-compose v1.
    """
    base = None
    if shutil.which("docker") and run(["docker", "compose", "version"])["success"]:
        base = ["docker", "compose", "-p", PROJECT_NAME, "-f", COMPOSE_FILE]
    elif shutil.which("docker-compose"):
        base = ["docker-compose", "-p", PROJECT_NAME, "-f", COMPOSE_FILE]
    else:
        return {"success": False, "code": 127, "out": "", "err": "docker compose / docker-compose introuvable"}

    return run(base + args, cwd=PROJECT_DIR)


def ensure_docker_ready():
    """Vérifie que le daemon Docker répond."""
    info = run(["docker", "info"])
    if info["success"]:
        return True, ""
    return False, info["err"] or info["out"] or "Docker n'est pas disponible"


def free_ports():
    """
    Libère les ports critiques utilisés par d'autres conteneurs pour éviter
    les erreurs “port already allocated”.
    """
    ps = run(["docker", "ps", "--format", "{{.ID}} {{.Ports}}"])
    if not ps["success"]:
        return False, ps["err"] or ps["out"] or "Impossible de lister les conteneurs"

    to_stop = []
    for line in (ps["out"] or "").splitlines():
        parts = line.split(maxsplit=1)
        if len(parts) != 2:
            continue
        cid, ports_str = parts
        for port in CRITICAL_PORTS:
            if re.search(rf"0\.0\.0\.0:{port}->|:{port}->", ports_str):
                to_stop.append(cid)
                break

    if not to_stop:
        return True, ""

    stop_res = run(["docker", "stop"] + to_stop)
    rm_res = run(["docker", "rm"] + to_stop)
    if stop_res["success"] and rm_res["success"]:
        return True, ""
    msg = (stop_res["err"] or stop_res["out"] or "") + "\n" + (rm_res["err"] or rm_res["out"] or "")
    return False, msg.strip()

@app.route("/api/control/start", methods=["POST"])
def start_lab():
    ready, err = ensure_docker_ready()
    if not ready:
        return jsonify({"status": "error", "message": f"Docker indisponible : {err}"}), 503

    freed, ferr = free_ports()
    if not freed:
        return jsonify({"status": "error", "message": f"Impossible de libérer les ports : {ferr}"}), 500

    # down avant up -> évite l’empilement
    down = compose(["down", "-v", "--remove-orphans"])
    up = compose(["up", "-d", "--build"])

    if up["success"]:
        return jsonify({"status": "running", "message": "Laboratoire démarré avec succès"})

    msg = up["err"] or up["out"] or "Unknown error"
    if down["err"] or down["out"]:
        msg = (down["err"] or down["out"]) + "\n" + msg

    return jsonify({"status": "error", "message": f"Erreur: {msg}"}), 500

@app.route("/api/control/stop", methods=["POST"])
def stop_lab():
    r = compose(["stop"])
    if r["success"]:
        return jsonify({"status": "stopped", "message": "Laboratoire arrêté avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {r['err'] or r['out'] or 'Unknown error'}"}), 500

@app.route("/api/control/restart", methods=["POST"])
def restart_lab():
    r = compose(["restart"])
    if r["success"]:
        return jsonify({"status": "running", "message": "Laboratoire redémarré avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {r['err'] or r['out'] or 'Unknown error'}"}), 500

@app.route("/api/control/destroy", methods=["POST"])
def destroy_lab():
    r = compose(["down", "-v", "--remove-orphans"])
    if r["success"]:
        return jsonify({"status": "destroyed", "message": "Laboratoire détruit avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {r['err'] or r['out'] or 'Unknown error'}"}), 500

@app.route("/api/logs", methods=["GET"])
def logs():
    r = compose(["logs", "--tail=120"])
    return jsonify({"logs": r["out"] or r["err"] or "Aucun log disponible"})

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "project": PROJECT_NAME, "compose_file": COMPOSE_FILE})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=False)
