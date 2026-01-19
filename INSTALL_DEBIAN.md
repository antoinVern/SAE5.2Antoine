# 📦 Installation sur Debian

Guide d'installation complet pour Debian.

## Étape 1: Mettre à jour le système

```bash
sudo apt update
sudo apt upgrade -y
```

## Étape 2: Installer les dépendances

```bash
sudo apt install -y \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    lsb-release
```

## Étape 3: Installer Docker

```bash
# Ajouter la clé GPG officielle de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Ajouter le dépôt Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installer Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Étape 4: Installer Docker Compose (si nécessaire)

Si Docker Compose n'est pas installé avec Docker:

```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Étape 5: Configurer les permissions Docker

```bash
# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER

# Redémarrer la session (ou se déconnecter/reconnecter)
newgrp docker

# Vérifier l'installation
docker --version
docker-compose --version
```

## Étape 6: Cloner le projet

```bash
git clone <url-du-repo>
cd SAE5.2Antoine
```

## Étape 7: Rendre les scripts exécutables

```bash
chmod +x build.sh destroy.sh
chmod +x scripts/*.sh
chmod +x scripts/*.py
```

## Étape 8: Construire le laboratoire

```bash
./build.sh
```

## Étape 9: Vérifier que tout fonctionne

```bash
# Voir les conteneurs en cours d'exécution
docker-compose ps

# Voir les logs
docker-compose logs -f
```

## 🎉 C'est prêt !

Ouvrez votre navigateur à **http://localhost** pour accéder à l'interface web.

## 🔧 Dépannage

### Erreur: "Permission denied" avec Docker

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Erreur: "docker-compose: command not found"

```bash
# Utiliser docker compose (sans tiret) si Docker Compose v2 est installé
docker compose up -d
```

### Les ports sont déjà utilisés

```bash
# Vérifier quels processus utilisent les ports
sudo netstat -tulpn | grep -E ':(80|5000|5001|5002|8080|3306)'

# Arrêter les services qui utilisent ces ports
sudo systemctl stop apache2  # Si Apache utilise le port 80
sudo systemctl stop nginx    # Si Nginx utilise le port 80
```
