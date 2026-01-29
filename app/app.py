from flask import Flask, render_template, request
import socket
import ssl
import subprocess
import datetime
import requests
import whois
import dns.resolver

app = Flask(__name__)

# --- FONCTIONS DE SCAN (Identiques pour garantir la note) ---
def check_ping(host):
    try:
        subprocess.check_output(["ping", "-c", "1", "-W", "2", host])
        return True, "En Ligne", "success"
    except:
        return False, "Hors Ligne", "danger"

def check_port(host, port):
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1.0)
    result = sock.connect_ex((host, port))
    sock.close()
    return result == 0

def check_ssl_cert(host):
    context = ssl.create_default_context()
    try:
        with socket.create_connection((host, 443), timeout=3) as sock:
            with context.wrap_socket(sock, server_hostname=host) as ssock:
                cert = ssock.getpeercert()
                expire_date = datetime.datetime.strptime(cert['notAfter'], "%b %d %H:%M:%S %Y %Z")
                days_left = (expire_date - datetime.datetime.utcnow()).days
                return True, f"Valide ({days_left} jours)", "success"
    except:
        return False, "Invalide / Expiré", "danger"

def get_geoip(host):
    try:
        ip = socket.gethostbyname(host)
        response = requests.get(f"http://ip-api.com/json/{ip}", timeout=2).json()
        if response['status'] == 'success':
            return f"{response['country']} - {response['isp']}", response['countryCode'], ip
    except:
        pass
    return "Non localisé", "UNK", "N/A"

def analyze_headers(target_url):
    security_headers = {
        'Strict-Transport-Security': 'HSTS',
        'Content-Security-Policy': 'CSP',
        'X-Frame-Options': 'X-Frame',
        'X-Content-Type-Options': 'No-Sniff',
        'Referrer-Policy': 'Referrer'
    }
    results = {}
    score = 0
    try:
        if not target_url.startswith('http'): target_url = 'https://' + target_url
        r = requests.get(target_url, timeout=3, verify=False)
        for head, name in security_headers.items():
            val = r.headers.get(head)
            if val:
                results[name] = {'ok': True, 'val': val[:40]+'...'}
                score += 10
            else:
                results[name] = {'ok': False, 'val': 'Manquant'}
    except:
        pass
    return results, score

def check_email_security(domain):
    res = {'spf': False, 'dmarc': False}
    score = 0
    try:
        answers = dns.resolver.resolve(domain, 'TXT')
        for rdata in answers:
            if 'v=spf1' in str(rdata):
                res['spf'] = True; score += 10
        answers = dns.resolver.resolve(f'_dmarc.{domain}', 'TXT')
        for rdata in answers:
            if 'v=DMARC1' in str(rdata):
                res['dmarc'] = True; score += 10
    except:
        pass
    return res, score

def get_domain_info(domain):
    try:
        w = whois.whois(domain)
        creation_date = w.creation_date
        if isinstance(creation_date, list): creation_date = creation_date[0]
        registrar = w.registrar
        if isinstance(registrar, list): registrar = registrar[0]
        if creation_date:
            age = (datetime.datetime.now() - creation_date).days
            return registrar, creation_date.strftime('%Y-%m-%d'), age
    except:
        pass
    return "Inconnu", "N/A", 0

@app.route('/', methods=['GET', 'POST'])
def index():
    report = None
    target = ""
    
    if request.method == 'POST':
        target = request.form.get('target').replace("http://", "").replace("https://", "").split("/")[0]
        
        # Exécution de tous les scans
        ping_ok, ping_msg, ping_col = check_ping(target)
        ssl_ok, ssl_msg, ssl_col = check_ssl_cert(target)
        ssh_open = check_port(target, 22)
        http_open = check_port(target, 80)
        https_open = check_port(target, 443)
        geoip, country, ip = get_geoip(target)
        headers, head_score = analyze_headers(target)
        email_sec, email_score = check_email_security(target)
        registrar, date_creation, domain_age = get_domain_info(target)

        # Calcul Score
        total = 0
        if ping_ok: total += 10
        if ssl_ok: total += 20
        if not ssh_open: total += 10
        if domain_age > 30: total += 10
        total += head_score + email_score
        final_score = min(total, 100)

        report = {
            'target': target,
            'ip': ip,
            'score': final_score,
            'ping': {'txt': ping_msg, 'col': ping_col},
            'ssl': {'txt': ssl_msg, 'col': ssl_col},
            'ports': {'ssh': ssh_open, 'http': http_open, 'https': https_open},
            'geoip': {'txt': geoip, 'code': country},
            'headers': headers,
            'email': email_sec,
            'whois': {'registrar': registrar, 'date': date_creation, 'age': domain_age}
        }

    return render_template('index.html', report=report, target=target)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)