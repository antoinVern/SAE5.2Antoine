# SAÉ 5.02 — Piloter un projet informatique

## Environnement Virtuel d'Audit de Sécurité Réseau

Ce projet met en place une **plateforme d'audit de sécurité réseau entièrement automatisée** permettant de créer, déployer et gérer des environnements d'audit éphémères et reproductibles.

### 🎯 Fonctionnalités

- ✅ **Automatisation complète** : Déploiement, audit et destruction via Ansible
- ✅ **Virtualisation** : Infrastructure réseau avec Vagrant/VirtualBox (LAN/DMZ)
- ✅ **Conteneurisation** : Outils d'audit isolés avec Docker/Docker Compose
- ✅ **Consolidation** : Génération automatique de rapports HTML synthétiques
- ✅ **Sécurité** : Gestion des secrets avec Ansible Vault
- ✅ **Documentation** : Documentation technique et tutoriel technicien

### 📋 Topologie réseau

```
┌─────────────────────────────────────────┐
│         Réseau Management                │
│           192.168.56.0/24               │
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

## 🚀 Démarrage rapide

> **📍 Où taper les commandes ?**  
> Ouvrez **PowerShell** dans le dossier du projet (`C:\Users\antoi\Documents\SAE5.2Antoine`)  
> Voir le [Guide de Démarrage Rapide](docs/GUIDE_DEMARRAGE_RAPIDE.md) pour plus de détails.

### Prérequis

- VirtualBox 6.0+
- Vagrant 2.2+
- Ansible 2.9+
- Python 3.8+
- Git

### Installation

1. **Cloner le dépôt:**

```bash
git clone <url-du-depot>
cd SAE5.2Antoine
```

2. **Installer les collections Ansible:**

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

### Utilisation (méthode recommandée)

**Windows (PowerShell):**

```powershell
# Scénario complet (déploiement + audit + consolidation)
.\scripts\run_audit.ps1 all

# Ou étape par étape
.\scripts\run_audit.ps1 deploy      # Déploiement
.\scripts\run_audit.ps1 audit       # Audit
.\scripts\run_audit.ps1 consolidate # Consolidation
.\scripts\run_audit.ps1 cleanup     # Nettoyage
```

**Linux/Mac:**

```bash
chmod +x scripts/run_audit.sh
./scripts/run_audit.sh all
```

### Utilisation (méthode manuelle)

1. **Démarrer les VMs:**

```bash
cd vagrant
vagrant up
```

2. **Générer l'inventaire Ansible:**

```powershell
.\scripts\gen-inventory.ps1
```

3. **Lancer le scénario complet:**

```bash
ansible-playbook playbooks/site.yml
```

## 📊 Rapports d'audit

Les rapports sont générés dans `/opt/audit/reports` sur la VM `attaquant` :

- **Rapports bruts** : `scan_*.xml`, `scan_*.txt` (format Nmap)
- **Rapport consolidé** : `audit_consolidated_report.html` (HTML stylisé)
- **Données JSON** : `audit_consolidated_report.json` (pour traitement)

**Consulter le rapport:**

```bash
vagrant ssh attaquant
cat /opt/audit/reports/audit_consolidated_report.html
```

## 📚 Documentation

- **[Documentation technique](docs/DOCUMENTATION_TECHNIQUE.md)** : Architecture, maintenance, dépannage
- **[Tutoriel technicien](docs/TUTORIEL_TECHNICIEN.md)** : Guide pas à pas pour prise en main
- **[Cahier des charges](CDC%20SAE5.2.pdf)** : Spécifications du projet

## 🏗️ Structure du projet

```
SAE5.2Antoine/
├── vagrant/              # Configuration Vagrant (VMs)
├── playbooks/            # Playbooks Ansible
│   ├── site.yml         # Playbook principal
│   ├── 10_install_docker.yml
│   ├── 15_config_fw.yml
│   ├── 20_deploy_cible_dmz.yml
│   ├── 30_scan_nmap.yml
│   ├── 40_consolidate_reports.yml
│   └── 99_cleanup.yml
├── roles/                # Rôles Ansible
├── docker/               # Docker Compose pour audit
├── scripts/              # Scripts utilitaires
│   ├── run_audit.ps1    # Wrapper PowerShell
│   ├── run_audit.sh     # Wrapper Bash
│   ├── gen-inventory.ps1
│   └── consolidate_reports.py
├── docs/                 # Documentation
├── inventory/            # Inventaire Ansible
└── group_vars/          # Variables Ansible (dont Vault)
```

## 🔒 Sécurité

- **Ansible Vault** : Secrets chiffrés dans `group_vars/all/vault.yml`
- **Isolation réseau** : Réseaux privés VirtualBox
- **Firewall** : Règles nftables sur le routeur
- **Environnement éphémère** : Destruction après audit

## 🧹 Nettoyage

```bash
# Nettoyer conteneurs et rapports
ansible-playbook playbooks/99_cleanup.yml

# Arrêter les VMs
cd vagrant
vagrant halt

# Destruction complète (supprime les VMs)
vagrant destroy
```

## 📝 Livrables

- ✅ Playbooks Ansible fonctionnels
- ✅ Fichiers Docker/Docker Compose
- ✅ Scripts Python de consolidation
- ✅ Documentation technique complète
- ✅ Tutoriel technicien
- ✅ Maquette de démonstration fonctionnelle

## 🆘 Support

En cas de problème, consulter :
- La section **Dépannage** de la documentation technique
- Les logs avec `ansible-playbook -vvv`
- Le tutoriel technicien pour les étapes de base

---

**Projet réalisé dans le cadre de la SAÉ 5.02 - BUT3 Réseaux et Télécommunications**
