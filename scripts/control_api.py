#!/usr/bin/env python3
"""
API de contrôle du laboratoire
- Docker Compose v2 (docker compose) + fallback v1 (docker-compose)
- Exécution sécurisée sans shell, et messages d'erreur clairs
"""
import subprocess
import os
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

LAB_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def detect_compose_cmd():
    # v2
    try:
        r = subprocess.run(["docker", "compose", "version"], capture_output=True, text=True, cwd=LAB_DIR)
        if r.returncode == 0:
            return ["docker", "compose"]
    except Exception:
        pass

    # v1
    try:
        r = subprocess.run(["docker-compose", "version"], capture_output=True, text=True, cwd=LAB_DIR)
        if r.returncode == 0:
            return ["docker-compose"]
    except Exception:
        pass

    return None

COMPOSE = detect_compose_cmd()

def run_command(cmd):
    """Exécute une commande: cmd peut être une liste ou une string."""
    try:
        if isinstance(cmd, str):
            # pour scripts: "bash ./destroy.sh" etc.
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=LAB_DIR)
        else:
            result = subprocess.run(cmd, capture_output=True, text=True, cwd=LAB_DIR)

        return {
            "success": result.returncode == 0,
            "output": (result.stdout or "").strip(),
            "error": (result.stderr or "").strip(),
            "code": result.returncode,
        }
    except Exception as e:
        return {"success": False, "output": "", "error": str(e), "code": -1}

def compose_or_error(args):
    if not COMPOSE:
        return {"success": False, "output": "", "error": "Docker Compose introuvable (v2 ou v1).", "code": -1}
    return run_command(COMPOSE + args)

@app.route("/api/control/start", methods=["POST"])
def start_lab():
    result = compose_or_error(["up", "-d"])
    if result["success"]:
        return jsonify({"status": "running", "message": "Laboratoire démarré avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result.get('error') or result.get('output') or 'Unknown error'}"}), 500

@app.route("/api/control/stop", methods=["POST"])
def stop_lab():
    result = compose_or_error(["stop"])
    if result["success"]:
        return jsonify({"status": "stopped", "message": "Laboratoire arrêté avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result.get('error') or result.get('output') or 'Unknown error'}"}), 500

@app.route("/api/control/restart", methods=["POST"])
def restart_lab():
    result = compose_or_error(["restart"])
    if result["success"]:
        return jsonify({"status": "running", "message": "Laboratoire redémarré avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result.get('error') or result.get('output') or 'Unknown error'}"}), 500

@app.route("/api/control/destroy", methods=["POST"])
def destroy_lab():
    # on laisse destroy.sh gérer le down -v etc.
    result = run_command("bash ./destroy.sh")
    if result["success"]:
        return jsonify({"status": "destroyed", "message": "Laboratoire détruit avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result.get('error') or result.get('output') or 'Unknown error'}"}), 500

@app.route("/api/logs", methods=["GET"])
def get_logs():
    result = compose_or_error(["logs", "--tail=50"])
    logs = result.get("output") or result.get("error") or "Aucun log disponible"
    return jsonify({"logs": logs})

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok", "compose": " ".join(COMPOSE) if COMPOSE else None})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=False)
