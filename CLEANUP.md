# 🧹 Guide de Nettoyage Git

Ce guide explique comment nettoyer votre dépôt Git pour le rendre plus propre.

## Nettoyage automatique

### Windows (PowerShell)

```powershell
.\scripts\cleanup-git.ps1
```

Ce script va :
- ✅ Supprimer les fichiers ignorés du cache Git
- ✅ Supprimer les fichiers `.bak`, `.tmp`
- ✅ Supprimer les dossiers `__pycache__`
- ✅ Afficher l'état du dépôt

## Nettoyage manuel

### 1. Supprimer les fichiers ignorés du cache Git

```bash
git rm -r --cached .
git add .
```

### 2. Supprimer les fichiers de backup

```powershell
# Windows
Get-ChildItem -Path . -Filter "*.bak" -Recurse | Remove-Item -Force

# Linux/Mac
find . -name "*.bak" -type f -delete
```

### 3. Vérifier l'état

```bash
git status
```

### 4. Commiter les changements

```bash
git add .
git commit -m "Nettoyage du dépôt Git"
```

## Fichiers à ne JAMAIS versionner

- ❌ Fichiers `.bak`, `.backup`, `.old`
- ❌ Fichiers de mots de passe (`.vault_pass`, `vault_pass.txt`)
- ❌ Dossiers `.vagrant/`
- ❌ Rapports générés (`*.xml`, `*.html`, `scan_*.txt`)
- ❌ Fichiers temporaires (`*.tmp`, `*.cache`)
- ❌ Dossiers Python (`__pycache__/`, `venv/`)

## Vérification

Après nettoyage, votre dépôt devrait contenir uniquement :

- ✅ Code source (`.yml`, `.py`, `.sh`, `.ps1`)
- ✅ Configuration (`.gitignore`, `.gitattributes`, `.editorconfig`)
- ✅ Documentation (`.md`, `.txt`)
- ✅ Scripts d'installation (`INSTALL.bat`, `LAUNCH.bat`)

---

**Note :** Le fichier `.gitignore` est configuré pour ignorer automatiquement tous les fichiers temporaires et générés.
