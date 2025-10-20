# Guide rapide - Publication du Docker Mod PSP

## ⚡ Étapes rapides (5 minutes)

### **1️⃣ Créer le repo GitHub**

```bash
# Aller sur : https://github.com/new
# Nom : jellyfin-psp-ffmpeg-mod
# Public ou Private
# NE PAS initialiser avec README
# Créer !
```

---

### **2️⃣ Pusher le code**

**Remplacer `VOTRE_USERNAME` par votre username GitHub** :

```bash
cd /home/janokun/git/psp-jellyfin-client/jellyfin-psp-mod

# Init git
git init
git add .
git commit -m "Initial release: FFmpeg Baseline Profile wrapper for PSP"

# Ajouter le remote (REMPLACER VOTRE_USERNAME !)
git remote add origin https://github.com/VOTRE_USERNAME/jellyfin-psp-ffmpeg-mod.git

# Push
git branch -M main
git push -u origin main
```

**Si demandé, entrez vos identifiants GitHub** (ou utilisez un Personal Access Token).

---

### **3️⃣ Attendre le build GitHub Actions**

```bash
# Aller sur : https://github.com/VOTRE_USERNAME/jellyfin-psp-ffmpeg-mod/actions
# Attendre que le workflow soit ✅ (2-3 minutes)
```

**Si le workflow échoue** avec une erreur de permissions :
1. Aller sur https://github.com/VOTRE_USERNAME/jellyfin-psp-ffmpeg-mod/settings/actions
2. **Workflow permissions** → **Read and write permissions**
3. Sauvegarder
4. Aller dans Actions → Re-run jobs

---

### **4️⃣ Rendre le package public (si repo privé)**

```bash
# Aller sur : https://github.com/VOTRE_USERNAME?tab=packages
# Cliquer sur : jellyfin-psp-ffmpeg-mod
# Package settings → Change visibility → Public
```

---

### **5️⃣ Utiliser le mod sur votre serveur**

**Sur le serveur**, modifier `docker-compose.yml` (REMPLACER `VOTRE_USERNAME`) :

```yaml
services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    environment:
      # ⭐ AJOUTER CETTE LIGNE
      - DOCKER_MODS=ghcr.io/VOTRE_USERNAME/jellyfin-psp-ffmpeg-mod:latest
```

**Puis** :

```bash
# Recréer le conteneur
docker-compose down
docker-compose up -d

# Attendre 20s
sleep 20

# Vérifier que le mod est appliqué
docker logs jellyfin 2>&1 | grep "PSP Jellyfin Mod"
# Doit afficher : "→ Wrapper FFmpeg installé ✅"

# Vérifier le wrapper
docker exec jellyfin ls -la /usr/lib/jellyfin-ffmpeg/
# Doit afficher : ffmpeg, ffmpeg.original

# Vider le cache
docker exec jellyfin rm -rf /config/cache/transcodes/*

# Tester sur la PSP ! 🎮
```

---

## ✅ Résultat attendu sur la PSP

```
VideoDecoder: [H264] NAL type=1, size=3072, keyframe=non        ✅
VideoDecoder: [H264 DECODE] ret=0x00000000, outsize=388800      ✅
VideoDecoder: Frame décodée avec succès! 🎉
```

---

## 📝 Exemple docker-compose.yml complet

```yaml
version: "3.8"

services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Paris
      - DOCKER_MODS=ghcr.io/VOTRE_USERNAME/jellyfin-psp-ffmpeg-mod:latest
    volumes:
      - /path/to/config:/config
      - /path/to/media:/data/media
    ports:
      - 21409:8096
    restart: unless-stopped
```

---

**C'EST TOUT !** Une seule variable d'environnement et le problème est résolu ! 🎉

