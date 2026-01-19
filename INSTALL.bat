@echo off
REM Script d'installation ONE-CLICK pour Windows
REM Double-cliquez sur ce fichier pour tout installer automatiquement !

echo.
echo ========================================
echo   Installation Automatique - SAE 5.02
echo ========================================
echo.

REM Vérifier si PowerShell est disponible
powershell -Command "Write-Host 'PowerShell OK' -ForegroundColor Green" >nul 2>&1
if errorlevel 1 (
    echo ERREUR: PowerShell n'est pas disponible
    pause
    exit /b 1
)

REM Lancer le script PowerShell d'installation
echo Lancement de l'installation automatique...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\install.ps1"

if errorlevel 1 (
    echo.
    echo ERREUR lors de l'installation
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Installation terminee avec succes !
echo ========================================
echo.
echo Pour lancer le projet, executez :
echo   .\scripts\run_audit.ps1 all
echo.
pause
