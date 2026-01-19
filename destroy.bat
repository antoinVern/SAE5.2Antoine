@echo off
REM Script de destruction pour Windows

echo Destruction du laboratoire ephemere...

docker-compose down -v
docker network prune -f

echo Laboratoire detruit avec succes!
pause
