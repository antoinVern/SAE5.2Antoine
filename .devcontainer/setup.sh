#!/bin/bash
# Script de configuration automatique pour GitHub Codespaces / Dev Containers

set -e

echo "═══════════════════════════════════════════════════════════"
echo "  🚀 Configuration automatique - SAÉ 5.02"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Mise à jour du système
echo "▶ Mise à jour du système..."
sudo apt-get update -qq

# Installation de Vagrant
echo "▶ Installation de Vagrant..."
if ! command -v vagrant &> /dev/null; then
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    sudo apt-get update -qq
    sudo apt-get install -y vagrant
    echo "✅ Vagrant installé"
else
    echo "✅ Vagrant déjà installé"
fi

# Installation d'Ansible
echo "▶ Installation d'Ansible..."
if ! command -v ansible-playbook &> /dev/null; then
    sudo apt-get install -y python3-pip
    pip3 install ansible
    echo "✅ Ansible installé"
else
    echo "✅ Ansible déjà installé"
fi

# Installation des collections Ansible
echo "▶ Installation des collections Ansible..."
if [ -f "collections/requirements.yml" ]; then
    ansible-galaxy collection install -r collections/requirements.yml
    echo "✅ Collections installées"
fi

# Installation de VirtualBox (si possible dans le conteneur)
echo "▶ Note: VirtualBox nécessite un environnement avec accès à l'hyperviseur"
echo "   Pour utiliser Vagrant, vous devrez utiliser un provider alternatif"
echo "   ou exécuter sur votre machine locale"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  ✅ Configuration terminée !"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "Pour lancer l'environnement :"
echo "  ./scripts/run_audit.sh all"
echo ""
