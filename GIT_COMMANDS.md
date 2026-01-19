# 📦 Commandes Git pour GitHub

## Initialisation du dépôt (première fois)

```bash
# Initialiser le dépôt Git
git init

# Ajouter tous les fichiers
git add .

# Faire le premier commit
git commit -m "Initial commit: Laboratoire éphémère SAE5.2 avec Docker et Ansible"

# Ajouter le remote GitHub (remplacez <votre-username> et <nom-du-repo>)
git remote add origin https://github.com/<votre-username>/<nom-du-repo>.git

# Renommer la branche principale en main (si nécessaire)
git branch -M main

# Pousser sur GitHub
git push -u origin main
```

## Commandes courantes

```bash
# Voir le statut des fichiers
git status

# Ajouter des fichiers modifiés
git add .

# Ou ajouter des fichiers spécifiques
git add fichier1.txt fichier2.txt

# Faire un commit
git commit -m "Description des modifications"

# Pousser les modifications
git push

# Récupérer les dernières modifications
git pull

# Voir l'historique des commits
git log

# Voir les différences
git diff
```

## Si vous avez déjà un dépôt GitHub

```bash
# Cloner le dépôt existant
git clone https://github.com/<votre-username>/<nom-du-repo>.git

# Aller dans le dossier
cd <nom-du-repo>

# Copier vos fichiers dans ce dossier, puis:
git add .
git commit -m "Ajout du laboratoire éphémère"
git push
```

## Créer un dépôt sur GitHub (via navigateur)

1. Aller sur https://github.com
2. Cliquer sur le bouton "+" en haut à droite
3. Sélectionner "New repository"
4. Donner un nom (ex: "SAE5.2-Laboratoire-Ephemere")
5. Choisir Public ou Private
6. **NE PAS** cocher "Initialize with README" (vous avez déjà un README)
7. Cliquer sur "Create repository"
8. Suivre les instructions affichées ou utiliser les commandes ci-dessus

## Commandes complètes (copier-coller)

```bash
# 1. Initialiser Git
git init

# 2. Ajouter tous les fichiers
git add .

# 3. Premier commit
git commit -m "Initial commit: Laboratoire éphémère SAE5.2"

# 4. Ajouter le remote (REMPLACEZ par votre URL GitHub)
git remote add origin https://github.com/VOTRE-USERNAME/VOTRE-REPO.git

# 5. Pousser sur GitHub
git push -u origin main
```

## Si vous avez des erreurs

### Erreur: "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/VOTRE-USERNAME/VOTRE-REPO.git
```

### Erreur: "failed to push"
```bash
# Vérifier que vous êtes connecté à GitHub
git remote -v

# Si besoin, mettre à jour l'URL
git remote set-url origin https://github.com/VOTRE-USERNAME/VOTRE-REPO.git
```

### Erreur: "branch main does not exist"
```bash
# Créer la branche main
git checkout -b main
git push -u origin main
```
