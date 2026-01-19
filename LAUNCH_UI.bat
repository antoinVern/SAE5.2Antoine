@echo off
REM ONE-CLICK: démarre l'interface web locale (boutons Deploy/Audit/Cleanup)

setlocal
cd /d "%~dp0"

echo.
echo ========================================
echo   SAÉ 5.02 - UI locale (boutons)
echo ========================================
echo.

REM Vérifier Python
python --version >nul 2>&1
if errorlevel 1 (
  echo ERREUR: Python n'est pas installe ou pas dans le PATH.
  echo Installe Python 3 puis relance.
  pause
  exit /b 1
)

REM Créer venv si besoin
if not exist ".venv\\Scripts\\python.exe" (
  echo Creation de l'environnement virtuel Python (.venv)...
  python -m venv .venv
)

echo Installation des dependances UI...
".venv\\Scripts\\python.exe" -m pip install --upgrade pip >nul
".venv\\Scripts\\python.exe" -m pip install -r ui\\requirements.txt

echo.
echo Lancement de l'UI...
echo Ouvre: http://127.0.0.1:5050
echo (fermer la fenetre pour arreter)
echo.

start "" "http://127.0.0.1:5050"
".venv\\Scripts\\python.exe" ui\\app.py

endlocal

