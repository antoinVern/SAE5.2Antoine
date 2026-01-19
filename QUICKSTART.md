# ⚡ Démarrage Rapide

## Windows

1. **Installer Docker Desktop** (si pas déjà fait)
   - Télécharger: https://www.docker.com/products/docker-desktop
   - Installer et redémarrer

2. **Double-cliquer sur `build.bat`**

3. **Ouvrir http://localhost dans le navigateur**

4. **Pour détruire: Double-cliquer sur `destroy.bat`**

## Linux/Mac

1. **Installer Docker** (si pas déjà fait)
   ```bash
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh
   ```

2. **Construire le laboratoire**
   ```bash
   ./build.sh
   ```

3. **Ouvrir http://localhost dans le navigateur**

4. **Pour détruire:**
   ```bash
   ./destroy.sh
   ```

## 🎯 C'est tout !

Le laboratoire est maintenant prêt à être utilisé. L'interface web vous permet de:
- ✅ Contrôler le laboratoire (démarrer/arrêter/détruire)
- ✅ Scanner le réseau pour détecter les machines
- ✅ Voir l'état des services
- ✅ Consulter les logs
