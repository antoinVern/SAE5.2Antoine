#!/usr/bin/env python3
"""
API de contrôle du laboratoire
"""
import subprocess
import os
from flask import Flask, jsonify, request
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

LAB_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def run_command(cmd):
    """Exécute une commande shell"""
    try:
        result = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            cwd=LAB_DIR
        )
        return {
            'success': result.returncode == 0,
            'output': result.stdout,
            'error': result.stderr
        }
    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }

@app.route('/api/control/start', methods=['POST'])
def start_lab():
    """Démarrer le laboratoire"""
    result = run_command('docker-compose up -d')
    if result['success']:
        return jsonify({
            'status': 'running',
            'message': 'Laboratoire démarré avec succès'
        })
    else:
        return jsonify({
            'status': 'error',
            'message': f"Erreur: {result.get('error', 'Unknown error')}"
        }), 500

@app.route('/api/control/stop', methods=['POST'])
def stop_lab():
    """Arrêter le laboratoire"""
    result = run_command('docker-compose stop')
    if result['success']:
        return jsonify({
            'status': 'stopped',
            'message': 'Laboratoire arrêté avec succès'
        })
    else:
        return jsonify({
            'status': 'error',
            'message': f"Erreur: {result.get('error', 'Unknown error')}"
        }), 500

@app.route('/api/control/restart', methods=['POST'])
def restart_lab():
    """Redémarrer le laboratoire"""
    result = run_command('docker-compose restart')
    if result['success']:
        return jsonify({
            'status': 'running',
            'message': 'Laboratoire redémarré avec succès'
        })
    else:
        return jsonify({
            'status': 'error',
            'message': f"Erreur: {result.get('error', 'Unknown error')}"
        }), 500

@app.route('/api/control/destroy', methods=['POST'])
def destroy_lab():
    """Détruire le laboratoire"""
    result = run_command('./destroy.sh')
    if result['success']:
        return jsonify({
            'status': 'destroyed',
            'message': 'Laboratoire détruit avec succès'
        })
    else:
        return jsonify({
            'status': 'error',
            'message': f"Erreur: {result.get('error', 'Unknown error')}"
        }), 500

@app.route('/api/logs', methods=['GET'])
def get_logs():
    """Récupérer les logs"""
    result = run_command('docker-compose logs --tail=50')
    return jsonify({
        'logs': result.get('output', 'Aucun log disponible')
    })

@app.route('/api/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002, debug=False)
