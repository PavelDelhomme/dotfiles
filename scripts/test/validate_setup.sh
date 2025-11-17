#!/bin/bash

################################################################################
# Validation complète du setup dotfiles
# Vérifie toutes les installations et configurations
################################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

check_pass() {
    echo -e "${GREEN}✅${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}❌${NC} $1"
    ((FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠️${NC} $1"
    ((WARNINGS++))
}

log_section() {
    echo -e "\n${BLUE}═══════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════${NC}\n"
}

################################################################################
# VÉRIFICATIONS FONCTIONS ZSH
################################################################################
log_section "Vérifications fonctions ZSH"

if type add_alias &> /dev/null; then
    check_pass "add_alias disponible"
else
    check_fail "add_alias non disponible"
fi

if type add_to_path &> /dev/null; then
    check_pass "add_to_path disponible"
else
    check_fail "add_to_path non disponible"
fi

if type clean_path &> /dev/null; then
    check_pass "clean_path disponible"
else
    check_fail "clean_path non disponible"
fi

################################################################################
# VÉRIFICATIONS PATH
################################################################################
log_section "Vérifications PATH"

PATHS_TO_CHECK=(
    "/usr/local/go/bin:Go"
    "$HOME/go/bin:Go (GOPATH)"
    "/opt/flutter/bin:Flutter"
    "$ANDROID_SDK_ROOT/platform-tools:Android SDK"
    "$HOME/.pub-cache/bin:Dart pub-cache"
)

for path_entry in "${PATHS_TO_CHECK[@]}"; do
    IFS=':' read -r path name <<< "$path_entry"
    if [ -n "$path" ] && [[ ":$PATH:" == *":$path:"* ]]; then
        check_pass "Chemin présent: $name ($path)"
    else
        check_warn "Chemin manquant: $name ($path)"
    fi
done

################################################################################
# VÉRIFICATIONS SERVICES
################################################################################
log_section "Vérifications services systemd"

if systemctl --user is-active --quiet dotfiles-sync.timer 2>/dev/null; then
    check_pass "Timer auto-sync actif"
else
    check_warn "Timer auto-sync non actif (optionnel)"
fi

if systemctl is-active --quiet docker 2>/dev/null; then
    check_pass "Service Docker actif"
else
    check_warn "Service Docker non actif (optionnel)"
fi

if pgrep -x ssh-agent > /dev/null; then
    check_pass "SSH agent actif"
else
    check_warn "SSH agent non actif (peut être normal)"
fi

################################################################################
# VÉRIFICATIONS GIT
################################################################################
log_section "Vérifications Git"

if [ -n "$(git config --global user.name)" ]; then
    check_pass "Git user.name configuré: $(git config --global user.name)"
else
    check_fail "Git user.name non configuré"
fi

if [ -n "$(git config --global user.email)" ]; then
    check_pass "Git user.email configuré: $(git config --global user.email)"
else
    check_fail "Git user.email non configuré"
fi

if [ -n "$(git config --global credential.helper)" ]; then
    check_pass "Git credential.helper configuré: $(git config --global credential.helper)"
else
    check_warn "Git credential.helper non configuré (optionnel)"
fi

if [ -f "$HOME/.ssh/id_ed25519" ]; then
    check_pass "Clé SSH ED25519 présente"
else
    check_warn "Clé SSH ED25519 absente (optionnel)"
fi

# Test connexion GitHub
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    check_pass "Connexion GitHub SSH OK"
else
    check_warn "Connexion GitHub SSH non vérifiée"
fi

################################################################################
# VÉRIFICATIONS OUTILS
################################################################################
log_section "Vérifications outils installés"

TOOLS_TO_CHECK=(
    "go:Go"
    "docker:Docker"
    "docker-compose:Docker Compose"
    "cursor:Cursor IDE"
    "yay:yay (AUR)"
    "make:make"
    "gcc:gcc"
    "cmake:cmake"
    "pkg-config:pkg-config"
)

for tool_entry in "${TOOLS_TO_CHECK[@]}"; do
    IFS=':' read -r tool name <<< "$tool_entry"
    if command -v "$tool" &> /dev/null; then
        VERSION=$($tool --version 2>/dev/null | head -n1 || echo "version inconnue")
        check_pass "$name: $VERSION"
    else
        if [ "$tool" = "yay" ] && [ ! -f /etc/arch-release ]; then
            # yay n'est applicable que sur Arch
            continue
        fi
        check_warn "$name non installé (optionnel)"
    fi
done

################################################################################
# VÉRIFICATIONS FICHIERS DOTFILES
################################################################################
log_section "Vérifications fichiers dotfiles"

DOTFILES_FILES=(
    "$HOME/dotfiles/zsh/zshrc_custom:zshrc_custom"
    "$HOME/dotfiles/zsh/env.sh:env.sh"
    "$HOME/dotfiles/zsh/aliases.zsh:aliases.zsh"
    "$HOME/dotfiles/setup.sh:setup.sh"
    "$HOME/dotfiles/bootstrap.sh:bootstrap.sh"
)

for file_entry in "${DOTFILES_FILES[@]}"; do
    IFS=':' read -r file name <<< "$file_entry"
    if [ -f "$file" ]; then
        check_pass "Fichier présent: $name"
    else
        check_fail "Fichier manquant: $name"
    fi
done

# Vérifier que zshrc_custom est sourcé
if grep -q "zshrc_custom" "$HOME/.zshrc" 2>/dev/null; then
    check_pass "zshrc_custom sourcé dans .zshrc"
else
    check_fail "zshrc_custom non sourcé dans .zshrc"
fi

################################################################################
# RAPPORT FINAL
################################################################################
log_section "Rapport final"

TOTAL=$((PASSED + FAILED + WARNINGS))
echo ""
echo "Résultats:"
echo "  ${GREEN}✅ Réussis: $PASSED${NC}"
echo "  ${RED}❌ Échecs: $FAILED${NC}"
echo "  ${YELLOW}⚠️ Avertissements: $WARNINGS${NC}"
echo "  Total: $TOTAL vérifications"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Setup validé avec succès!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️ $WARNINGS avertissements (non critiques)${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ $FAILED problème(s) détecté(s)${NC}"
    echo ""
    echo "Solutions suggérées:"
    echo "  1. Relancez setup.sh pour installer les composants manquants"
    echo "  2. Rechargez votre shell: exec zsh"
    echo "  3. Vérifiez les logs pour plus de détails"
    exit 1
fi

