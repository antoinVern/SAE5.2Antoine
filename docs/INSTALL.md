# Installation — Plateforme d’Audit (SAÉ 5.02)

Ce document explique comment **installer et lancer** rapidement la plateforme.

> Limite importante : la création des VMs **VirtualBox** ne peut pas se faire “depuis un lien web” sans installation locale.  
> En revanche, on peut proposer une installation **très simple** : *Download ZIP → double-clic `INSTALL.bat` → double-clic `LAUNCH.bat`*.

---

## Pré-requis

- **Windows 10/11** recommandé pour le “one-click”
- **VirtualBox** (obligatoire)
- **Vagrant** (obligatoire)
- **Ansible** (obligatoire)  
  - Recommandé via **WSL** ou un environnement Python (selon ton setup)
- **Git** (optionnel si tu utilises “Download ZIP”)

---

## Installation (Windows) — méthode la plus simple

### Option A — “Download ZIP” (sans Git)

1. Sur GitHub, clique sur **Code** → **Download ZIP** sur le repo  
   `https://github.com/antoinVern/SAE5.2Antoine`
2. Dézippe
3. Double-clique:
   - `INSTALL.bat`
   - puis `LAUNCH.bat`

### Option B — Git (recommandé)

```powershell
git clone https://github.com/antoinVern/SAE5.2Antoine.git
cd SAE5.2Antoine
.\INSTALL.bat
.\LAUNCH.bat
```

---

## Lancement rapide (PowerShell)

Si tu préfères ne pas utiliser les `.bat` :

```powershell
.\scripts\install-complete.ps1
.\scripts\run_audit.ps1 all
```

---

## Où sont les rapports ?

Dans la VM `attaquant` :

```powershell
cd vagrant
vagrant ssh attaquant
ls -lh /opt/audit/reports/
cat /opt/audit/reports/audit_consolidated_report.html
```

Récupération sur Windows :

```powershell
vagrant ssh attaquant -- "cat /opt/audit/reports/audit_consolidated_report.html" > rapport.html
start rapport.html
```

---

## Nettoyage / Destruction

- Nettoyage conteneurs/rapports + arrêt VMs :

```powershell
.\scripts\run_audit.ps1 cleanup
```

- Destruction complète des VMs :

```powershell
cd vagrant
vagrant destroy
```

