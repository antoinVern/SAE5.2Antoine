#!/bin/bash
# Script de construction du laboratoire éphémère
# Compatible Docker Compose v2 (docker compose) et v1 (docker-compose)
# Optimisé pour Linux/Debian

set -e

echo "🔨 Construction du laboratoire éphémère..."

# Vérifier que nous sommes sur Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ Ce script est conçu pour Linux uniquement."
    echo "   Système détecté: $OSTYPE"
    exit 1
fi

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé."
    echo "   Installez-le avec:"
    echo "   curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    exit 1
fi

# Vérifier Docker Compose (v2 ou v1)
if docker compose version &> /dev/null; then
    COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    COMPOSE="docker-compose"
else
    echo "❌ Docker Compose n'est pas installé."
    echo "   Installez-le avec:"
    echo "   sudo apt install docker-compose-plugin"
    exit 1
fi

echo "✅ Docker Compose détecté : $COMPOSE"

# Vérifier les permissions Docker
if ! docker ps &> /dev/null; then
    echo "⚠️  Vous n'avez pas les permissions pour utiliser Docker."
    echo "   Exécutez:"
    echo "   sudo usermod -aG docker \$USER"
    echo "   newgrp docker"
    exit 1
fi

# Nettoyer les anciennes instances
echo "🧹 Nettoyage des anciennes instances..."
$COMPOSE down -v 2>/dev/null || true

# Construire et démarrer les conteneurs
echo "🐳 Démarrage des conteneurs..."
$COMPOSE up -d --build

# Attendre que les conteneurs soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 15

# Exécuter les playbooks Ansible
echo "📋 Configuration avec Ansible..."
docker exec lab-ansible-control /scripts/run_ansible.sh || {
    echo "⚠️  Erreur lors de l'exécution d'Ansible."
    echo "   Consultez les logs avec:"
    echo "   $COMPOSE logs ansible-control"
}

# Afficher les informations
echo ""
echo "✅ Laboratoire construit avec succès !"
echo ""
echo "📊 Informations du laboratoire :"
echo "   - Interface Web : http://localhost"
echo "   - API Scanner  : http://localhost:5001/api/discover"
echo "   - Serveur Web  : http://localhost:8080"
echo "   - API          : http://localhost:5000"
echo ""
echo "🧨 Pour détruire le laboratoire : ./destroy.sh"
