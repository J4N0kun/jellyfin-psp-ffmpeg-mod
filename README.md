# Jellyfin PSP Docker Mod - FFmpeg Baseline Profile Wrapper

[![Docker Mod](https://img.shields.io/badge/Docker-Mod-blue?logo=docker)](https://github.com/linuxserver/docker-mods)
[![GitHub](https://img.shields.io/github/license/yourusername/jellyfin-psp-ffmpeg-mod)](LICENSE)

## 🎯 Objectif

Docker Mod pour **LinuxServer Jellyfin** qui force **tous** les transcodages H.264 en **Baseline Profile Level 3.0** pour compatibilité PSP (PlayStation Portable).

**Avantage principal** : Intercepte directement FFmpeg, pas besoin de modifier `encoding.xml` qui est constamment réécrit par Jellyfin !

---

## 📦 Qu'est-ce qu'un Docker Mod ?

Un Docker Mod LinuxServer est une **image Docker minimaliste** qui contient des fichiers à injecter dans le conteneur au démarrage.

Référence : [LinuxServer - Docker Mods](https://docs.linuxserver.io/general/container-customization/#docker-mods)

---

## 🚀 Installation

### **Méthode 1 : Build local (RECOMMANDÉ)**

```bash
# 1. Builder le mod en image Docker locale
docker build -t jellyfin-psp-mod:latest /home/janokun/git/psp-jellyfin-client/jellyfin-psp-mod

# 2. Sur le serveur : Modifier docker-compose.yml
```

Ajouter la variable d'environnement `DOCKER_MODS` :

```yaml
services:
  jellyfin:
    image: lscr.io/linuxserver/jellyfin:latest
    container_name: jellyfin
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Europe/Paris
      
      # ⭐ AJOUTER CETTE LIGNE (Docker Mod PSP FFmpeg)
      - DOCKER_MODS=jellyfin-psp-mod:latest
      
    volumes:
      - /path/to/config:/config
      - /path/to/media:/data/media
    ports:
      - 21409:8096
    restart: unless-stopped
```

```bash
# 3. Recréer le conteneur
docker-compose down
docker-compose up -d

# 4. Attendre 20 secondes
sleep 20

# 5. Vérifier que le wrapper est installé
docker exec jellyfin ls -la /usr/lib/jellyfin-ffmpeg/
# Doit afficher : ffmpeg, ffmpeg.original

# 6. Vérifier les logs
docker logs jellyfin 2>&1 | grep "PSP Jellyfin Mod"
# Doit afficher : "→ Wrapper FFmpeg installé ✅"

# 7. Vider le cache transcoding
docker exec jellyfin rm -rf /config/cache/transcodes/*
```

---

### **Méthode 2 : Publier sur Dockerhub (pour partage public)**

Si vous voulez partager ce mod avec la communauté :

1. Créer un repo GitHub avec le contenu de `jellyfin-psp-mod/`
2. Configurer GitHub Actions pour builder et pusher sur Dockerhub
3. Utiliser `DOCKER_MODS=youruser/jellyfin-psp-ffmpeg:latest`

Voir : [LinuxServer Docker Mods - Getting Started](https://github.com/linuxserver/docker-mods)

---

## 🔍 Comment ça fonctionne

### **1️⃣ Au démarrage du conteneur**

```
LinuxServer Jellyfin démarre
        │
        ▼
Docker Mod s6-overlay script s'exécute
        │
        ├─> Renomme /usr/lib/jellyfin-ffmpeg/ffmpeg → ffmpeg.original
        └─> Crée un wrapper /usr/lib/jellyfin-ffmpeg/ffmpeg
        │
        ▼
Jellyfin démarre normalement
```

### **2️⃣ Quand Jellyfin transcode**

```
Jellyfin appelle: ffmpeg -i input.mkv ... -c:v libx264 ... output.mp4
        │
        ▼
Wrapper FFmpeg détecte "libx264"
        │
        ├─> Ajoute: -profile:v baseline -level 3.0 -bf 0 -refs 1 ...
        └─> Exécute: ffmpeg.original -i input.mkv ... -c:v libx264 \
                     -profile:v baseline -level 3.0 -bf 0 ... output.mp4
        │
        ▼
Stream H.264 Baseline Profile généré ✅
```

---

## ✅ Avantages de cette méthode

✅ **Transparent** : Jellyfin n'a rien à modifier  
✅ **Robuste** : Pas besoin de surveiller `encoding.xml`  
✅ **Persistant** : Survit à tous les redémarrages  
✅ **Simple** : Une seule variable d'environnement  
✅ **Propre** : Pas de scripts de surveillance complexes  
✅ **Universel** : Fonctionne pour TOUS les transcodages H.264  

---

## 🐛 Troubleshooting

### Le mod ne s'applique pas

```bash
# Vérifier que l'image existe
docker images | grep jellyfin-psp-mod

# Vérifier les logs du mod
docker logs jellyfin 2>&1 | grep "PSP Jellyfin Mod"

# Vérifier que le wrapper est installé
docker exec jellyfin which ffmpeg
docker exec jellyfin ls -la /usr/lib/jellyfin-ffmpeg/ffmpeg*
```

### FFmpeg ne force pas Baseline

```bash
# Tester le wrapper manuellement
docker exec jellyfin sh -c "echo 'test libx264' | /usr/lib/jellyfin-ffmpeg/ffmpeg --help"

# Voir les commandes FFmpeg en temps réel (lors du transcodage)
docker logs -f jellyfin | grep ffmpeg
# Doit afficher : -profile:v baseline -level 3.0 -bf 0 ...
```

---

## 📝 Paramètres H.264 forcés par le wrapper

- **Profile** : `baseline` (pas de B-frames, pas de CABAC)
- **Level** : `3.0` (compatible PSP)
- **B-frames** : `0` (désactivé)
- **Références** : `1` (minimum)
- **Entropy coding** : `CAVLC` (`-coder 0`)
- **GOP** : `48` frames fixe
- **Keyframe min** : `48` (pas de scene change detection)
- **8x8 DCT** : Désactivé (`no-8x8dct=1`)
- **CABAC** : Désactivé (`no-cabac=1`)

---

**C'EST LA VRAIE SOLUTION !** 🎉 Jellyfin peut réécrire `encoding.xml` autant qu'il veut, le wrapper FFmpeg force **toujours** Baseline Profile !

