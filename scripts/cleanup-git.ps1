# Script de nettoyage Git
# Supprime les fichiers ignorés et nettoie le dépôt

Write-Host "🧹 Nettoyage du dépôt Git..." -ForegroundColor Cyan
Write-Host ""

# Supprimer les fichiers ignorés du cache Git
Write-Host "▶ Suppression des fichiers ignorés du cache Git..." -ForegroundColor Yellow
git rm -r --cached . 2>$null
git add .

# Supprimer les fichiers .bak
Write-Host "▶ Recherche des fichiers .bak..." -ForegroundColor Yellow
$bakFiles = Get-ChildItem -Path . -Filter "*.bak" -Recurse -ErrorAction SilentlyContinue
if ($bakFiles) {
    foreach ($file in $bakFiles) {
        Write-Host "  Suppression: $($file.FullName)" -ForegroundColor Gray
        Remove-Item $file.FullName -Force
    }
} else {
    Write-Host "  Aucun fichier .bak trouvé" -ForegroundColor Green
}

# Supprimer les fichiers temporaires
Write-Host "▶ Recherche des fichiers temporaires..." -ForegroundColor Yellow
$tmpFiles = Get-ChildItem -Path . -Filter "*.tmp" -Recurse -ErrorAction SilentlyContinue
if ($tmpFiles) {
    foreach ($file in $tmpFiles) {
        Write-Host "  Suppression: $($file.FullName)" -ForegroundColor Gray
        Remove-Item $file.FullName -Force
    }
} else {
    Write-Host "  Aucun fichier temporaire trouvé" -ForegroundColor Green
}

# Supprimer __pycache__
Write-Host "▶ Recherche des dossiers __pycache__..." -ForegroundColor Yellow
$pycacheDirs = Get-ChildItem -Path . -Filter "__pycache__" -Recurse -Directory -ErrorAction SilentlyContinue
if ($pycacheDirs) {
    foreach ($dir in $pycacheDirs) {
        Write-Host "  Suppression: $($dir.FullName)" -ForegroundColor Gray
        Remove-Item $dir.FullName -Recurse -Force
    }
} else {
    Write-Host "  Aucun dossier __pycache__ trouvé" -ForegroundColor Green
}

# Vérifier l'état Git
Write-Host ""
Write-Host "▶ État du dépôt Git:" -ForegroundColor Yellow
git status --short

Write-Host ""
Write-Host "✅ Nettoyage terminé !" -ForegroundColor Green
Write-Host ""
Write-Host "Pour commiter les changements:" -ForegroundColor Cyan
Write-Host "  git add ." -ForegroundColor White
Write-Host "  git commit -m 'Nettoyage du dépôt Git'" -ForegroundColor White
