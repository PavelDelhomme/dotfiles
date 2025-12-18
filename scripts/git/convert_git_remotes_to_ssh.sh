#!/bin/bash

################################################################################
# Script pour convertir tous les remotes Git de HTTPS vers SSH
# Parcourt ~/Documents/Dev/ et tous ses sous-dossiers
################################################################################

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SEARCH_DIR="${1:-$HOME/Documents/Dev}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Conversion Git Remotes HTTPS → SSH                     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📁 Recherche dans: $SEARCH_DIR${NC}"
echo ""

# Vérifier que SSH fonctionne avec GitHub
echo -e "${CYAN}🔐 Vérification de la connexion SSH GitHub...${NC}"
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo -e "${GREEN}✓ Connexion SSH GitHub OK${NC}"
else
    echo -e "${YELLOW}⚠️  Connexion SSH GitHub non vérifiée (peut être normale)${NC}"
fi
echo ""

# Fonction pour convertir une URL HTTPS en SSH
convert_https_to_ssh() {
    local url="$1"
    
    # Pattern: https://github.com/user/repo.git
    # ou: https://github.com/user/repo
    if [[ "$url" =~ ^https://github.com/([^/]+)/([^/]+)(\.git)?$ ]]; then
        local user="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        # Enlever .git si présent
        repo="${repo%.git}"
        echo "git@github.com:$user/$repo.git"
        return 0
    fi
    
    # Pattern: https://gitlab.com/user/repo.git
    if [[ "$url" =~ ^https://gitlab.com/([^/]+)/([^/]+)(\.git)?$ ]]; then
        local user="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        repo="${repo%.git}"
        echo "git@gitlab.com:$user/$repo.git"
        return 0
    fi
    
    # Pattern: https://bitbucket.org/user/repo.git
    if [[ "$url" =~ ^https://bitbucket.org/([^/]+)/([^/]+)(\.git)?$ ]]; then
        local user="${BASH_REMATCH[1]}"
        local repo="${BASH_REMATCH[2]}"
        repo="${repo%.git}"
        echo "git@bitbucket.org:$user/$repo.git"
        return 0
    fi
    
    # Si déjà en SSH ou autre format, retourner tel quel
    echo "$url"
    return 1
}

# Compteurs
total_repos=0
converted_repos=0
skipped_repos=0
error_repos=0

# Trouver tous les dossiers .git
echo -e "${CYAN}🔍 Recherche des dépôts Git...${NC}"
while IFS= read -r git_dir; do
    repo_dir=$(dirname "$git_dir")
    repo_name=$(basename "$repo_dir")
    
    # Ignorer les dossiers .git dans node_modules ou autres
    if [[ "$repo_dir" == *"node_modules"* ]] || [[ "$repo_dir" == *".git"* ]]; then
        continue
    fi
    
    total_repos=$((total_repos + 1))
    
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}📦 Dépôt: $repo_name${NC}"
    echo -e "${CYAN}📍 Chemin: $repo_dir${NC}"
    
    # Vérifier que c'est un repo Git valide
    if ! git -C "$repo_dir" rev-parse --git-dir >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Dépôt Git invalide, ignoré${NC}"
        skipped_repos=$((skipped_repos + 1))
        continue
    fi
    
    # Obtenir tous les remotes
    remotes=$(git -C "$repo_dir" remote 2>/dev/null || echo "")
    
    if [ -z "$remotes" ]; then
        echo -e "${YELLOW}⚠️  Aucun remote configuré${NC}"
        skipped_repos=$((skipped_repos + 1))
        continue
    fi
    
    repo_converted=false
    
    # Parcourir chaque remote
    while IFS= read -r remote_name; do
        if [ -z "$remote_name" ]; then
            continue
        fi
        
        current_url=$(git -C "$repo_dir" remote get-url "$remote_name" 2>/dev/null || echo "")
        
        if [ -z "$current_url" ]; then
            continue
        fi
        
        echo -e "   ${CYAN}Remote: $remote_name${NC}"
        echo -e "   ${YELLOW}URL actuelle: $current_url${NC}"
        
        # Vérifier si c'est déjà en SSH
        if [[ "$current_url" =~ ^git@ ]]; then
            echo -e "   ${GREEN}✓ Déjà en SSH${NC}"
            continue
        fi
        
        # Vérifier si c'est HTTPS
        if [[ "$current_url" =~ ^https:// ]]; then
            new_url=$(convert_https_to_ssh "$current_url")
            
            if [ "$new_url" != "$current_url" ]; then
                echo -e "   ${GREEN}→ Nouvelle URL: $new_url${NC}"
                
                # Modifier le remote
                if git -C "$repo_dir" remote set-url "$remote_name" "$new_url" 2>/dev/null; then
                    echo -e "   ${GREEN}✓ Remote mis à jour${NC}"
                    repo_converted=true
                else
                    echo -e "   ${RED}✗ Erreur lors de la mise à jour${NC}"
                    error_repos=$((error_repos + 1))
                fi
            else
                echo -e "   ${YELLOW}⚠️  Format non reconnu, ignoré${NC}"
            fi
        else
            echo -e "   ${YELLOW}⚠️  Format non HTTPS, ignoré${NC}"
        fi
    done <<< "$remotes"
    
    if [ "$repo_converted" = true ]; then
        converted_repos=$((converted_repos + 1))
    fi
    
done < <(find "$SEARCH_DIR" -type d -name ".git" 2>/dev/null)

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${CYAN}📊 Résumé:${NC}"
echo -e "   ${GREEN}Total dépôts trouvés: $total_repos${NC}"
echo -e "   ${GREEN}Dépôts convertis: $converted_repos${NC}"
echo -e "   ${YELLOW}Dépôts ignorés: $skipped_repos${NC}"
if [ $error_repos -gt 0 ]; then
    echo -e "   ${RED}Erreurs: $error_repos${NC}"
fi
echo ""
echo -e "${GREEN}✅ Conversion terminée!${NC}"
echo ""
echo -e "${BLUE}💡 Pour tester un remote:${NC}"
echo "   git remote -v"
echo "   git fetch"
echo ""

