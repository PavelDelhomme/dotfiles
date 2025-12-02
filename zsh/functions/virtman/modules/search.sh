#!/bin/bash

################################################################################
# Recherche d'environnements virtuels
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'virtman search'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
if [ -f "$DOTFILES_DIR/scripts/lib/common.sh" ]; then
    source "$DOTFILES_DIR/scripts/lib/common.sh"
else
    log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
    log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
    log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
    log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }
fi

log_section "Recherche d'environnements virtuels"

echo ""
printf "Nom ou pattern à rechercher: "
read -r search_term

if [ -z "$search_term" ]; then
    log_error "Terme de recherche vide"
    return 1 2>/dev/null || exit 1
fi

echo ""
log_info "Recherche de '$search_term'..."
echo ""

# Recherche dans Docker
if command -v docker >/dev/null 2>&1; then
    echo -e "\033[0;36m🐳 DOCKER\033[0m"
    docker ps -a --format "table {{.Names}}\t{{.Status}}" | grep -i "$search_term" || echo "  Aucun résultat"
    echo ""
fi

# Recherche dans QEMU
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo -e "\033[0;36m⚡ QEMU/KVM\033[0m"
    ps aux | grep qemu-system | grep -i "$search_term" | grep -v grep || echo "  Aucun résultat"
    echo ""
fi

# Recherche dans libvirt
if command -v virsh >/dev/null 2>&1; then
    echo -e "\033[0;36m🔧 LIBVIRT\033[0m"
    virsh list --all --name 2>/dev/null | grep -i "$search_term" || echo "  Aucun résultat"
    echo ""
fi

# Recherche dans LXC
if command -v lxc >/dev/null 2>&1 || command -v lxc-ls >/dev/null 2>&1; then
    echo -e "\033[0;36m📦 LXC\033[0m"
    if command -v lxc >/dev/null 2>&1; then
        lxc list --format csv -c n 2>/dev/null | grep -i "$search_term" || echo "  Aucun résultat"
    else
        lxc-ls 2>/dev/null | grep -i "$search_term" || echo "  Aucun résultat"
    fi
    echo ""
fi

# Recherche dans Vagrant
if command -v vagrant >/dev/null 2>&1; then
    echo -e "\033[0;36m🚀 VAGRANT\033[0m"
    vagrant global-status 2>/dev/null | grep -i "$search_term" || echo "  Aucun résultat"
    echo ""
fi

read -k 1 "?Appuyez sur une touche pour continuer... "

