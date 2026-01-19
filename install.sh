#!/bin/bash
# Script d'installation automatique pour Linux/Mac
# Usage: ./install.sh

set -e

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "  🚀 Installation - SAÉ 5.02"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Vérification des prérequis
print_info "Vérification des prérequis..."

MISSING=0

if ! command -v vagrant &> /dev/null; then
    print_error "Vagrant n'est pas installé"
    echo "  Télécharger: https://www.vagrantup.com/downloads"
    MISSING=1
else
    print_success "Vagrant installé"
    vagrant --version
fi

if ! command -v ansible-playbook &> /dev/null; then
    print_error "Ansible n'est pas installé"
    echo "  Installer via: pip3 install ansible"
    MISSING=1
else
    print_success "Ansible installé"
    ansible --version | head -n 1
fi

if ! command -v git &> /dev/null; then
    print_error "Git n'est pas installé"
    MISSING=1
else
    print_success "Git installé"
    git --version
fi

if [ $MISSING -eq 1 ]; then
    echo ""
    print_error "Des prérequis sont manquants. Veuillez les installer avant de continuer."
    exit 1
fi

# Installation des collections Ansible
echo ""
print_info "Installation des collections Ansible..."
if [ -f "collections/requirements.yml" ]; then
    ansible-galaxy collection install -r collections/requirements.yml
    print_success "Collections installées"
else
    print_error "Fichier collections/requirements.yml non trouvé"
fi

echo ""
print_success "Installation terminée !"
echo ""
print_info "Pour lancer le projet :"
echo "  ansible-playbook site.yml"
echo ""
