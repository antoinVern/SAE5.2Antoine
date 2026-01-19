#!/bin/bash
# Script pour exécuter les playbooks Ansible

set -e

echo "🚀 Démarrage de la configuration Ansible..."

# Attendre que les conteneurs soient prêts
echo "⏳ Attente des conteneurs..."
sleep 5

# Vérifier que les conteneurs cibles sont accessibles
echo "🔍 Vérification de l'accessibilité des conteneurs..."
cd /etc/ansible

# Exécuter les playbooks dans l'ordre
echo "📋 Exécution du playbook principal..."
if ansible-playbook playbooks/site.yml; then
    echo "✅ Playbook principal terminé avec succès"
else
    echo "⚠️  Erreur lors de l'exécution du playbook principal"
fi

echo "🔒 Exécution du durcissement de sécurité..."
if ansible-playbook playbooks/security-hardening.yml; then
    echo "✅ Durcissement de sécurité terminé"
else
    echo "⚠️  Erreur lors du durcissement de sécurité"
fi

echo "🌐 Configuration de la découverte réseau..."
if ansible-playbook playbooks/network-discovery.yml; then
    echo "✅ Configuration réseau terminée"
else
    echo "⚠️  Erreur lors de la configuration réseau"
fi

echo "✅ Configuration Ansible terminée!"
