#!/bin/bash
# Script de destruction du laboratoire éphémère
# Compatible Docker Compose v2 et v1

set -e

echo "🧨 Destruction du laboratoire éphémère..."

# Détection Docker Compose
if docker compose version &>/dev/null; then
    COMPOSE="docker compose"
elif command -v docker-compose &>/dev/null; then
    COMPOSE="docker-compose"
else
    echo "❌ Docker Compose non trouvé"
    exit 1
fi

echo "🛑 Arrêt des conteneurs..."
$COMPOSE down -v --remove-orphans

echo "🧹 Nettoyage terminé"
echo "✅ Laboratoire détruit avec succès"
