#!/bin/bash
# Script de test pour vérifier l'environnement

echo "🔍 Vérification de l'environnement..."

# Vérifier le système
echo "Système: $(uname -a)"

# Vérifier Docker
if command -v docker &> /dev/null; then
    echo "✅ Docker installé: $(docker --version)"
    if docker ps &> /dev/null; then
        echo "✅ Permissions Docker OK"
    else
        echo "❌ Pas de permissions Docker"
    fi
else
    echo "❌ Docker non installé"
fi

# Vérifier Docker Compose
if command -v docker-compose &> /dev/null; then
    echo "✅ Docker Compose installé: $(docker-compose --version)"
elif docker compose version &> /dev/null; then
    echo "✅ Docker Compose v2 installé: $(docker compose version)"
else
    echo "❌ Docker Compose non installé"
fi

# Vérifier les ports
echo ""
echo "🔍 Vérification des ports..."
for port in 80 5000 5001 5002 8080 3306; do
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        echo "⚠️  Port $port déjà utilisé"
    else
        echo "✅ Port $port disponible"
    fi
done

echo ""
echo "✅ Vérification terminée"
