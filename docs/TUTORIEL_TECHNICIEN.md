# Tutoriel Technicien - Plateforme d'Audit de Sécurité Réseau

**Projet:** SAÉ 5.02 - Piloter un projet informatique  
**Public:** Techniciens repreneurs du projet  
**Date:** Novembre 2025  
**Version:** 1.0

---

## 🎯 Objectif de ce tutoriel

Ce tutoriel vous guide pas à pas pour **prendre en main** et **utiliser** la plateforme d'audit de sécurité réseau. À la fin, vous serez capable de :

- ✅ Déployer l'environnement complet
- ✅ Exécuter des audits de sécurité
- ✅ Consulter et interpréter les rapports
- ✅ Nettoyer l'environnement après utilisation

**Temps estimé:** 30-45 minutes

---

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :

- [ ] VirtualBox installé et fonctionnel
- [ ] Vagrant installé
- [ ] Ansible installé (version 2.9+)
- [ ] Au moins 8 GB de RAM libre
- [ ] 20 GB d'espace disque libre
- [ ] Accès au dépôt GitLab/GitHub du projet

---

## 🚀 Étape 1 : Préparation de l'environnement

> **📍 Où taper les commandes ?**  
> Ouvrez **PowerShell** dans le dossier `C:\Users\antoi\Documents\SAE5.2Antoine`  
> (Clic droit → "Ouvrir PowerShell ici" ou depuis VS Code/Cursor : **Ctrl + ù**)

### 1.1 Cloner le dépôt (si pas déjà fait)

```bash
git clone <url-du-depot>
cd SAE5.2Antoine
```

**Ou si vous avez déjà le projet :**

```powershell
# Vérifier que vous êtes au bon endroit
cd C:\Users\antoi\Documents\SAE5.2Antoine
pwd  # Devrait afficher le chemin complet
```

### 1.2 Installer les dépendances Ansible

```powershell
# Depuis C:\Users\antoi\Documents\SAE5.2Antoine
ansible-galaxy collection install -r collections/requirements.yml
```

**Vérification:**

```bash
ansible-galaxy collection list
```

Vous devriez voir `community.docker` et `ansible.posix` dans la liste.

### 1.3 Vérifier les prérequis

**Windows (PowerShell):**

```powershell
vagrant --version
ansible --version
```

**Linux/Mac:**

```bash
vagrant --version
ansible --version
```

---

## 🏗️ Étape 2 : Premier déploiement

### 2.1 Démarrer les machines virtuelles

**📍 Depuis PowerShell dans `C:\Users\antoi\Documents\SAE5.2Antoine` :**

```powershell
cd vagrant
vagrant up
```

**Ou depuis le dossier racine :**

```powershell
# Depuis SAE5.2Antoine/
vagrant up  # Vagrant trouve automatiquement le Vagrantfile
```

**Ce qui se passe:**

- Vagrant télécharge la box Debian (première fois uniquement)
- Crée 3 machines virtuelles (attaquant, fw, cible_dmz)
- Configure les réseaux virtuels
- Démarre les VMs

**⏱️ Temps estimé:** 5-10 minutes (première fois)

### 2.2 Générer l'inventaire Ansible

**📍 Depuis PowerShell dans `C:\Users\antoi\Documents\SAE5.2Antoine` :**

```powershell
# Si vous êtes dans vagrant/, revenir au dossier principal
cd ..

# Générer l'inventaire
.\scripts\gen-inventory.ps1
```

**💡 Astuce :** Si vous êtes déjà dans `SAE5.2Antoine`, pas besoin de `cd ..`

**Linux/Mac:**

L'inventaire est généralement généré automatiquement, sinon :

```bash
cd ..
vagrant ssh-config > inventory/ssh_config
# Puis adapter inventory/hosts.ini manuellement
```

**Vérification:**

```bash
ansible-inventory --list
```

Vous devriez voir les 3 VMs listées.

### 2.3 Tester la connexion

```bash
ansible all -m ping
```

**Résultat attendu:**

```
attaquant | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
fw | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
cible_dmz | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

---

## 🔧 Étape 3 : Déploiement complet

### 3.1 Lancer le playbook principal

**📍 Depuis PowerShell dans `C:\Users\antoi\Documents\SAE5.2Antoine` :**

**Option A - Script wrapper (recommandé):**

```powershell
.\scripts\run_audit.ps1 deploy
```

**Linux/Mac:**

```bash
chmod +x scripts/run_audit.sh
./scripts/run_audit.sh deploy
```

**Option B - Ansible directement:**

```powershell
# Depuis C:\Users\antoi\Documents\SAE5.2Antoine
ansible-playbook playbooks/site.yml
```

### 3.2 Ce qui se déploie

Le playbook `site.yml` exécute dans l'ordre :

1. ✅ Installation Docker sur `attaquant` et `cible_dmz`
2. ✅ Configuration firewall (`fw`) avec règles nftables
3. ✅ Configuration routes statiques LAN ↔ DMZ
4. ✅ Déploiement conteneur nginx en DMZ
5. ✅ Installation outils d'audit
6. ✅ Exécution scans Nmap
7. ✅ Consolidation des rapports

**⏱️ Temps estimé:** 5-10 minutes

### 3.3 Vérifier le déploiement

**Vérifier les conteneurs Docker:**

```bash
vagrant ssh attaquant
docker ps
```

Vous devriez voir des conteneurs Nmap.

**Vérifier le service nginx:**

```bash
vagrant ssh cible_dmz
docker ps
curl http://localhost:80
```

---

## 🔍 Étape 4 : Exécution d'un audit

### 4.1 Lancer un audit complet

**📍 Depuis PowerShell dans `C:\Users\antoi\Documents\SAE5.2Antoine` :**

**Script wrapper (recommandé):**

```powershell
.\scripts\run_audit.ps1 audit
```

**Ou directement avec Ansible:**

```powershell
ansible-playbook playbooks/30_scan_nmap.yml
```

### 4.2 Ce qui se passe

1. **Découverte des hôtes** : Scan ping des réseaux LAN et DMZ
2. **Scan des ports** : Scan SYN des ports 22, 80, 443, 8080 sur chaque cible
3. **Génération des rapports** : Fichiers XML et TXT dans `/opt/audit/reports`

### 4.3 Consulter les rapports bruts

```bash
vagrant ssh attaquant
ls -lh /opt/audit/reports/
cat /opt/audit/reports/scan_10.10.20.20.txt
```

---

## 📊 Étape 5 : Consolidation des rapports

### 5.1 Générer le rapport consolidé

**📍 Depuis PowerShell dans `C:\Users\antoi\Documents\SAE5.2Antoine` :**

**Via script (recommandé):**

```powershell
.\scripts\run_audit.ps1 consolidate
```

**Ou directement avec Ansible:**

```powershell
ansible-playbook playbooks/40_consolidate_reports.yml
```

### 5.2 Consulter le rapport HTML

**Sur la VM:**

```bash
vagrant ssh attaquant
cat /opt/audit/reports/audit_consolidated_report.html
```

**Récupérer localement (Windows):**

```powershell
vagrant ssh attaquant -- "cat /opt/audit/reports/audit_consolidated_report.html" > rapport.html
start rapport.html
```

**Linux/Mac:**

```bash
vagrant ssh attaquant -- "cat /opt/audit/reports/audit_consolidated_report.html" > rapport.html
open rapport.html  # Mac
xdg-open rapport.html  # Linux
```

### 5.3 Interpréter le rapport

Le rapport HTML contient :

- **Résumé exécutif** : Nombre d'hôtes scannés, ports ouverts, services détectés
- **Détails par cible** : Pour chaque IP, liste des ports ouverts et services

**Exemple d'interprétation:**

```
Cible: 10.10.20.20
- Port 80/TCP ouvert → Service: http (nginx)
- Port 443/TCP ouvert → Service: https
```

---

## 🧹 Étape 6 : Nettoyage

### 6.1 Nettoyer l'environnement

**Script wrapper:**

```powershell
.\scripts\run_audit.ps1 cleanup
```

**Ou manuellement:**

```bash
# Nettoyer conteneurs et rapports
ansible-playbook playbooks/99_cleanup.yml

# Arrêter les VMs
cd vagrant
vagrant halt
```

### 6.2 Destruction complète (optionnel)

**⚠️ Attention:** Cela supprime définitivement les VMs.

```bash
cd vagrant
vagrant destroy
```

---

## 🎓 Scénarios d'utilisation

### Scénario 1 : Audit complet en une commande

**📍 Depuis PowerShell dans `C:\Users\antoi\Documents\SAE5.2Antoine` :**

```powershell
.\scripts\run_audit.ps1 all
```

Cette commande exécute : déploiement → audit → consolidation.

### Scénario 2 : Audit rapide (infrastructure déjà déployée)

**📍 Depuis PowerShell dans `C:\Users\antoi\Documents\SAE5.2Antoine` :**

```powershell
ansible-playbook playbooks/30_scan_nmap.yml
ansible-playbook playbooks/40_consolidate_reports.yml
```

### Scénario 3 : Test d'une configuration firewall spécifique

**📍 Depuis PowerShell dans `C:\Users\antoi\Documents\SAE5.2Antoine` :**

1. Modifier `playbooks/15_config_fw.yml` (règles nftables)
2. Redéployer : `ansible-playbook playbooks/15_config_fw.yml`
3. Relancer l'audit : `ansible-playbook playbooks/30_scan_nmap.yml`
4. Comparer les rapports avant/après

---

## ❓ Questions fréquentes (FAQ)

### Q1 : Les VMs ne démarrent pas

**Vérifications:**

1. VirtualBox est-il démarré ?
2. Y a-t-il assez de RAM disponible ?
3. Les ports réseau sont-ils libres ?

**Solution:**

```bash
vagrant up --debug  # Mode debug
VBoxManage list runningvms  # Vérifier VMs actives
```

### Q2 : Ansible ne peut pas se connecter aux VMs

**Vérifications:**

1. Les VMs sont-elles démarrées ? (`vagrant status`)
2. L'inventaire est-il correct ? (`ansible-inventory --list`)
3. Les clés SSH sont-elles correctes ?

**Solution:**

```bash
# Régénérer l'inventaire
.\scripts\gen-inventory.ps1

# Tester la connexion manuelle
vagrant ssh attaquant
```

### Q3 : Les scans Nmap ne trouvent rien

**Vérifications:**

1. Le firewall bloque-t-il les scans ?
2. Les routes sont-elles correctes ?
3. Les services sont-ils démarrés ?

**Solution:**

```bash
# Vérifier les routes
vagrant ssh attaquant
ip route

# Tester la connectivité
ping 10.10.20.20
curl http://10.10.20.20
```

### Q4 : Le rapport consolidé est vide

**Vérifications:**

1. Les scans ont-ils généré des fichiers XML ?
2. Les permissions sont-elles correctes ?

**Solution:**

```bash
vagrant ssh attaquant
ls -la /opt/audit/reports/*.xml
sudo chown -R vagrant:vagrant /opt/audit/
```

---

## 📚 Ressources complémentaires

### Documentation

- **Documentation technique complète** : `docs/DOCUMENTATION_TECHNIQUE.md`
- **Cahier des charges** : `CDC SAE5.2.pdf`

### Commandes utiles

**Vagrant:**

```bash
vagrant status          # État des VMs
vagrant ssh <vm_name>   # Se connecter à une VM
vagrant reload          # Redémarrer les VMs
vagrant suspend         # Suspendre les VMs
```

**Ansible:**

```bash
ansible all -m ping                    # Tester connexion
ansible-playbook playbook.yml -v      # Mode verbose
ansible-playbook playbook.yml --check # Mode dry-run
```

**Docker:**

```bash
docker ps                    # Conteneurs actifs
docker logs <container>      # Logs d'un conteneur
docker exec -it <container> sh  # Shell dans conteneur
```

---

## ✅ Checklist de prise en main

- [ ] Environnement préparé (VirtualBox, Vagrant, Ansible)
- [ ] Dépôt cloné et dépendances installées
- [ ] Premier déploiement réussi
- [ ] Audit exécuté avec succès
- [ ] Rapport consolidé généré et consulté
- [ ] Nettoyage effectué
- [ ] Documentation technique lue

---

## 🆘 Support

En cas de problème :

1. Consulter la section **Dépannage** de la documentation technique
2. Vérifier les logs avec `-vvv` (mode très verbeux)
3. Contacter l'équipe projet ou le responsable technique

---

**Fin du tutoriel**

**Bon courage pour la prise en main ! 🚀**
