# 🚀 Démarrage Rapide - Debian

## Installation complète en 5 minutes

### 1. Installer Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Vérifier l'installation

```bash
docker --version
docker ps
```

### 3. Cloner et lancer le projet

```bash
git clone <url-du-repo>
cd SAE5.2Antoine
chmod +x build.sh destroy.sh test.sh
./build.sh
```

### 4. Accéder à l'interface

Ouvrez **http://localhost** dans votre navigateur.

### 5. Tester l'environnement (optionnel)

```bash
./test.sh
```

## Commandes essentielles

```bash
# Construire
./build.sh

# Détruire
./destroy.sh

# Voir les logs
docker-compose logs -f

# Voir l'état
docker-compose ps

# Redémarrer
docker-compose restart
```

## Dépannage rapide

### Erreur de permissions Docker
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Ports déjà utilisés
```bash
# Voir ce qui utilise les ports
sudo netstat -tulpn | grep -E ':(80|5000|5001|5002|8080|3306)'
```

### Réinitialiser complètement
```bash
./destroy.sh
docker system prune -a --volumes
./build.sh
```
