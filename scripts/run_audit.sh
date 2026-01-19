#!/bin/bash
# Script wrapper pour faciliter l'utilisation de la plateforme d'audit
# Usage: ./run_audit.sh [deploy|audit|consolidate|cleanup|all]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PLAYBOOKS_DIR="$PROJECT_ROOT/playbooks"

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  🔒 Plateforme d'Audit de Sécurité Réseau - SAÉ 5.02${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

check_prerequisites() {
    print_info "Vérification des prérequis..."
    
    if ! command -v ansible-playbook &> /dev/null; then
        print_error "Ansible n'est pas installé"
        exit 1
    fi
    
    if ! command -v vagrant &> /dev/null; then
        print_error "Vagrant n'est pas installé"
        exit 1
    fi
    
    print_success "Prérequis OK"
}

deploy() {
    print_header
    print_info "🚀 Déploiement de l'infrastructure complète..."
    
    cd "$PROJECT_ROOT/vagrant"
    
    print_info "Démarrage des VMs Vagrant..."
    vagrant up
    
    print_info "Génération de l'inventaire Ansible..."
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
        # Windows
        powershell -ExecutionPolicy Bypass -File "$PROJECT_ROOT/scripts/gen-inventory.ps1"
    else
        # Linux/Mac - à adapter si besoin
        print_info "Génération manuelle de l'inventaire requise sur Linux/Mac"
    fi
    
    print_info "Exécution des playbooks de déploiement..."
    ansible-playbook "$PLAYBOOKS_DIR/site.yml"
    
    print_success "Déploiement terminé"
}

audit() {
    print_header
    print_info "🔍 Exécution des scans d'audit..."
    
    ansible-playbook "$PLAYBOOKS_DIR/30_scan_nmap.yml"
    
    print_success "Audit terminé - Rapports disponibles dans /opt/audit/reports sur la VM attaquant"
}

consolidate() {
    print_header
    print_info "📊 Consolidation des rapports..."
    
    ansible-playbook "$PLAYBOOKS_DIR/40_consolidate_reports.yml"
    
    print_success "Consolidation terminée"
    print_info "Rapport HTML disponible: /opt/audit/reports/audit_consolidated_report.html"
}

cleanup() {
    print_header
    print_info "🧹 Nettoyage de l'environnement..."
    
    ansible-playbook "$PLAYBOOKS_DIR/99_cleanup.yml"
    
    print_info "Arrêt des VMs Vagrant..."
    cd "$PROJECT_ROOT/vagrant"
    vagrant halt
    
    print_success "Nettoyage terminé"
}

all() {
    deploy
    audit
    consolidate
    print_success "🎉 Scénario complet terminé !"
}

# Menu principal
case "${1:-help}" in
    deploy)
        check_prerequisites
        deploy
        ;;
    audit)
        check_prerequisites
        audit
        ;;
    consolidate)
        check_prerequisites
        consolidate
        ;;
    cleanup)
        check_prerequisites
        cleanup
        ;;
    all)
        check_prerequisites
        all
        ;;
    help|*)
        print_header
        echo "Usage: $0 [deploy|audit|consolidate|cleanup|all]"
        echo ""
        echo "Commandes disponibles:"
        echo "  deploy      - Déploie l'infrastructure complète (VMs + Docker + config réseau)"
        echo "  audit       - Exécute les scans d'audit Nmap"
        echo "  consolidate - Consolide les rapports d'audit en HTML"
        echo "  cleanup     - Nettoie l'environnement (conteneurs + VMs)"
        echo "  all         - Exécute tout le scénario (deploy + audit + consolidate)"
        echo ""
        exit 0
        ;;
esac
