#!/usr/bin/env python3
"""
Service de détection automatique des machines sur le réseau
"""
import subprocess
import json
import re
from flask import Flask, jsonify
import threading
import time

app = Flask(__name__)

def get_network_range():
    """Détecte automatiquement la plage réseau"""
    try:
        result = subprocess.run(['ip', 'route'], capture_output=True, text=True)
        for line in result.stdout.split('\n'):
            if 'default' in line:
                parts = line.split()
                gateway = parts[2]
                # Extraire le réseau
                result2 = subprocess.run(['ip', 'addr', 'show'], capture_output=True, text=True)
                for line2 in result2.stdout.split('\n'):
                    if 'inet ' in line2 and gateway.split('.')[0] in line2:
                        ip_match = re.search(r'inet (\d+\.\d+\.\d+\.\d+)/\d+', line2)
                        if ip_match:
                            ip = ip_match.group(1)
                            return f"{'.'.join(ip.split('.')[:-1])}.0/24"
    except:
        pass
    return "192.168.1.0/24"  # Fallback

def scan_network(network_range):
    """Scanne le réseau et retourne les machines trouvées"""
    devices = []
    try:
        # Utiliser nmap pour scanner
        result = subprocess.run(
            ['nmap', '-sn', network_range],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        current_device = {}
        for line in result.stdout.split('\n'):
            if 'Nmap scan report for' in line:
                if current_device:
                    devices.append(current_device)
                current_device = {}
                # Extraire l'IP
                ip_match = re.search(r'(\d+\.\d+\.\d+\.\d+)', line)
                if ip_match:
                    current_device['ip'] = ip_match.group(1)
                    # Extraire le hostname si présent
                    hostname_match = re.search(r'for (.+) \(', line)
                    if hostname_match:
                        current_device['hostname'] = hostname_match.group(1)
            elif 'MAC Address:' in line:
                mac_match = re.search(r'MAC Address: ([0-9A-Fa-f:]+)', line)
                if mac_match:
                    current_device['mac'] = mac_match.group(1)
                vendor_match = re.search(r'\((.+)\)', line)
                if vendor_match:
                    current_device['vendor'] = vendor_match.group(1)
        
        if current_device:
            devices.append(current_device)
            
    except subprocess.TimeoutExpired:
        pass
    except Exception as e:
        print(f"Erreur lors du scan: {e}")
    
    return devices

@app.route('/api/discover', methods=['GET'])
def discover():
    """Endpoint pour découvrir les machines sur le réseau"""
    network_range = get_network_range()
    devices = scan_network(network_range)
    return jsonify({
        'network': network_range,
        'devices': devices,
        'count': len(devices)
    })

@app.route('/api/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({'status': 'ok'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=False)
