# Script d'installation automatique pour Windows
# Vérifie et installe les prérequis si nécessaire

Write-Host "🔍 Vérification des prérequis..." -ForegroundColor Cyan

$missing = @()

# Vérifier VirtualBox
if (-not (Get-Command VBoxManage -ErrorAction SilentlyContinue)) {
    Write-Host "❌ VirtualBox non trouvé" -ForegroundColor Red
    $missing += "VirtualBox"
} else {
    Write-Host "✅ VirtualBox installé" -ForegroundColor Green
}

# Vérifier Vagrant
if (-not (Get-Command vagrant -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Vagrant non trouvé" -ForegroundColor Red
    $missing += "Vagrant"
} else {
    Write-Host "✅ Vagrant installé" -ForegroundColor Green
    vagrant --version
}

# Vérifier Ansible
if (-not (Get-Command ansible-playbook -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Ansible non trouvé" -ForegroundColor Red
    $missing += "Ansible"
} else {
    Write-Host "✅ Ansible installé" -ForegroundColor Green
    ansible --version
}

# Vérifier Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git non trouvé" -ForegroundColor Red
    $missing += "Git"
} else {
    Write-Host "✅ Git installé" -ForegroundColor Green
    git --version
}

if ($missing.Count -gt 0) {
    Write-Host "`n⚠️  Prérequis manquants : $($missing -join ', ')" -ForegroundColor Yellow
    Write-Host "`nTéléchargements :" -ForegroundColor Cyan
    Write-Host "  - VirtualBox : https://www.virtualbox.org/wiki/Downloads"
    Write-Host "  - Vagrant    : https://www.vagrantup.com/downloads"
    Write-Host "  - Ansible    : https://docs.ansible.com/ansible/latest/installation_guide/index.html"
    Write-Host "  - Git        : https://git-scm.com/downloads"
    exit 1
}

Write-Host "`n✅ Tous les prérequis sont installés !" -ForegroundColor Green

# Installer les collections Ansible
Write-Host "`n📦 Installation des collections Ansible..." -ForegroundColor Cyan
$collectionsFile = Join-Path $PSScriptRoot "..\collections\requirements.yml"
if (Test-Path $collectionsFile) {
    ansible-galaxy collection install -r $collectionsFile
    Write-Host "✅ Collections installées" -ForegroundColor Green
} else {
    Write-Host "⚠️  Fichier requirements.yml non trouvé" -ForegroundColor Yellow
}

Write-Host "`n🎉 Installation terminée !" -ForegroundColor Green
Write-Host "`nPour lancer le projet :" -ForegroundColor Cyan
Write-Host "  .\scripts\run_audit.ps1 all" -ForegroundColor White
