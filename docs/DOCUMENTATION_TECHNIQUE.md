# Documentation Technique - Plateforme d'Audit de Sécurité Réseau

**Projet:** SAÉ 5.02 - Piloter un projet informatique  
**Auteur:** Antoine Vernay  
**Date:** Novembre 2025  
**Version:** 1.0

---

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Composants techniques](#composants-techniques)
4. [Installation et configuration](#installation-et-configuration)
5. [Utilisation](#utilisation)
6. [Maintenance](#maintenance)
7. [Sécurité](#sécurité)
8. [Dépannage](#dépannage)

---

## Vue d'ensemble

Cette plateforme permet de créer, déployer et gérer un environnement d'audit de sécurité réseau éphémère et entièrement automatisé. Elle combine :

- **Virtualisation** (VirtualBox/Vagrant) pour l'infrastructure réseau
- **Conteneurisation** (Docker/Docker Compose) pour les outils d'audit
- **Automatisation** (Ansible) pour l'orchestration complète
- **Scripts Python** pour la consolidation des rapports

### Objectifs

- Fournir un banc de test reproductible pour valider des configurations réseau
- Permettre l'exécution de scénarios d'attaque/défense dans un environnement isolé
- Automatiser le cycle de vie complet (déploiement → audit → destruction)

---

## Architecture

### Topologie réseau

```
┌─────────────────────────────────────────────────────────────┐
│                    Réseau de Management                     │
│                     192.168.56.0/24                        │
└─────────────────────────────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐         ┌────▼────┐        ┌────▼────┐
   │Attaquant│         │   FW    │        │Cible DMZ│
   │ 10.10.  │         │ 10.10.  │        │ 10.10.  │
   │ 10.10   │         │ 10.1    │        │ 20.20   │
   │         │         │ 20.1    │        │         │
   └─────────┘         └────┬────┘        └─────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
   ┌────▼────┐         ┌────▼────┐        ┌────▼────┐
   │   LAN   │         │   DMZ   │        │   DMZ   │
   │10.10.10 │         │10.10.20 │        │10.10.20 │
   │   .0/24 │         │   .0/24 │        │   .0/24 │
   └─────────┘         └─────────┘        └─────────┘
```

### Machines virtuelles

| VM | Rôle | IP Management | IP Réseau | RAM | CPU |
|----|------|---------------|-----------|-----|-----|
| `attaquant` | Contrôleur d'audit | 192.168.56.10 | 10.10.10.10 (LAN) | 2 GB | 2 |
| `fw` | Firewall/Router | 192.168.56.12 | 10.10.10.1 (LAN)<br>10.10.20.1 (DMZ) | 1 GB | 1 |
| `cible_dmz` | Cible d'audit | 192.168.56.20 | 10.10.20.20 (DMZ) | 1 GB | 1 |

### Flux de données

1. **Déploiement** : Vagrant crée les VMs → Ansible configure Docker/réseau → Docker Compose orchestre les conteneurs
2. **Audit** : Conteneurs Nmap scannent les cibles → Rapports XML/TXT générés dans `/opt/audit/reports`
3. **Consolidation** : Script Python parse les XML → Génère rapport HTML/JSON consolidé
4. **Nettoyage** : Ansible supprime conteneurs → Vagrant détruit les VMs

---

## Composants techniques

### 1. Vagrant (`vagrant/Vagrantfile`)

**Rôle:** Définition et création des machines virtuelles

**Configuration:**
- Box Debian Bookworm 64-bit
- 3 VMs avec réseaux privés isolés
- Configuration réseau multi-interface (management + LAN/DMZ)

**Commandes principales:**
```bash
vagrant up          # Créer et démarrer les VMs
vagrant halt        # Arrêter les VMs
vagrant destroy     # Supprimer les VMs
vagrant ssh-config  # Afficher la config SSH pour Ansible
```

### 2. Ansible (`playbooks/`)

**Rôle:** Automatisation du déploiement et de la configuration

**Playbooks principaux:**

| Playbook | Description |
|----------|-------------|
| `10_install_docker.yml` | Installation Docker sur attaquant + cible_dmz |
| `15_config_fw.yml` | Configuration routage + règles nftables |
| `16_routes.yml` | Ajout routes statiques LAN ↔ DMZ |
| `20_deploy_cible_dmz.yml` | Déploiement conteneur nginx en DMZ |
| `25_setup_audit_tools.yml` | Installation outils d'audit |
| `30_scan_nmap.yml` | Exécution scans Nmap (découverte + scan ports) |
| `40_consolidate_reports.yml` | Consolidation rapports via Docker Compose |
| `99_cleanup.yml` | Nettoyage conteneurs et rapports |
| `site.yml` | Playbook principal (orchestre tous les autres) |

**Rôles Ansible:**

- `roles/cible_nginx/` : Déploiement conteneur nginx
- `roles/scan_nmap/` : Configuration et exécution scans Nmap
- `roles/cleanup/` : Nettoyage environnement

**Variables:**

- `group_vars/all/vars.yml` : Variables non sensibles
- `group_vars/all/vault.yml` : Secrets chiffrés (Ansible Vault)

### 3. Docker & Docker Compose

**Rôle:** Isolation et orchestration des outils d'audit

**Fichiers:**

- `docker/docker-compose.audit.yml` : Définition des services d'audit

**Services Docker:**

| Service | Image | Rôle |
|---------|-------|------|
| `nmap_scanner` | `instrumentisto/nmap:latest` | Exécution scans Nmap |
| `report_consolidator` | `python:3.11-slim` | Consolidation rapports |
| `report_viewer` | `nginx:alpine` | Visualisation rapports (optionnel) |

**Volumes:**

- `/opt/audit/reports` : Stockage rapports (persistant)
- `/opt/audit/scripts` : Scripts Python de consolidation

### 4. Scripts Python

**Rôle:** Traitement et consolidation des rapports

**Scripts:**

- `scripts/consolidate_reports.py` : Parse XML Nmap → Génère HTML/JSON consolidé

**Fonctionnalités:**

- Parsing XML Nmap avec `xml.etree.ElementTree`
- Extraction ports ouverts, services détectés
- Génération rapport HTML stylisé
- Export JSON pour traitement ultérieur

### 5. Scripts wrapper

**Rôle:** Interface utilisateur simplifiée

**Scripts:**

- `scripts/run_audit.sh` (Linux/Mac)
- `scripts/run_audit.ps1` (Windows PowerShell)
- `scripts/gen-inventory.ps1` (Génération inventaire Ansible depuis Vagrant)

---

## Installation et configuration

### Prérequis

**Logiciels requis:**

- VirtualBox 6.0+ ou 7.0+
- Vagrant 2.2+
- Ansible 2.9+ (ou 2.14+ recommandé)
- Python 3.8+ (pour scripts de consolidation)
- Git (pour cloner le dépôt)

**Systèmes supportés:**

- Windows 10/11 (avec PowerShell)
- Linux (Debian/Ubuntu recommandé)
- macOS (avec Homebrew)

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

3. **Configurer Ansible Vault (optionnel):**

```bash
# Créer/modifier les secrets
ansible-vault edit group_vars/all/vault.yml

# Mot de passe par défaut: (à définir selon votre politique)
```

4. **Vérifier la configuration:**

```bash
ansible-playbook playbooks/site.yml --check
```

### Configuration réseau

**Modification des IPs:**

Éditer `vagrant/Vagrantfile` pour changer les adresses IP si nécessaire.

**Modification des règles firewall:**

Éditer `playbooks/15_config_fw.yml` (section nftables) pour ajuster les règles.

---

## Utilisation

### Démarrage rapide

**Windows (PowerShell):**

```powershell
.\scripts\run_audit.ps1 all
```

**Linux/Mac:**

```bash
chmod +x scripts/run_audit.sh
./scripts/run_audit.sh all
```

### Commandes détaillées

**1. Déploiement complet:**

```bash
# Windows
.\scripts\run_audit.ps1 deploy

# Linux/Mac
./scripts/run_audit.sh deploy
```

**2. Exécution audit uniquement:**

```bash
ansible-playbook playbooks/30_scan_nmap.yml
```

**3. Consolidation rapports:**

```bash
ansible-playbook playbooks/40_consolidate_reports.yml
```

**4. Nettoyage:**

```bash
ansible-playbook playbooks/99_cleanup.yml
vagrant destroy  # Supprimer les VMs
```

### Accès aux rapports

**Sur la VM attaquant:**

```bash
vagrant ssh attaquant
ls -lh /opt/audit/reports/
cat /opt/audit/reports/audit_consolidated_report.html
```

**Récupération locale (Windows):**

```powershell
vagrant ssh attaquant -- "cat /opt/audit/reports/audit_consolidated_report.html" > rapport.html
```

---

## Maintenance

### Mise à jour des images Docker

```bash
ansible-playbook playbooks/10_install_docker.yml -e "docker_pull_images=yes"
```

### Ajout d'un nouvel outil d'audit

1. Ajouter le service dans `docker/docker-compose.audit.yml`
2. Créer un playbook Ansible pour l'exécuter
3. Mettre à jour `scripts/consolidate_reports.py` si nécessaire

### Modification de la topologie réseau

1. Modifier `vagrant/Vagrantfile`
2. Ajuster `playbooks/15_config_fw.yml` (règles firewall)
3. Mettre à jour `playbooks/16_routes.yml` (routes statiques)
4. Régénérer l'inventaire: `.\scripts\gen-inventory.ps1`

### Logs et débogage

**Logs Ansible:**

```bash
ansible-playbook playbooks/site.yml -v  # Verbose
ansible-playbook playbooks/site.yml -vvv  # Très verbeux
```

**Logs Docker:**

```bash
vagrant ssh attaquant
docker logs nmap_scanner
docker logs report_consolidator
```

**Vérification état:**

```bash
vagrant status
ansible all -m ping
```

---

## Sécurité

### Ansible Vault

**Chiffrement des secrets:**

Les identifiants sensibles sont stockés dans `group_vars/all/vault.yml` (chiffré).

**Commandes Vault:**

```bash
# Éditer les secrets
ansible-vault edit group_vars/all/vault.yml

# Créer un nouveau fichier chiffré
ansible-vault create group_vars/all/vault.yml

# Déchiffrer (pour lecture)
ansible-vault view group_vars/all/vault.yml
```

**Mot de passe Vault:**

Le mot de passe doit être partagé de manière sécurisée avec l'équipe (gestionnaire de mots de passe, etc.).

### Isolation réseau

- Réseaux privés VirtualBox (pas d'accès Internet par défaut)
- Firewall nftables sur le routeur (filtrage strict)
- Conteneurs Docker isolés (network_mode: host uniquement pour Nmap)

### Bonnes pratiques

- Ne jamais commiter les fichiers Vault non chiffrés
- Utiliser des mots de passe forts pour les VMs
- Limiter l'accès au dépôt GitLab/GitHub
- Détruire l'environnement après chaque audit (éphémère)

---

## Dépannage

### Problèmes courants

**1. Erreur "Host key checking failed":**

```bash
# Solution: Désactiver la vérification (déjà fait dans ansible.cfg)
# Ou ajouter les clés SSH manuellement:
ssh-keyscan -H 192.168.56.10 >> ~/.ssh/known_hosts
```

**2. VM ne démarre pas:**

```bash
# Vérifier VirtualBox
VBoxManage list vms
vagrant status
vagrant up --debug
```

**3. Ansible ne peut pas se connecter:**

```bash
# Vérifier l'inventaire
ansible-inventory --list

# Tester la connexion
ansible all -m ping
```

**4. Conteneurs Docker ne démarrent pas:**

```bash
vagrant ssh attaquant
sudo systemctl status docker
docker ps -a
docker logs <container_name>
```

**5. Rapports non générés:**

```bash
# Vérifier les permissions
vagrant ssh attaquant
ls -la /opt/audit/reports/
sudo chown -R vagrant:vagrant /opt/audit/
```

### Support

Pour toute question ou problème, consulter:
- La documentation Ansible: https://docs.ansible.com/
- La documentation Docker: https://docs.docker.com/
- Les logs détaillés avec `-vvv`

---

## Évolutions futures

- [ ] Intégration d'autres outils d'audit (Nikto, SQLMap, etc.)
- [ ] Interface web pour visualisation des rapports
- [ ] Support de plusieurs scénarios d'audit prédéfinis
- [ ] Intégration CI/CD (GitLab CI)
- [ ] Export des rapports vers formats standards (PDF, JSON API)

---

**Fin de la documentation technique**
