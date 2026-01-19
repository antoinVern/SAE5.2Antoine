# 🚀 Guide de Démarrage Rapide - Où taper les commandes ?

## 📍 Sur Windows (PowerShell)

### Étape 1 : Ouvrir PowerShell

**Méthode 1 - Depuis l'Explorateur de fichiers :**
1. Ouvrez l'**Explorateur de fichiers Windows**
2. Naviguez vers : `C:\Users\antoi\Documents\SAE5.2Antoine`
3. **Clic droit** dans le dossier → **"Ouvrir dans le terminal"** ou **"Ouvrir PowerShell ici"**

**Méthode 2 - Depuis le menu Démarrer :**
1. Appuyez sur **Windows + X**
2. Sélectionnez **"Windows PowerShell"** ou **"Terminal"**
3. Naviguez vers le dossier :
   ```powershell
   cd C:\Users\antoi\Documents\SAE5.2Antoine
   ```

**Méthode 3 - Depuis VS Code/Cursor :**
1. Ouvrez le dossier `SAE5.2Antoine` dans votre éditeur
2. Appuyez sur **Ctrl + ù** (ou **Ctrl + `**) pour ouvrir le terminal intégré
3. Le terminal s'ouvre directement dans le bon dossier !

### Étape 2 : Vérifier que vous êtes au bon endroit

Dans PowerShell, vous devriez voir quelque chose comme :

```
PS C:\Users\antoi\Documents\SAE5.2Antoine>
```

**Si vous n'êtes pas au bon endroit**, tapez :

```powershell
cd C:\Users\antoi\Documents\SAE5.2Antoine
```

### Étape 3 : Vérifier la structure du projet

```powershell
ls
```

Vous devriez voir :
- `vagrant/`
- `playbooks/`
- `scripts/`
- `docker/`
- `docs/`
- etc.

---

## 🎯 Commandes principales et où les exécuter

### ✅ Toutes ces commandes se tapent dans PowerShell, depuis le dossier `SAE5.2Antoine`

#### 1. Installation des dépendances Ansible

```powershell
# Vous êtes ici : C:\Users\antoi\Documents\SAE5.2Antoine
ansible-galaxy collection install -r collections/requirements.yml
```

#### 2. Démarrage des VMs

```powershell
# Vous êtes ici : C:\Users\antoi\Documents\SAE5.2Antoine
cd vagrant
vagrant up
```

#### 3. Génération de l'inventaire

```powershell
# Vous êtes ici : C:\Users\antoi\Documents\SAE5.2Antoine\vagrant
cd ..
.\scripts\gen-inventory.ps1
```

#### 4. Scénario complet (RECOMMANDÉ)

```powershell
# Vous êtes ici : C:\Users\antoi\Documents\SAE5.2Antoine
.\scripts\run_audit.ps1 all
```

#### 5. Commandes Ansible individuelles

```powershell
# Vous êtes ici : C:\Users\antoi\Documents\SAE5.2Antoine
ansible-playbook playbooks/site.yml
ansible-playbook playbooks/30_scan_nmap.yml
ansible-playbook playbooks/99_cleanup.yml
```

---

## 📂 Structure des dossiers et commandes

```
SAE5.2Antoine/                    ← VOUS ÊTES ICI pour la plupart des commandes
│
├── scripts/
│   ├── run_audit.ps1            ← Exécuter depuis SAE5.2Antoine/
│   └── gen-inventory.ps1        ← Exécuter depuis SAE5.2Antoine/
│
├── playbooks/
│   └── site.yml                 ← Exécuter depuis SAE5.2Antoine/
│
└── vagrant/
    └── Vagrantfile              ← Exécuter depuis vagrant/ OU SAE5.2Antoine/
```

---

## 🔍 Exemples concrets

### Exemple 1 : Premier lancement complet

```powershell
# 1. Ouvrir PowerShell dans C:\Users\antoi\Documents\SAE5.2Antoine

# 2. Vérifier que vous êtes au bon endroit
pwd
# Devrait afficher : C:\Users\antoi\Documents\SAE5.2Antoine

# 3. Lancer tout en une commande
.\scripts\run_audit.ps1 all
```

### Exemple 2 : Déploiement manuel étape par étape

```powershell
# 1. Depuis SAE5.2Antoine/
cd vagrant
vagrant up

# 2. Retour au dossier principal
cd ..

# 3. Générer l'inventaire
.\scripts\gen-inventory.ps1

# 4. Lancer le déploiement
ansible-playbook playbooks/site.yml
```

### Exemple 3 : Se connecter à une VM

```powershell
# Depuis SAE5.2Antoine/
cd vagrant
vagrant ssh attaquant
# Vous êtes maintenant DANS la VM Linux !
# Pour sortir : tapez "exit"
```

---

## ⚠️ Erreurs courantes

### ❌ Erreur : "Le terme 'vagrant' n'est pas reconnu"

**Cause :** Vagrant n'est pas dans le PATH ou pas installé.

**Solution :**
1. Vérifier l'installation : `vagrant --version`
2. Si non installé, télécharger depuis https://www.vagrantup.com/

### ❌ Erreur : "Cannot find path '.\scripts\run_audit.ps1'"

**Cause :** Vous n'êtes pas dans le bon dossier.

**Solution :**
```powershell
cd C:\Users\antoi\Documents\SAE5.2Antoine
pwd  # Vérifier
ls scripts  # Devrait lister les fichiers .ps1
```

### ❌ Erreur : "ansible-playbook : commande introuvable"

**Cause :** Ansible n'est pas installé ou pas dans le PATH.

**Solution :**
- Windows : Installer Ansible via WSL ou utiliser une VM Linux
- Ou utiliser Docker avec Ansible

---

## 💡 Astuce : Terminal intégré VS Code/Cursor

**Le plus simple :** Utiliser le terminal intégré de votre éditeur !

1. Ouvrez le dossier `SAE5.2Antoine` dans VS Code/Cursor
2. Appuyez sur **Ctrl + ù** (ou **Ctrl + `**)
3. Le terminal s'ouvre directement dans le bon dossier
4. Tapez vos commandes directement

---

## 📝 Résumé visuel

```
┌─────────────────────────────────────────┐
│  PowerShell ouvert ICI                  │
│  C:\Users\antoi\Documents\SAE5.2Antoine│
└─────────────────────────────────────────┘
                    │
        ┌───────────┼───────────┐
        │           │           │
   ┌────▼────┐ ┌────▼────┐ ┌────▼────┐
   │vagrant/ │ │scripts/ │ │playbooks│
   │         │ │         │ │         │
   │vagrant  │ │run_audit│ │site.yml │
   │  up     │ │  .ps1   │ │         │
   └─────────┘ └─────────┘ └─────────┘
```

**Toutes les commandes principales se lancent depuis le dossier racine `SAE5.2Antoine` !**

---

**Besoin d'aide ?** Consultez le [Tutoriel Technicien](TUTORIEL_TECHNICIEN.md) pour plus de détails.
