#!/bin/bash
# Script de destruction automatique du laboratoire

set -e

echo "🗑️  Destruction du laboratoire éphémère..."

# Arrêter et supprimer tous les conteneurs
echo "🛑 Arrêt des conteneurs..."
docker-compose down -v

# Nettoyer les réseaux orphelins
echo "🧹 Nettoyage des réseaux..."
docker network prune -f

echo "✅ Laboratoire détruit avec succès!"
