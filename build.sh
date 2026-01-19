#!/bin/bash
# Script de construction du laboratoire éphémère
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
    echo "   Installez-le avec: curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh"
    exit 1
fi

# Vérifier Docker Compose (v2 ou v1)
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé."
    echo "   Installez-le avec Docker ou séparément."
    exit 1
fi

# Vérifier les permissions Docker
if ! docker ps &> /dev/null; then
    echo "⚠️  Vous n'avez pas les permissions pour utiliser Docker."
    echo "   Ajoutez votre utilisateur au groupe docker:"
    echo "   sudo usermod -aG docker \$USER"
    echo "   newgrp docker"
    exit 1
fi

# Nettoyer les anciennes instances
echo "🧹 Nettoyage des anciennes instances..."
docker-compose down -v 2>/dev/null || true

# Construire et démarrer les conteneurs
echo "🐳 Démarrage des conteneurs..."
docker-compose up -d

# Attendre que les conteneurs soient prêts
echo "⏳ Attente du démarrage des services..."
sleep 15

# Exécuter les playbooks Ansible
echo "📋 Configuration avec Ansible..."
docker exec lab-ansible-control /scripts/run_ansible.sh || {
    echo "⚠️  Erreur lors de l'exécution d'Ansible. Vérifiez les logs avec:"
    echo "   docker-compose logs ansible-control"
}

# Afficher les informations
echo ""
echo "✅ Laboratoire construit avec succès!"
echo ""
echo "📊 Informations du laboratoire:"
echo "   - Interface Web: http://localhost"
echo "   - API Scanner: http://localhost:5001/api/discover"
echo "   - Serveur Web: http://localhost:8080"
echo "   - API: http://localhost:5000"
echo ""
echo "Pour détruire le laboratoire, exécutez: ./destroy.sh"
