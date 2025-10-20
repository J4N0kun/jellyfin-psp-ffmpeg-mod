#!/bin/bash
# Script de publication du Docker Mod PSP sur GitHub

set -e

echo "=================================================="
echo " Publication du Docker Mod PSP sur GitHub"
echo "=================================================="
echo ""

# Demander le username GitHub
read -p "Votre username GitHub : " GITHUB_USER

if [ -z "$GITHUB_USER" ]; then
    echo "❌ Erreur : username GitHub requis !"
    exit 1
fi

REPO_NAME="jellyfin-psp-ffmpeg-mod"
REPO_URL="https://github.com/$GITHUB_USER/$REPO_NAME.git"

echo ""
echo "→ Username GitHub : $GITHUB_USER"
echo "→ Repo GitHub : $REPO_URL"
echo ""

# Vérifier qu'on est dans le bon dossier
if [ ! -f "Dockerfile" ]; then
    echo "❌ Erreur : Dockerfile non trouvé !"
    echo "   Exécutez ce script depuis le dossier jellyfin-psp-mod/"
    exit 1
fi

# Initialiser git si nécessaire
if [ ! -d ".git" ]; then
    echo "→ Initialisation du repo git..."
    git init
    git add .
    git commit -m "Initial release: FFmpeg Baseline Profile wrapper for PSP compatibility"
else
    echo "→ Repo git déjà initialisé ✅"
fi

# Ajouter le remote GitHub
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "→ Ajout du remote GitHub..."
    git remote add origin "$REPO_URL"
else
    CURRENT_REMOTE=$(git remote get-url origin)
    if [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
        echo "→ Mise à jour du remote GitHub..."
        git remote set-url origin "$REPO_URL"
    else
        echo "→ Remote GitHub déjà configuré ✅"
    fi
fi

# Push vers GitHub
echo "→ Push vers GitHub..."
git branch -M main

if git push -u origin main; then
    echo ""
    echo "=================================================="
    echo "✅ Code pushé avec succès sur GitHub !"
    echo "=================================================="
    echo ""
    echo "📋 Prochaines étapes :"
    echo ""
    echo "1. Vérifier le build GitHub Actions :"
    echo "   https://github.com/$GITHUB_USER/$REPO_NAME/actions"
    echo ""
    echo "2. Attendre que le build soit ✅ (2-3 minutes)"
    echo ""
    echo "3. Si le build échoue avec erreur de permissions :"
    echo "   https://github.com/$GITHUB_USER/$REPO_NAME/settings/actions"
    echo "   → Workflow permissions → Read and write permissions"
    echo ""
    echo "4. Si repo privé, rendre le package public :"
    echo "   https://github.com/$GITHUB_USER?tab=packages"
    echo "   → jellyfin-psp-ffmpeg-mod → Change visibility → Public"
    echo ""
    echo "5. Utiliser le mod dans docker-compose.yml :"
    echo "   environment:"
    echo "     - DOCKER_MODS=ghcr.io/$GITHUB_USER/jellyfin-psp-ffmpeg-mod:latest"
    echo ""
    echo "=================================================="
else
    echo ""
    echo "❌ Erreur lors du push !"
    echo ""
    echo "Si vous avez une erreur d'authentification, créez un Personal Access Token :"
    echo "1. https://github.com/settings/tokens/new"
    echo "2. Cocher : repo, write:packages, read:packages"
    echo "3. Utiliser le token comme mot de passe lors du push"
    echo ""
    exit 1
fi

