# Publication du Docker Mod PSP sur GitHub

## 🎯 Objectif

Publier le Docker Mod sur **GitHub Container Registry** (GHCR) pour qu'il soit accessible depuis n'importe où.

---

## 📋 Étapes de publication

### **1️⃣ Créer un nouveau repo GitHub**

1. Aller sur https://github.com/new
2. **Nom du repo** : `jellyfin-psp-ffmpeg-mod`
3. **Description** : `Docker Mod for LinuxServer Jellyfin - Forces H.264 Baseline Profile for PSP compatibility`
4. **Public** ou **Private** (GHCR fonctionne avec les deux)
5. **NE PAS** initialiser avec README (on a déjà nos fichiers)
6. Cliquer sur **Create repository**

---

### **2️⃣ Pusher le code sur GitHub**

**Sur WSL** :

```bash
cd /home/janokun/git/psp-jellyfin-client/jellyfin-psp-mod

# Initialiser git (si pas déjà fait)
git init
git add .
git commit -m "Initial release: Jellyfin PSP FFmpeg Baseline Profile wrapper"

# Ajouter le remote GitHub (REMPLACER 'yourusername' par votre username GitHub)
git remote add origin https://github.com/yourusername/jellyfin-psp-ffmpeg-mod.git

# Push vers GitHub
git branch -M main
git push -u origin main
```

---

### **3️⃣ GitHub Actions va builder automatiquement**

Une fois pushé, **GitHub Actions** va :
1. Détecter le push sur `main`
2. Builder le Docker Mod
3. Le publier sur **GitHub Container Registry**
4. L'image sera disponible à : `ghcr.io/yourusername/jellyfin-psp-ffmpeg-mod:latest`

**Vérifier le build** :
1. Aller sur https://github.com/yourusername/jellyfin-psp-ffmpeg-mod/actions
2. Cliquer sur le workflow "Build and Publish Docker Mod"
3. Attendre que le build soit ✅ (environ 2-3 minutes)

---

### **4️⃣ Rendre le package public (si repo privé)**

Si votre repo est **privé**, rendez le package GHCR **public** :

1. Aller sur https://github.com/yourusername?tab=packages
2. Cliquer sur `jellyfin-psp-ffmpeg-mod`
3. **Package settings** → **Change visibility** → **Public**

---

### **5️⃣ Utiliser le mod sur votre serveur**

**Sur le serveur**, modifier `docker-compose.yml` :

```yaml
services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Paris
      
      # ⭐ UTILISER LE MOD DEPUIS GITHUB (remplacer 'yourusername')
      - DOCKER_MODS=ghcr.io/yourusername/jellyfin-psp-ffmpeg-mod:latest
      
    volumes:
      - /path/to/config:/config
      - /path/to/media:/data/media
    ports:
      - 21409:8096
    restart: unless-stopped
```

**Puis** :

```bash
# Recréer le conteneur (il téléchargera le mod depuis GHCR)
docker-compose down
docker-compose up -d

# Attendre 20 secondes
sleep 20

# Vérifier que le wrapper est installé
docker exec jellyfin ls -la /usr/lib/jellyfin-ffmpeg/
# Doit afficher : ffmpeg (wrapper), ffmpeg.original

# Vider le cache
docker exec jellyfin rm -rf /config/cache/transcodes/*

# Tester sur la PSP ! 🎮
```

---

## 🔐 Permissions GitHub (si erreur lors du build)

Si GitHub Actions échoue avec une erreur de permissions :

1. Aller sur https://github.com/yourusername/jellyfin-psp-ffmpeg-mod/settings/actions
2. **Workflow permissions** → Sélectionner **Read and write permissions**
3. Sauvegarder
4. Re-runner le workflow (Actions → Re-run jobs)

---

## 🎉 Avantages de cette méthode

✅ **Accessible partout** : Le mod est sur GHCR, téléchargeable depuis n'importe quel serveur  
✅ **Versionné** : Chaque commit = nouvelle version du mod  
✅ **Automatique** : GitHub Actions build à chaque push  
✅ **Gratuit** : GHCR est gratuit pour les repos publics  
✅ **Multi-arch** : Le workflow build pour AMD64 et ARM64  
✅ **Professionnel** : Peut être partagé avec la communauté  

---

## 📊 Flux de travail

```
Vous modifiez le wrapper FFmpeg localement
        │
        ▼ (git push)
GitHub Actions détecte le push
        │
        ▼
Build du Docker Mod (AMD64 + ARM64)
        │
        ▼
Publication sur GitHub Container Registry
        │
        ▼
Votre serveur télécharge le mod au démarrage
        │
        ▼
Wrapper FFmpeg installé automatiquement ✅
```

---

## 🔄 Mettre à jour le mod

```bash
# 1. Modifier le wrapper FFmpeg localement
# Éditer : jellyfin-psp-mod/root/etc/s6-overlay/s6-rc.d/init-mod-jellyfin-psp-ffmpeg/run

# 2. Commit et push
git add .
git commit -m "Update: nouvelle version du wrapper FFmpeg"
git push

# 3. Attendre le build GitHub Actions (2-3 min)

# 4. Sur le serveur : Recréer le conteneur pour télécharger la nouvelle version
docker-compose down
docker-compose pull  # Télécharge la nouvelle version du mod
docker-compose up -d
```

---

**Prêt à créer le repo GitHub ?** Dites-moi votre **username GitHub** et je vous aide à pusher ! 🚀

