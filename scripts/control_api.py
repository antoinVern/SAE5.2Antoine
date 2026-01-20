#!/usr/bin/env python3
import os
import subprocess
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

PROJECT_DIR = os.environ.get("PROJECT_DIR", "/project")
COMPOSE_FILE = os.environ.get("COMPOSE_FILE", os.path.join(PROJECT_DIR, "docker-compose.yml"))

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
    # docker-compose (v1) dans le conteneur control-api
    return run(["docker-compose", "-f", COMPOSE_FILE] + args, cwd=PROJECT_DIR)

@app.route("/api/control/start", methods=["POST"])
def start_lab():
    # 🔥 évite les conflits de noms: down + remove-orphans avant up
    cleanup = compose(["down", "-v", "--remove-orphans"])
    up = compose(["up", "-d", "--build"])

    if up["success"]:
        return jsonify({"status": "running", "message": "Laboratoire démarré avec succès"})

    # si down a échoué mais up a aussi échoué, on renvoie le max d'info
    msg = up["err"] or up["out"] or "Unknown error"
    if cleanup["err"] or cleanup["out"]:
        msg = f"{cleanup['err'] or cleanup['out']}\n{msg}".strip()

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
    r = compose(["logs", "--tail=80"])
    return jsonify({"logs": r["out"] or r["err"] or "Aucun log disponible"})

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "project_dir": PROJECT_DIR, "compose_file": COMPOSE_FILE})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=False)
