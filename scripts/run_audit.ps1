# Script wrapper PowerShell pour faciliter l'utilisation de la plateforme d'audit
# Usage: .\run_audit.ps1 [deploy|audit|consolidate|cleanup|all]

param(
    [Parameter(Position=0)]
    [ValidateSet("deploy", "audit", "consolidate", "cleanup", "all", "help")]
    [string]$Action = "help"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$SiteYml = Join-Path $ProjectRoot "site.yml"
$VagrantDir = Join-Path $ProjectRoot "vagrant"

function Print-Header {
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  🔒 Plateforme d'Audit de Sécurité Réseau - SAÉ 5.02" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Print-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Print-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Yellow
}

function Test-Prerequisites {
    Print-Info "Vérification des prérequis..."
    
    if (-not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
        Print-Error "Ansible n'est pas installé ou pas dans le PATH"
        exit 1
    }
    
    if (-not (Get-Command vagrant -ErrorAction SilentlyContinue)) {
        Print-Error "Vagrant n'est pas installé ou pas dans le PATH"
        exit 1
    }
    
    Print-Success "Prérequis OK"
}

function Start-Deploy {
    Print-Header
    Print-Info "🚀 Déploiement de l'infrastructure complète..."
    
    Push-Location $VagrantDir
    
    Print-Info "Démarrage des VMs Vagrant..."
    vagrant up
    
    Print-Info "Génération de l'inventaire Ansible..."
    & (Join-Path $ScriptDir "gen-inventory.ps1")
    
    Print-Info "Exécution du playbook principal..."
    ansible-playbook $SiteYml
    
    Pop-Location
    
    Print-Success "Déploiement terminé"
}

function Start-Audit {
    Print-Header
    Print-Info "🔍 Exécution des scans d'audit..."
    
    $AuditYml = Join-Path $ProjectRoot "audit.yml"
    ansible-playbook $AuditYml
    
    Print-Success "Audit terminé - Rapports disponibles dans /opt/audit/reports sur la VM attaquant"
}

function Start-Consolidate {
    Print-Header
    Print-Info "📊 Consolidation des rapports..."
    
    $ConsolidateYml = Join-Path $ProjectRoot "consolidate.yml"
    ansible-playbook $ConsolidateYml
    
    Print-Success "Consolidation terminée"
    Print-Info "Rapport HTML disponible: /opt/audit/reports/audit_consolidated_report.html"
}

function Start-Cleanup {
    Print-Header
    Print-Info "🧹 Nettoyage de l'environnement..."
    
    $CleanupYml = Join-Path $ProjectRoot "cleanup.yml"
    ansible-playbook $CleanupYml
    
    Print-Info "Arrêt des VMs Vagrant..."
    Push-Location $VagrantDir
    vagrant halt
    Pop-Location
    
    Print-Success "Nettoyage terminé"
}

function Start-All {
    Start-Deploy
    Start-Audit
    Start-Consolidate
    Print-Success "🎉 Scénario complet terminé !"
}

# Menu principal
switch ($Action) {
    "deploy" {
        Test-Prerequisites
        Start-Deploy
    }
    "audit" {
        Test-Prerequisites
        Start-Audit
    }
    "consolidate" {
        Test-Prerequisites
        Start-Consolidate
    }
    "cleanup" {
        Test-Prerequisites
        Start-Cleanup
    }
    "all" {
        Test-Prerequisites
        Start-All
    }
    default {
        Print-Header
        Write-Host "Usage: .\run_audit.ps1 [deploy|audit|consolidate|cleanup|all]" -ForegroundColor White
        Write-Host ""
        Write-Host "Commandes disponibles:" -ForegroundColor Cyan
        Write-Host "  deploy      - Déploie l'infrastructure complète (VMs + Docker + config réseau)"
        Write-Host "  audit       - Exécute les scans d'audit Nmap"
        Write-Host "  consolidate - Consolide les rapports d'audit en HTML"
        Write-Host "  cleanup     - Nettoie l'environnement (conteneurs + VMs)"
        Write-Host "  all         - Exécute tout le scénario (deploy + audit + consolidate)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Exemples:" -ForegroundColor Yellow
        Write-Host "  .\run_audit.ps1 all         # Scénario complet (recommandé)"
        Write-Host "  .\run_audit.ps1 deploy      # Déploiement uniquement"
        Write-Host "  .\run_audit.ps1 cleanup     # Nettoyage"
        Write-Host ""
        Write-Host "Documentation: https://github.com/antoinVern/SAE5.2Antoine" -ForegroundColor Gray
        Write-Host ""
    }
}
