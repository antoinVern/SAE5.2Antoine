# Script d'installation COMPLETE - ONE-CLICK
# Fait TOUT automatiquement : vérifie prérequis, installe, configure et lance

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🚀 Installation COMPLETE - SAÉ 5.02" -ForegroundColor Cyan
Write-Host "  Installation automatique de l'environnement d'audit" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

# Fonctions d'affichage
function Print-Step {
    param([string]$Message)
    Write-Host "`n▶ $Message" -ForegroundColor Yellow
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
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

# ÉTAPE 1 : Vérification des prérequis
Print-Step "ÉTAPE 1/5 : Vérification des prérequis..."

$missing = @()

# Vérifier VirtualBox
if (-not (Get-Command VBoxManage -ErrorAction SilentlyContinue)) {
    Print-Error "VirtualBox non trouvé"
    $missing += @{
        Name = "VirtualBox"
        Url = "https://www.virtualbox.org/wiki/Downloads"
        Installer = "VirtualBox-*-Win.exe"
    }
} else {
    Print-Success "VirtualBox installé"
    $vboxVersion = (VBoxManage --version)
    Write-Host "   Version: $vboxVersion" -ForegroundColor Gray
}

# Vérifier Vagrant
if (-not (Get-Command vagrant -ErrorAction SilentlyContinue)) {
    Print-Error "Vagrant non trouvé"
    $missing += @{
        Name = "Vagrant"
        Url = "https://www.vagrantup.com/downloads"
        Installer = "vagrant_*_x86_64.msi"
    }
} else {
    Print-Success "Vagrant installé"
    $vagrantVersion = vagrant --version
    Write-Host "   $vagrantVersion" -ForegroundColor Gray
}

# Vérifier Ansible
if (-not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
    Print-Error "Ansible non trouvé"
    Print-Info "Installation d'Ansible recommandée via WSL ou pip"
    $missing += @{
        Name = "Ansible"
        Url = "https://docs.ansible.com/ansible/latest/installation_guide/index.html"
        Note = "Installer via: pip install ansible OU utiliser WSL"
    }
} else {
    Print-Success "Ansible installé"
    $ansibleVersion = ansible --version | Select-Object -First 1
    Write-Host "   $ansibleVersion" -ForegroundColor Gray
}

# Vérifier Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Print-Error "Git non trouvé"
    $missing += @{
        Name = "Git"
        Url = "https://git-scm.com/downloads"
        Installer = "Git-*.exe"
    }
} else {
    Print-Success "Git installé"
    $gitVersion = git --version
    Write-Host "   $gitVersion" -ForegroundColor Gray
}

# Afficher les prérequis manquants
if ($missing.Count -gt 0) {
    Write-Host ""
    Print-Error "Prérequis manquants détectés :"
    Write-Host ""
    foreach ($item in $missing) {
        Write-Host "  ❌ $($item.Name)" -ForegroundColor Red
        Write-Host "     Télécharger: $($item.Url)" -ForegroundColor Gray
        if ($item.Note) {
            Write-Host "     Note: $($item.Note)" -ForegroundColor Yellow
        }
        Write-Host ""
    }
    
    $continue = Read-Host "Voulez-vous continuer quand même ? (o/N)"
    if ($continue -ne "o" -and $continue -ne "O") {
        Write-Host "Installation annulée." -ForegroundColor Yellow
        exit 1
    }
} else {
    Print-Success "Tous les prérequis sont installés !"
}

# ÉTAPE 2 : Installation des collections Ansible
Print-Step "ÉTAPE 2/5 : Installation des collections Ansible..."

$collectionsFile = Join-Path $ProjectRoot "collections\requirements.yml"
if (Test-Path $collectionsFile) {
    try {
        ansible-galaxy collection install -r $collectionsFile
        Print-Success "Collections Ansible installées"
    } catch {
        Print-Error "Erreur lors de l'installation des collections"
        Write-Host "   Vous pouvez continuer, mais certaines fonctionnalités peuvent ne pas fonctionner" -ForegroundColor Yellow
    }
} else {
    Print-Error "Fichier requirements.yml non trouvé"
}

# ÉTAPE 3 : Génération de l'inventaire (si Vagrant est disponible)
Print-Step "ÉTAPE 3/5 : Préparation de l'environnement..."

if (Get-Command vagrant -ErrorAction SilentlyContinue) {
    $vagrantDir = Join-Path $ProjectRoot "vagrant"
    if (Test-Path $vagrantDir) {
        Push-Location $vagrantDir
        
        # Vérifier si les VMs existent déjà
        $vmsExist = vagrant status 2>&1 | Select-String -Pattern "not created|running|poweroff"
        
        if ($vmsExist) {
            Print-Info "VMs Vagrant détectées"
            Print-Info "Pour démarrer les VMs, exécutez: cd vagrant && vagrant up"
        } else {
            Print-Info "Les VMs seront créées au premier lancement"
        }
        
        Pop-Location
    }
} else {
    Print-Info "Vagrant non disponible - les VMs devront être créées manuellement"
}

# ÉTAPE 4 : Vérification de la structure du projet
Print-Step "ÉTAPE 4/5 : Vérification de la structure du projet..."

$requiredDirs = @("playbooks", "roles", "scripts", "vagrant", "docker", "docs")
$allPresent = $true

foreach ($dir in $requiredDirs) {
    $dirPath = Join-Path $ProjectRoot $dir
    if (Test-Path $dirPath) {
        Write-Host "   ✅ $dir/" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $dir/ (manquant)" -ForegroundColor Red
        $allPresent = $false
    }
}

if ($allPresent) {
    Print-Success "Structure du projet complète"
} else {
    Print-Error "Certains dossiers sont manquants"
}

# ÉTAPE 5 : Instructions finales
Print-Step "ÉTAPE 5/5 : Instructions de lancement"

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ✅ Installation terminée avec succès !" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Print-Info "Pour lancer l'environnement d'audit complet :"
Write-Host ""
Write-Host "  .\scripts\run_audit.ps1 all" -ForegroundColor White -BackgroundColor DarkBlue
Write-Host ""

Print-Info "Cette commande va :"
Write-Host "  1. Créer les VMs (attaquant, firewall, cible DMZ)"
Write-Host "  2. Configurer le réseau et le firewall"
Write-Host "  3. Déployer Docker et les conteneurs"
Write-Host "  4. Lancer les scans d'audit"
Write-Host "  5. Générer le rapport HTML consolidé"
Write-Host ""

Print-Info "Autres commandes utiles :"
Write-Host "  .\scripts\run_audit.ps1 deploy      # Déploiement uniquement"
Write-Host "  .\scripts\run_audit.ps1 audit       # Audit uniquement"
Write-Host "  .\scripts\run_audit.ps1 cleanup      # Nettoyage"
Write-Host ""

$launch = Read-Host "Voulez-vous lancer l'environnement maintenant ? (o/N)"
if ($launch -eq "o" -or $launch -eq "O") {
    Write-Host ""
    Print-Info "Lancement de l'environnement..."
    & (Join-Path $ScriptDir "run_audit.ps1") all
} else {
    Write-Host ""
    Print-Info "Vous pouvez lancer l'environnement plus tard avec :"
    Write-Host "  .\scripts\run_audit.ps1 all" -ForegroundColor White
}

Write-Host ""
Write-Host "Documentation complète : https://github.com/antoinVern/SAE5.2Antoine" -ForegroundColor Gray
Write-Host ""
