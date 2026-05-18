#!/usr/bin/env bash
# Mise à jour Debian sur le VPS (via SSH). À lancer après sauvegarde / snapshot.
set -euo pipefail

HOST="${VPS_SSH_HOST:-pavel-server}"

echo "→ Mise à jour $HOST (apt update + full-upgrade)…"
echo "  Astuce : lancez d'abord scripts/ssh/vps_backup.sh"
read -r -p "Continuer ? [o/N] " ans
case "$ans" in
    [oOyY]) ;;
    *) echo "Annulé."; exit 0 ;;
esac

ssh -t "$HOST" 'sudo apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y && sudo apt-get autoremove -y && echo "" && echo "=== noyau actuel ===" && uname -r && echo "=== redémarrage conseillé si le noyau a changé ==="'

echo "✓ Upgrade terminé. Si le noyau a changé : ssh $HOST puis sudo reboot"
