#!/bin/bash
# Script de construction du laboratoire éphémère

set -e

echo "🔨 Construction du laboratoire éphémère..."

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez l'installer d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez l'installer d'abord."
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
sleep 10

# Exécuter les playbooks Ansible
echo "📋 Configuration avec Ansible..."
docker exec lab-ansible-control /scripts/run_ansible.sh

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
