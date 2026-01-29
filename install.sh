#!/bin/bash

# Couleurs pour le terminal
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}##################################################${NC}"
echo -e "${BLUE}#           CYBERMONITOR PRO INSTALLER           #${NC}"
echo -e "${BLUE}##################################################${NC}"
echo ""

# 1. Vérification d'Ansible
if ! command -v ansible >/dev/null 2>&1; then
    echo -e "❌ Ansible n'est pas installé."
    echo -e "Veuillez l'installer avec : sudo apt update && sudo apt install -y ansible"
    exit 1
fi

# 2. Lancement du Playbook
echo -e "${GREEN}[+] Lancement du déploiement avec Ansible...${NC}"
echo -e "⚠️  Vous allez devoir entrer votre mot de passe sudo (root) pour l'installation."
echo ""

ansible-playbook -i inventory.ini deploy_monitor.yml --ask-become-pass

# 3. Message de fin
if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ INSTALLATION RÉUSSIE !${NC}"
    echo -e "👉 Ouvrez votre navigateur sur : ${BLUE}http://localhost:5000${NC}"
else
    echo ""
    echo -e "❌ Une erreur est survenue lors du déploiement."
fi