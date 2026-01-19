#!/bin/bash
# Script pour exécuter les playbooks Ansible

set -e

echo "🚀 Démarrage de la configuration Ansible..."

# Attendre que les conteneurs soient prêts
echo "⏳ Attente des conteneurs..."
sleep 5

# Exécuter les playbooks dans l'ordre
cd /etc/ansible

echo "📋 Exécution du playbook principal..."
ansible-playbook playbooks/site.yml

echo "🔒 Exécution du durcissement de sécurité..."
ansible-playbook playbooks/security-hardening.yml

echo "🌐 Configuration de la découverte réseau..."
ansible-playbook playbooks/network-discovery.yml

echo "✅ Configuration Ansible terminée!"
