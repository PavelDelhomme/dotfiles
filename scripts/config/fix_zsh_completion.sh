#!/usr/bin/env bash
# Répare la complétion zsh (Tab) quand comptags/comptry sont introuvables.
# Cause fréquente : .zcompdump corrompu (quota disque, double compinit).
# Usage : bash ~/dotfiles/scripts/config/fix_zsh_completion.sh

set -euo pipefail

echo "Suppression des dumps de complétion zsh (anciens + cache)…"
rm -f \
    "${ZDOTDIR:-$HOME}/.zcompdump" \
    "${ZDOTDIR:-$HOME}/.zcompdump".zwc \
    "${ZDOTDIR:-$HOME}"/.zcompdump-* \
    "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"/zcompdump-* \
    2>/dev/null || true

ZDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$(hostname -s 2>/dev/null || echo local)-${ZSH_VERSION:-$(zsh --version 2>/dev/null | awk '{print $2}')}"
mkdir -p "$(dirname "$ZDUMP")" 2>/dev/null || true

echo "Régénération via compinit (dump → $ZDUMP)…"
zsh -f -c "
  export ZSH_COMPDUMP='$ZDUMP'
  autoload -Uz compinit
  compinit -u -D -d \"\$ZSH_COMPDUMP\"
  if whence comptags >/dev/null 2>&1 && whence comptry >/dev/null 2>&1; then
    print -r 'OK: comptags et comptry disponibles.'
  else
    print -ru2 'ERREUR: complétion toujours cassée après compinit.'
    print -ru2 'Vérifiez le quota disque (btrfs qgroup) — cause fréquente de dumps tronqués.'
    exit 1
  fi
"

echo ""
echo "Rechargez le shell : exec zsh"
echo "Puis testez : tapez « ls » + Tab (doit compléter sans erreur)."
