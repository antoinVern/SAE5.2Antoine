# 🔒 Plateforme d'Audit de Sécurité Réseau

[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue)](https://github.com/antoinVern/SAE5.2Antoine)
[![Ansible](https://img.shields.io/badge/Ansible-2.9+-green)](https://www.ansible.com/)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue)](https://www.docker.com/)
[![One-Click](https://img.shields.io/badge/Installation-One--Click-success)](INSTALL.bat)

> **Plateforme d'audit de sécurité réseau entièrement automatisée** avec Vagrant, Ansible et Docker.  
> **Installation et lancement en UN CLIC** ou via **interface web avec boutons** ! ⚡

---

## 🚀 Démarrage Rapide

### Option 1 : Interface Web (ZÉRO COMMANDES) 🖱️

**Le plus simple :**

1. **Télécharge le projet** (clone Git ou ZIP depuis GitHub)
2. **Double-clique sur `LAUNCH_UI.bat`**
3. **La page web s'ouvre automatiquement** : `http://127.0.0.1:5050`
4. **Clique sur les boutons** :
   - 🚀 **Déployer** → Crée les VMs et configure tout
   - 🔍 **Audit** → Lance les scans d'audit
   - 📊 **Consolider** → Génère le rapport HTML
   - 🧹 **Nettoyer** → Supprime tout
   - ⚡ **Tout faire** → Exécute tout en une fois
5. **Les logs s'affichent en direct** dans la page web

**C'est tout ! Aucune commande à taper, juste des clics sur des boutons.** 🎉

### Option 2 : Scripts ONE-CLICK (Windows)

1. **Double-clique sur `INSTALL.bat`** → Installation automatique
2. **Double-clique sur `LAUNCH.bat`** → Lancement complet

### Option 3 : Ligne de commande

**Windows :**
```powershell
# Installation
.\INSTALL.bat
# OU
.\scripts\install-complete.ps1

# Lancement
ansible-playbook site.yml
# OU
.\scripts\run_audit.ps1 all
```

**Linux/Mac :**
```bash
# Installation
chmod +x install.sh
./install.sh

# Lancement
ansible-playbook site.yml
```

---

## 📋 Prérequis

Le script d'installation vérifie automatiquement :

- ✅ **VirtualBox** ([Télécharger](https://www.virtualbox.org/wiki/Downloads))
- ✅ **Vagrant** ([Télécharger](https://www.vagrantup.com/downloads))
- ✅ **Ansible** ([Installation](https://docs.ansible.com/ansible/latest/installation_guide/index.html))
- ✅ **Git** ([Télécharger](https://git-scm.com/downloads))
- ✅ **Python 3** (pour l'interface web)

**Vérification manuelle :**
```powershell
vagrant --version
ansible --version
python --version
```

---

## 🎯 Ce qui se passe automatiquement

Quand tu lances le déploiement (via bouton web ou commande), le système :

- ✅ **Crée les VMs** (attaquant, firewall, cible DMZ) via Vagrant
- ✅ **Configure le réseau** (LAN/DMZ) et les routes
- ✅ **Configure le firewall** (nftables avec règles de filtrage)
- ✅ **Installe Docker** sur les machines nécessaires
- ✅ **Déploie les conteneurs** (nginx en DMZ, outils d'audit)
- ✅ **Lance les scans d'audit** Nmap (découverte + scan ports)
- ✅ **Génère le rapport HTML consolidé** avec tous les résultats

---

## 📊 Consulter les rapports

Une fois l'audit terminé, les rapports sont disponibles sur la VM `attaquant` :

```powershell
# Se connecter à la VM attaquant
cd vagrant
vagrant ssh attaquant

# Consulter le rapport consolidé
cat /opt/audit/reports/audit_consolidated_report.html

# Ou lister tous les rapports
ls -lh /opt/audit/reports/
```

**Récupérer le rapport sur Windows :**
```powershell
vagrant ssh attaquant -- "cat /opt/audit/reports/audit_consolidated_report.html" > rapport.html
start rapport.html
```

---

## 🏗️ Architecture

### Topologie réseau

```
┌─────────────────────────────────────────┐
│         Réseau Management              │
│           192.168.56.0/24             │
└─────────────────────────────────────────┘
              │
    ┌─────────┼─────────┐
    │         │         │
┌───▼───┐ ┌───▼───┐ ┌───▼────┐
│Attaq. │ │  FW   │ │Cible   │
│10.10. │ │10.10. │ │10.10.  │
│10.10  │ │10.1   │ │20.20   │
│(LAN)  │ │20.1   │ │(DMZ)   │
└───────┘ └───────┘ └────────┘
```

- **attaquant** (LAN): `10.10.10.10` + management `192.168.56.10`
- **fw** (firewall): `10.10.10.1` (LAN) + `10.10.20.1` (DMZ) + management `192.168.56.12`
- **cible_dmz** (service web): `10.10.20.20` + management `192.168.56.20`

### Rôles Ansible

Le projet utilise une architecture modulaire avec des rôles organisés :

| Rôle | Description |
|------|-------------|
| **`docker_moteur`** | Installation et configuration de Docker |
| **`securite`** | Configuration firewall (nftables) et routage |
| **`socle_commun`** | Configuration routes réseau inter-VMs |
| **`deploiement_app`** | Déploiement application cible (nginx en conteneur) |
| **`audit`** | Installation outils d'audit et exécution scans Nmap |
| **`docs`** | Documentation des rôles |

---

## 🏗️ Structure du projet

```
SAE5.2Antoine/
├── site.yml                 # Playbook principal (à la racine)
├── install.sh               # Script d'installation (Linux/Mac)
├── INSTALL.bat              # Script d'installation (Windows)
├── LAUNCH_UI.bat            # Interface web locale (boutons)
├── inventory.ini            # Inventaire Ansible (à la racine)
├── README.md                # Documentation principale
├── roles/                   # Rôles Ansible organisés
│   ├── docker_moteur/      # Installation Docker
│   ├── securite/           # Configuration firewall/réseau
│   ├── socle_commun/       # Configuration routes
│   ├── deploiement_app/    # Déploiement application cible
│   ├── audit/              # Outils et scans d'audit
│   └── docs/               # Documentation des rôles
├── vagrant/                 # Configuration Vagrant (VMs)
├── docker/                  # Docker Compose pour audit
├── scripts/                 # Scripts utilitaires
│   ├── run_audit.ps1       # Wrapper PowerShell
│   ├── run_audit.sh        # Wrapper Bash
│   ├── install-complete.ps1 # Installation complète
│   └── consolidate_reports.py # Consolidation rapports
├── ui/                      # Interface web locale
│   ├── app.py              # Serveur Flask
│   └── templates/          # Templates HTML
├── docs/                    # Documentation complète
└── group_vars/              # Variables Ansible (dont Vault)
```

---

## 🎯 Commandes disponibles

### Via interface web (recommandé)

Double-clic sur `LAUNCH_UI.bat` puis clic sur les boutons.

### Via ligne de commande

**Scénario complet :**
```powershell
ansible-playbook site.yml
# OU
.\scripts\run_audit.ps1 all
```

**Commandes individuelles :**
```powershell
.\scripts\run_audit.ps1 deploy      # Déploie l'infrastructure
.\scripts\run_audit.ps1 audit       # Lance les scans d'audit
.\scripts\run_audit.ps1 consolidate # Génère le rapport HTML
.\scripts\run_audit.ps1 cleanup     # Nettoie tout
```

---

## 🔒 Sécurité

- **Ansible Vault** : Secrets chiffrés dans `group_vars/all/vault.yml`
- **Isolation réseau** : Réseaux privés VirtualBox
- **Firewall** : Règles nftables sur le routeur
- **Environnement éphémère** : Destruction après audit

---

## 🧹 Nettoyage

**Via interface web :**
- Clique sur le bouton **🧹 Nettoyer**

**Via ligne de commande :**
```powershell
# Nettoyer conteneurs et rapports
.\scripts\run_audit.ps1 cleanup

# Destruction complète des VMs
cd vagrant
vagrant destroy
```

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| **[QUICK_START.md](QUICK_START.md)** | ⚡ Guide ultra-rapide en 30 secondes |
| **[Installation](docs/INSTALL.md)** | Installation complète (style GitLab) |
| **[Interface Web](docs/UI_LOCALE.md)** | Guide d'utilisation de l'interface web |
| **[Guide de Démarrage Rapide](docs/GUIDE_DEMARRAGE_RAPIDE.md)** | 📍 Où taper les commandes ? |
| **[Tutoriel Technicien](docs/TUTORIEL_TECHNICIEN.md)** | Guide pas à pas complet |
| **[Documentation Technique](docs/DOCUMENTATION_TECHNIQUE.md)** | Architecture, maintenance, dépannage |

---

## ❓ FAQ

### L'interface web ne s'ouvre pas ?

1. Vérifie que Python est installé : `python --version`
2. Vérifie que le port 5050 n'est pas utilisé
3. Relance `LAUNCH_UI.bat` en mode administrateur si nécessaire

### Les VMs ne démarrent pas ?

- Vérifie que VirtualBox est installé et fonctionnel
- Vérifie qu'il y a assez de RAM (minimum 4 GB recommandé)
- Consulte la section **Dépannage** de la [Documentation Technique](docs/DOCUMENTATION_TECHNIQUE.md)

### Comment modifier les règles du firewall ?

Édite `roles/securite/tasks/main.yml` puis relance :
```powershell
ansible-playbook site.yml
```

### Comment utiliser un autre provider Vagrant ?

Modifie `vagrant/Vagrantfile` pour utiliser un autre provider (libvirt, VMware, etc.)

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Voir [CONTRIBUTING.md](CONTRIBUTING.md)

---

## 📝 Licence

Ce projet est réalisé dans le cadre de la **SAÉ 5.02 - BUT3 Réseaux et Télécommunications**.

---

## ⭐ Star le projet

Si ce projet vous est utile, n'hésitez pas à ⭐ **star** le dépôt !

---

**Créé avec ❤️ par [Antoine Vernay](https://github.com/antoinVern)**
