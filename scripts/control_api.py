#!/usr/bin/env python3
"""
API de contrôle du laboratoire
- Utilise docker-compose (v1) DANS le conteneur
- Pointeur explicite vers /project/docker-compose.yml
"""
import os
import subprocess
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

PROJECT_DIR = os.environ.get("PROJECT_DIR", "/project")
COMPOSE_FILE = os.environ.get("COMPOSE_FILE", os.path.join(PROJECT_DIR, "docker-compose.yml"))

def run_command(cmd, cwd=None):
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=cwd
        )
        return {
            "success": result.returncode == 0,
            "code": result.returncode,
            "output": (result.stdout or "").strip(),
            "error": (result.stderr or "").strip(),
        }
    except Exception as e:
        return {"success": False, "code": -1, "output": "", "error": str(e)}

def compose(args):
    return run_command(["docker-compose", "-f", COMPOSE_FILE] + args, cwd=PROJECT_DIR)

@app.route("/api/control/start", methods=["POST"])
def start_lab():
    result = compose(["up", "-d"])
    if result["success"]:
        return jsonify({"status": "running", "message": "Laboratoire démarré avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result['error'] or result['output'] or 'Unknown error'}"}), 500

@app.route("/api/control/stop", methods=["POST"])
def stop_lab():
    result = compose(["stop"])
    if result["success"]:
        return jsonify({"status": "stopped", "message": "Laboratoire arrêté avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result['error'] or result['output'] or 'Unknown error'}"}), 500

@app.route("/api/control/restart", methods=["POST"])
def restart_lab():
    result = compose(["restart"])
    if result["success"]:
        return jsonify({"status": "running", "message": "Laboratoire redémarré avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result['error'] or result['output'] or 'Unknown error'}"}), 500

@app.route("/api/control/destroy", methods=["POST"])
def destroy_lab():
    # down + volumes
    result = compose(["down", "-v", "--remove-orphans"])
    if result["success"]:
        return jsonify({"status": "destroyed", "message": "Laboratoire détruit avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result['error'] or result['output'] or 'Unknown error'}"}), 500

@app.route("/api/logs", methods=["GET"])
def get_logs():
    result = compose(["logs", "--tail=50"])
    logs = result.get("output") or result.get("error") or "Aucun log disponible"
    return jsonify({"logs": logs})

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "project_dir": PROJECT_DIR,
        "compose_file": COMPOSE_FILE
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=False)
