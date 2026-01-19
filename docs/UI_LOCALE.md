# UI locale (boutons) — SAÉ 5.02

Objectif: permettre à un utilisateur de piloter la plateforme **sans commandes** (via une page web locale).

## Démarrage (Windows)

1. Installer les prérequis du projet (VirtualBox/Vagrant/Ansible)
2. Double-cliquer sur `LAUNCH_UI.bat`
3. Ouvrir `http://127.0.0.1:5050`

## Boutons disponibles

- **Déployer**: lance `scripts/run_audit.ps1 deploy`
- **Audit**: lance `scripts/run_audit.ps1 audit`
- **Consolider**: lance `scripts/run_audit.ps1 consolidate`
- **Nettoyer**: lance `scripts/run_audit.ps1 cleanup`
- **Tout faire**: lance `scripts/run_audit.ps1 all`

## Notes

- L’UI tourne en local (localhost) et exécute des commandes sur la machine: c’est normal.
- Fermer la fenêtre `LAUNCH_UI.bat` arrête l’UI.

