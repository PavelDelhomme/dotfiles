#!/bin/bash

################################################################################
# Vue d'ensemble - Tous les environnements virtuels
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'virtman overview'
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

log_section "Vue d'ensemble - Tous les environnements virtuels"

echo ""
echo "📊 RÉSUMÉ GLOBAL"
echo "══════════════════════════════════════════════════════════════════"
echo ""

# Docker
if command -v docker >/dev/null 2>&1; then
    echo -e "\033[0;36m🐳 DOCKER\033[0m"
    running=$(docker ps -q | wc -l)
    total=$(docker ps -aq | wc -l)
    echo "  Conteneurs: $running en cours / $total au total"
    if [ "$running" -gt 0 ]; then
        echo "  En cours:"
        docker ps --format "    - {{.Names}} ({{.Status}})"
    fi
    echo ""
else
    echo -e "\033[1;33m🐳 DOCKER\033[0m: Non installé"
    echo ""
fi

# QEMU/KVM
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo -e "\033[0;36m⚡ QEMU/KVM\033[0m"
    qemu_count=$(pgrep -f qemu-system | wc -l)
    echo "  VMs en cours: $qemu_count"
    if [ "$qemu_count" -gt 0 ]; then
        echo "  Processus:"
        ps aux | grep qemu-system | grep -v grep | awk '{print "    - PID", $2, "(" $11 ")"}'
    fi
    echo ""
else
    echo -e "\033[1;33m⚡ QEMU/KVM\033[0m: Non installé"
    echo ""
fi

# libvirt
if command -v virsh >/dev/null 2>&1; then
    echo -e "\033[0;36m🔧 LIBVIRT\033[0m"
    if virsh list >/dev/null 2>&1; then
        running_vms=$(virsh list --state-running --name 2>/dev/null | wc -l)
        total_vms=$(virsh list --all --name 2>/dev/null | wc -l)
        echo "  VMs: $running_vms en cours / $total_vms au total"
        if [ "$running_vms" -gt 0 ]; then
            echo "  En cours:"
            virsh list --state-running --name 2>/dev/null | sed 's/^/    - /'
        fi
    else
        echo "  ⚠️  libvirtd non démarré ou permissions insuffisantes"
    fi
    echo ""
else
    echo -e "\033[1;33m🔧 LIBVIRT\033[0m: Non installé"
    echo ""
fi

# LXC
if command -v lxc >/dev/null 2>&1 || command -v lxc-ls >/dev/null 2>&1; then
    echo -e "\033[0;36m📦 LXC\033[0m"
    if command -v lxc >/dev/null 2>&1; then
        running_lxc=$(lxc list --format csv -c s 2>/dev/null | grep RUNNING | wc -l)
        total_lxc=$(lxc list --format csv -c s 2>/dev/null | wc -l)
        echo "  Conteneurs: $running_lxc en cours / $total_lxc au total"
    else
        running_lxc=$(lxc-ls --running 2>/dev/null | wc -l)
        total_lxc=$(lxc-ls 2>/dev/null | wc -l)
        echo "  Conteneurs: $running_lxc en cours / $total_lxc au total"
    fi
    echo ""
else
    echo -e "\033[1;33m📦 LXC\033[0m: Non installé"
    echo ""
fi

# Vagrant
if command -v vagrant >/dev/null 2>&1; then
    echo -e "\033[0;36m🚀 VAGRANT\033[0m"
    vagrant_vms=$(vagrant global-status --prune 2>/dev/null | grep -c "running\|saved\|poweroff" || echo "0")
    echo "  VMs: $vagrant_vms trouvées"
    if [ "$vagrant_vms" -gt 0 ]; then
        echo "  État:"
        vagrant global-status --prune 2>/dev/null | grep -E "running|saved|poweroff" | head -5 | sed 's/^/    /'
    fi
    echo ""
else
    echo -e "\033[1;33m🚀 VAGRANT\033[0m: Non installé"
    echo ""
fi

echo "══════════════════════════════════════════════════════════════════"
echo ""
log_info "Utilisez 'virtman <module>' pour gérer un type spécifique"
echo ""

read -k 1 "?Appuyez sur une touche pour continuer... "

