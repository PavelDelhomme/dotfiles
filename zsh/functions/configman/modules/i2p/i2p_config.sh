#!/usr/bin/env bash
# configman i2p — configuration i2pd / I2P (non destructif par défaut)
# USAGE: bash .../i2p_config.sh [--status|--show|--ports|--dry-run|--apply-user]
set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
USER_I2PD_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/i2pd"
USER_CONF="$USER_I2PD_DIR/i2pd.conf"
SYS_CONFS="/etc/i2pd/i2pd.conf /usr/share/i2pd/i2pd.conf"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

usage() {
    printf "${CYAN}${BOLD}configman i2p${RESET}\n\n"
    echo "  --status / status     service i2pd + binaires"
    echo "  --show / show         chemins de config détectés"
    echo "  --ports / ports       ports HTTP/SOCKS/console typiques"
    echo "  --dry-run             prévisualiser un fragment user conf"
    echo "  --apply-user          écrire $USER_CONF (backup si existe)"
    echo "  help / -h             cette aide"
    echo ""
    echo "Liens : installman i2p · anonyman i2p · netman i2p"
}

cmd_status() {
    printf "${CYAN}I2P / i2pd — statut${RESET}\n\n"
    if command -v i2pd >/dev/null 2>&1; then
        printf "  binaire : ${GREEN}%s${RESET}\n" "$(command -v i2pd)"
        i2pd --version 2>/dev/null | head -n1 || true
    else
        printf "  binaire : ${YELLOW}absent${RESET} — installman i2p\n"
    fi
    if command -v systemctl >/dev/null 2>&1; then
        st=$(systemctl is-active i2pd 2>/dev/null || echo inactive)
        en=$(systemctl is-enabled i2pd 2>/dev/null || echo disabled)
        printf "  systemd : %s (enabled: %s)\n" "$st" "$en"
    fi
    [ -f "$USER_CONF" ] && printf "  user conf : %s\n" "$USER_CONF"
}

cmd_show() {
    printf "${CYAN}Configs I2P détectées${RESET}\n\n"
    for f in $SYS_CONFS "$USER_CONF"; do
        if [ -f "$f" ]; then
            printf "  ${GREEN}✓${RESET} %s\n" "$f"
        else
            printf "  · %s (absent)\n" "$f"
        fi
    done
}

cmd_ports() {
    echo "HTTP outproxy / proxy  : 127.0.0.1:4444"
    echo "SOCKS                  : 127.0.0.1:4447"
    echo "Web console (souvent)  : 127.0.0.1:7070"
    echo "SAM / BOB              : selon i2pd.conf"
    echo ""
    echo "Ne pas exposer ces ports hors localhost sans firewall."
}

fragment_user_conf() {
    cat <<'EOF'
# Fragment généré par configman i2p (user) — labo / privacy
# Doc : man i2pd · https://i2pd.readthedocs.io/

log = file
loglevel = warn

[http]
enabled = true
address = 127.0.0.1
port = 4444

[httpproxy]
enabled = true
address = 127.0.0.1
port = 4444

[socksproxy]
enabled = true
address = 127.0.0.1
port = 4447

[sam]
enabled = false
EOF
}

cmd_dry_run() {
    printf "${CYAN}--dry-run : fragment vers %s${RESET}\n\n" "$USER_CONF"
    fragment_user_conf
}

cmd_apply_user() {
    mkdir -p "$USER_I2PD_DIR"
    if [ -f "$USER_CONF" ]; then
        cp -a "$USER_CONF" "$USER_CONF.bak.$(date +%Y%m%d%H%M%S)"
        printf "${YELLOW}Backup:${RESET} %s.bak.*\n" "$USER_CONF"
    fi
    fragment_user_conf >"$USER_CONF"
    printf "${GREEN}Écrit:${RESET} %s\n" "$USER_CONF"
    printf "Redémarre i2pd si besoin : anonyman i2p enable  (ou systemctl restart i2pd)\n"
    printf "${YELLOW}Note:${RESET} selon packaging, i2pd lit /etc/i2pd/ — adapte ou symlink.\n"
}

case "${1:-status}" in
    help|-h|--help) usage ;;
    status|--status) cmd_status ;;
    show|--show) cmd_show ;;
    ports|--ports) cmd_ports ;;
    --dry-run|dry-run) cmd_dry_run ;;
    --apply-user|apply-user|apply) cmd_apply_user ;;
    *)
        printf "${RED}Option inconnue:${RESET} %s\n\n" "$1" >&2
        usage
        exit 1
        ;;
esac
