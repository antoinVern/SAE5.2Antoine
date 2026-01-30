# 🛡️ CyberMonitor Pro

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)  
![Security](https://img.shields.io/badge/Security-Audit-green)  
![Docker](https://img.shields.io/badge/Docker-Ready-blue)  
![Ansible](https://img.shields.io/badge/Deployed%20with-Ansible-red)

**CyberMonitor Pro** est une plateforme de **surveillance "Blue Team"** et d'audit de sécurité automatisée.  
Conçue pour les administrateurs systèmes et les équipes SecOps, elle permet de vérifier instantanément la conformité, la sécurité et la santé d'une cible (Nom de domaine ou Adresse IP).

L'outil est entièrement **conteneurisé (Docker)** et se déploie automatiquement grâce à **Ansible**.

---

## 🚀 Fonctionnalités Clés

- **📊 Scoring de Sécurité :** Algorithme de notation intelligent (0-100) avec jauge visuelle  
- **🌐 Audit Réseau :** Vérification de la disponibilité (Ping) et des ports critiques (SSH, HTTP, HTTPS)  
- **🔒 Analyse SSL/TLS :** Validation de la chaîne de certification et alerte d'expiration  
- **📧 Sécurité Email & DNS :** Détection des protections anti-spoofing (SPF, DMARC)  
- **🛡️ En-têtes HTTP (OWASP) :** Audit des headers de sécurité (HSTS, CSP, X-Frame, X-Content...)  
- **🏢 Threat Intelligence :** Identification du Registrar, calcul de l'âge du domaine et géolocalisation  
- **🎨 Interface Moderne :** Tableau de bord professionnel avec navigation par onglets  

---

## 🛠️ Architecture Technique

- **Frontend / Backend :** Python Flask + Bootstrap 5  
- **Conteneurisation :** Docker (Image Python optimisée)  
- **Orchestration :** Ansible (Playbooks d'automatisation)  
- **Librairies :** `whois`, `dnspython`, `requests`, `chart.js`  

---

## 📋 Prérequis

Environnement Linux (Ubuntu, Debian, Kali ou WSL2 sous Windows) avec :

- **Git**  
- **Ansible**  

Installation si nécessaire :

```bash
sudo apt update
sudo apt install -y ansible git
```

---

## ⚡ Installation Rapide

### 1️⃣ Cloner le dépôt

```bash
git clone https://github.com/antoinVern/SAE5.2Antoine.git
cd SAE5.2Antoine
```

### 2️⃣ Lancer l'installation

```bash
chmod +x install.sh
./install.sh
```

Puis ouvrir : http://localhost:5000

---

## 🖥️ Guide d'Utilisation

**Cible :** entrer une IP (1.1.1.1) ou domaine (google.com)  
**Scan :** cliquer sur "LANCER L'AUDIT"  
**Résultats :** navigation via les onglets Vue d'ensemble, Réseau, Sécurité Web, Identité  

---

## 👤 Auteur

Projet réalisé dans un cadre **Cyber-Défense / DevOps**.

> ⚠️ Usage éducatif et défensif uniquement.
