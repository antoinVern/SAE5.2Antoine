# ⚡ Quick Start - Démarrage en 30 secondes

## 🚀 Méthode ONE-CLICK (Windows)

### Installation + Lancement en 2 clics

1. **Double-cliquez sur `INSTALL.bat`** → Installation automatique
2. **Double-cliquez sur `LAUNCH.bat`** → Lancement de l'environnement d'audit

**C'est tout !** 🎉

---

## 📝 Méthode Ligne de Commande (Windows)

```powershell
# 1. Cloner
git clone https://github.com/antoinVern/SAE5.2Antoine.git
cd SAE5.2Antoine

# 2. Installation automatique complète
.\scripts\install-complete.ps1

# 3. Lancer !
.\scripts\run_audit.ps1 all
```

---

## 🐧 Linux/Mac

```bash
git clone https://github.com/antoinVern/SAE5.2Antoine.git
cd SAE5.2Antoine
ansible-galaxy collection install -r collections/requirements.yml
chmod +x scripts/run_audit.sh
./scripts/run_audit.sh all
```

---

## ☁️ GitHub Codespaces (Cloud)

1. Cliquez sur **"Code"** → **"Codespaces"** → **"Create codespace"**
2. Attendez la configuration automatique
3. Lancez : `./scripts/run_audit.sh all`

> **Note :** VirtualBox ne fonctionne pas dans Codespaces. Utilisez votre machine locale.

---

## 📋 Prérequis

- VirtualBox ([Télécharger](https://www.virtualbox.org/wiki/Downloads))
- Vagrant ([Télécharger](https://www.vagrantup.com/downloads))
- Ansible ([Installation](https://docs.ansible.com/ansible/latest/installation_guide/index.html))

**Le script d'installation vérifie automatiquement ces prérequis !**

---

## 📊 Consulter les rapports

```powershell
vagrant ssh attaquant
cat /opt/audit/reports/audit_consolidated_report.html
```

**Ou récupérer sur Windows :**

```powershell
vagrant ssh attaquant -- "cat /opt/audit/reports/audit_consolidated_report.html" > rapport.html
start rapport.html
```

---

**Besoin d'aide ?** Consultez le [README.md](README.md) ou la [Documentation](docs/)
