#!/usr/bin/env python3
"""
API de contrôle du laboratoire
- Compatible Docker Compose v2 (docker compose)
"""
import subprocess
import os
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

LAB_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

COMPOSE_CMD = ["docker", "compose"]  # Compose v2

def run_command(cmd):
    """Exécute une commande (liste d'arguments, sans shell)"""
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            cwd=LAB_DIR
        )
        return {
            "success": result.returncode == 0,
            "output": result.stdout,
            "error": result.stderr
        }
    except Exception as e:
        return {"success": False, "error": str(e), "output": ""}

@app.route("/api/control/start", methods=["POST"])
def start_lab():
    result = run_command(COMPOSE_CMD + ["up", "-d"])
    if result["success"]:
        return jsonify({"status": "running", "message": "Laboratoire démarré avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result.get('error', 'Unknown error')}"}), 500

@app.route("/api/control/stop", methods=["POST"])
def stop_lab():
    result = run_command(COMPOSE_CMD + ["stop"])
    if result["success"]:
        return jsonify({"status": "stopped", "message": "Laboratoire arrêté avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result.get('error', 'Unknown error')}"}), 500

@app.route("/api/control/restart", methods=["POST"])
def restart_lab():
    result = run_command(COMPOSE_CMD + ["restart"])
    if result["success"]:
        return jsonify({"status": "running", "message": "Laboratoire redémarré avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result.get('error', 'Unknown error')}"}), 500

@app.route("/api/control/destroy", methods=["POST"])
def destroy_lab():
    # destroy.sh peut rester tel quel
    result = run_command(["bash", "./destroy.sh"])
    if result["success"]:
        return jsonify({"status": "destroyed", "message": "Laboratoire détruit avec succès"})
    return jsonify({"status": "error", "message": f"Erreur: {result.get('error', 'Unknown error')}"}), 500

@app.route("/api/logs", methods=["GET"])
def get_logs():
    result = run_command(COMPOSE_CMD + ["logs", "--tail=50"])
    logs = result.get("output") or result.get("error") or "Aucun log disponible"
    return jsonify({"logs": logs})

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=False)
