#!/usr/bin/env python3
"""
Script de consolidation des rapports d'audit Nmap
Génère un rapport synthétique à partir des fichiers XML/TXT générés par Nmap
"""

import os
import sys
import xml.etree.ElementTree as ET
from datetime import datetime
from pathlib import Path
import json

REPORTS_DIR = Path("/reports")
OUTPUT_FILE = REPORTS_DIR / "audit_consolidated_report.html"


def parse_nmap_xml(xml_file):
    """Parse un fichier XML Nmap et extrait les informations principales"""
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
        
        scan_info = {
            'target': root.find('.//address').get('addr') if root.find('.//address') is not None else 'Unknown',
            'scan_date': root.get('scanner') + ' ' + root.get('args') if root.get('args') else 'N/A',
            'hosts_up': 0,
            'hosts_down': 0,
            'open_ports': [],
            'services': []
        }
        
        for host in root.findall('host'):
            status = host.find('status')
            if status is not None and status.get('state') == 'up':
                scan_info['hosts_up'] += 1
                
                # Extraire les ports ouverts
                for port in host.findall('.//port'):
                    port_state = port.find('state')
                    if port_state is not None and port_state.get('state') == 'open':
                        port_id = port.get('portid')
                        protocol = port.get('protocol')
                        service = port.find('service')
                        service_name = service.get('name') if service is not None else 'unknown'
                        
                        scan_info['open_ports'].append({
                            'port': port_id,
                            'protocol': protocol,
                            'service': service_name
                        })
                        
                        scan_info['services'].append(f"{service_name} ({protocol}/{port_id})")
            else:
                scan_info['hosts_down'] += 1
        
        return scan_info
    except Exception as e:
        print(f"Erreur lors du parsing de {xml_file}: {e}", file=sys.stderr)
        return None


def generate_html_report(scan_results):
    """Génère un rapport HTML consolidé"""
    html_content = f"""<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport d'Audit Consolidé - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</title>
    <style>
        body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }}
        .container {{
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        h1 {{
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }}
        h2 {{
            color: #34495e;
            margin-top: 30px;
        }}
        .summary {{
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }}
        .card {{
            background: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #3498db;
        }}
        .card h3 {{
            margin: 0 0 10px 0;
            color: #2c3e50;
        }}
        .card .value {{
            font-size: 2em;
            font-weight: bold;
            color: #3498db;
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }}
        th, td {{
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }}
        th {{
            background-color: #3498db;
            color: white;
        }}
        tr:hover {{
            background-color: #f5f5f5;
        }}
        .port-open {{
            color: #e74c3c;
            font-weight: bold;
        }}
        .footer {{
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            color: #7f8c8d;
            font-size: 0.9em;
        }}
    </style>
</head>
<body>
    <div class="container">
        <h1>🔒 Rapport d'Audit de Sécurité Réseau Consolidé</h1>
        <p><strong>Date de génération:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
        
        <h2>📊 Résumé Exécutif</h2>
        <div class="summary">
            <div class="card">
                <h3>Hôtes Scannés</h3>
                <div class="value">{len(scan_results)}</div>
            </div>
            <div class="card">
                <h3>Ports Ouverts</h3>
                <div class="value">{sum(len(r['open_ports']) for r in scan_results if r)}</div>
            </div>
            <div class="card">
                <h3>Services Détectés</h3>
                <div class="value">{len(set(s for r in scan_results if r for s in r['services']))}</div>
            </div>
        </div>
        
        <h2>🎯 Détails par Cible</h2>
"""
    
    for result in scan_results:
        if result:
            html_content += f"""
        <h3>Cible: {result['target']}</h3>
        <table>
            <tr>
                <th>Statut</th>
                <th>Ports Ouverts</th>
                <th>Services</th>
            </tr>
"""
            if result['open_ports']:
                for port_info in result['open_ports']:
                    html_content += f"""
            <tr>
                <td><span class="port-open">OUVERT</span></td>
                <td>{port_info['protocol'].upper()}/{port_info['port']}</td>
                <td>{port_info['service']}</td>
            </tr>
"""
            else:
                html_content += """
            <tr>
                <td colspan="3">Aucun port ouvert détecté</td>
            </tr>
"""
            html_content += """
        </table>
"""
    
    html_content += f"""
        <div class="footer">
            <p><strong>Généré par:</strong> Script de consolidation d'audit SAÉ 5.02</p>
            <p><strong>Environnement:</strong> Maquette LAN/DMZ automatisée (Vagrant + Ansible + Docker)</p>
        </div>
    </div>
</body>
</html>
"""
    
    return html_content


def main():
    """Fonction principale"""
    if not REPORTS_DIR.exists():
        print(f"Erreur: Le répertoire {REPORTS_DIR} n'existe pas", file=sys.stderr)
        sys.exit(1)
    
    # Chercher tous les fichiers XML Nmap
    xml_files = list(REPORTS_DIR.glob("*.xml"))
    
    if not xml_files:
        print("Aucun fichier XML Nmap trouvé dans /reports", file=sys.stderr)
        # Générer un rapport vide
        with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
            f.write(generate_html_report([]))
        sys.exit(0)
    
    # Parser tous les fichiers XML
    scan_results = []
    for xml_file in xml_files:
        result = parse_nmap_xml(xml_file)
        if result:
            scan_results.append(result)
    
    # Générer le rapport HTML consolidé
    html_report = generate_html_report(scan_results)
    
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(html_report)
    
    # Générer aussi un JSON pour traitement ultérieur
    json_file = REPORTS_DIR / "audit_consolidated_report.json"
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(scan_results, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Rapport consolidé généré: {OUTPUT_FILE}")
    print(f"✅ Données JSON générées: {json_file}")
    print(f"📊 {len(scan_results)} scan(s) consolidé(s)")


if __name__ == "__main__":
    main()
