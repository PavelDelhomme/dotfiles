#!/bin/zsh
# =============================================================================
# SSH AUTO SETUP - Fonction wrapper pour configuration SSH automatique
# =============================================================================
# Description: Fonction ZSH pour configurer automatiquement SSH avec mot de passe depuis .env
# Usage: ssh_auto_setup [host_name] [host_ip] [user] [port]
# Example: ssh_auto_setup pavel-server 95.111.227.204 pavel 22
# =============================================================================

ssh_auto_setup() {
    local host_name="${1:-pavel-server}"
    local host_ip="${2:-95.111.227.204}"
    local user="${3:-pavel}"
    local port="${4:-22}"
    
    # Essayer d'abord sshman, puis configman en fallback
    local script_path="$HOME/dotfiles/zsh/functions/sshman/modules/ssh_auto_setup.sh"
    
    if [ ! -f "$script_path" ]; then
        script_path="$HOME/dotfiles/zsh/functions/configman/modules/ssh/ssh_auto_setup.sh"
    fi
    
    if [ -f "$script_path" ]; then
        bash "$script_path" "$host_name" "$host_ip" "$user" "$port"
    else
        echo "❌ Script ssh_auto_setup.sh non trouvé"
        echo "💡 Essayez: sshman auto-setup"
        return 1
    fi
}

# Alias pour faciliter l'utilisation
alias ssh-auto='ssh_auto_setup'
alias sshauto='ssh_auto_setup'

