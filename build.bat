@echo off
REM Script de construction pour Windows

echo Construction du laboratoire ephemere...

REM Verifier Docker
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERREUR: Docker n'est pas installe. Veuillez installer Docker Desktop.
    pause
    exit /b 1
)

REM Nettoyer les anciennes instances
echo Nettoyage des anciennes instances...
docker-compose down -v 2>nul

REM Construire et demarrer
echo Demarrage des conteneurs...
docker-compose up -d

REM Attendre
echo Attente du demarrage...
timeout /t 10 /nobreak >nul

REM Executer Ansible
echo Configuration avec Ansible...
docker exec lab-ansible-control /scripts/run_ansible.sh

echo.
echo Laboratoire construit avec succes!
echo.
echo Interface Web: http://localhost
echo API Scanner: http://localhost:5001/api/discover
echo.
echo Pour detruire: destroy.bat
pause
