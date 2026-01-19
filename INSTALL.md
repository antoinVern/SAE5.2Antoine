# 📖 Guide d'Installation Détaillé

## Pour les Utilisateurs Non-Techniques

### Étape 1: Installer Docker

#### Sur Windows:
1. Téléchargez Docker Desktop depuis: https://www.docker.com/products/docker-desktop
2. Installez Docker Desktop
3. Redémarrez votre ordinateur
4. Lancez Docker Desktop et attendez qu'il soit démarré (icône Docker dans la barre des tâches)

#### Sur Linux:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### Sur Mac:
1. Téléchargez Docker Desktop depuis: https://www.docker.com/products/docker-desktop
2. Installez Docker Desktop
3. Lancez Docker Desktop

### Étape 2: Cloner ou Télécharger le Projet

**Option A - Avec Git:**
```bash
git clone <url-du-repo>
cd SAE5.2Antoine
```

**Option B - Sans Git:**
1. Téléchargez le projet en ZIP depuis GitHub
2. Extrayez le fichier ZIP
3. Ouvrez un terminal dans le dossier extrait

### Étape 3: Construire le Laboratoire

**Sur Windows (Git Bash ou PowerShell):**
```bash
bash build.sh
```

**Sur Linux/Mac:**
```bash
./build.sh
```

### Étape 4: Utiliser le Laboratoire

1. Ouvrez votre navigateur
2. Allez à: http://localhost
3. Utilisez les boutons pour contrôler le laboratoire

### Étape 5: Détruire le Laboratoire

**Quand vous avez terminé:**
```bash
bash destroy.sh
```

Ou utilisez le bouton "Détruire" dans l'interface web.

## ⚠️ Problèmes Courants

### "Docker n'est pas installé"
- Installez Docker Desktop (voir Étape 1)

### "Permission denied" sur Linux
```bash
sudo chmod +x build.sh destroy.sh
```

### Les ports sont déjà utilisés
- Arrêtez les autres applications utilisant les ports 80, 5000, 5001, 5002, 8080, 3306
- Ou modifiez les ports dans `docker-compose.yml`

### Le scanner réseau ne fonctionne pas
- Sur Windows, le mode `host` réseau peut ne pas fonctionner
- Le scanner fonctionnera toujours mais avec des limitations

## 🔍 Vérification

Pour vérifier que tout fonctionne:
```bash
docker-compose ps
```

Tous les conteneurs doivent être "Up".
