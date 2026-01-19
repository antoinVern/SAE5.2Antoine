@echo off
REM Script ONE-CLICK pour lancer l'environnement d'audit
REM Double-cliquez sur ce fichier pour tout lancer automatiquement !

echo.
echo ========================================
echo   Lancement Environnement d'Audit
echo   SAE 5.02 - ONE-CLICK
echo ========================================
echo.

REM Vérifier si l'installation a été faite
if not exist "scripts\run_audit.ps1" (
    echo ERREUR: Scripts non trouves
    echo Veuillez d'abord executer INSTALL.bat
    pause
    exit /b 1
)

REM Lancer le script principal
echo Lancement de l'environnement d'audit...
echo Cela peut prendre plusieurs minutes (creation des VMs, etc.)
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0scripts\run_audit.ps1" all

if errorlevel 1 (
    echo.
    echo ERREUR lors du lancement
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Environnement lance avec succes !
echo ========================================
echo.
echo Les rapports sont disponibles sur la VM attaquant
echo Pour consulter: vagrant ssh attaquant
echo.
pause
