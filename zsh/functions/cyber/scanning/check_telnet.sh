#!/bin/zsh
# =============================================================================
# CHECK_TELNET - Vérifie si telnet est actif sur une cible
# =============================================================================
# DESC: Vérifie si le service telnet est actif et accessible sur une cible en testant le port 23 et en tentant une connexion.
# USAGE: check_telnet [target] [port]
# EXAMPLE: check_telnet 192.168.1.1
# EXAMPLE: check_telnet example.com 23
# EXAMPLE: check_telnet  # Utilise les cibles configurées
check_telnet() {
    # Charger le gestionnaire de cibles
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    local target=""
    local port="${2:-23}"
    
    if [ $# -gt 0 ]; then
        target="$1"
        [ -n "$2" ] && port="$2"
    elif has_targets; then
        echo "🎯 Utilisation des cibles configurées:"
        show_targets
        echo ""
        printf "Utiliser toutes les cibles? (O/n): "
        read -r use_all
        if [ "$use_all" != "n" ] && [ "$use_all" != "N" ]; then
            # Utiliser toutes les cibles
            for t in "${CYBER_TARGETS[@]}"; do
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🎯 Vérification Telnet: $t"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                check_telnet_single "$t" "$port"
            done
            return 0
        else
            target=$(prompt_target "🎯 Entrez la cible: ")
            if [ -z "$target" ]; then
                return 1
            fi
        fi
    else
        target=$(prompt_target "🎯 Entrez la cible (IP ou domaine): ")
        if [ -z "$target" ]; then
            return 1
        fi
    fi
    
    check_telnet_single "$target" "$port"
}

# Fonction interne pour vérifier une seule cible
check_telnet_single() {
    local target="$1"
    local port="${2:-23}"
    
    if [ -z "$target" ]; then
        echo "❌ Usage: check_telnet <target> [port]"
        return 1
    fi
    
    echo "🔍 Vérification Telnet pour $target:$port"
    echo ""
    
    # Méthode 1: Vérifier si le port est ouvert avec nc (netcat)
    if command -v nc >/dev/null 2>&1; then
        echo "📡 Test de connexion au port $port..."
        if timeout 3 nc -zv "$target" "$port" 2>&1 | grep -q "succeeded\|open"; then
            echo "✅ Port $port ouvert"
            local port_open=true
        else
            echo "❌ Port $port fermé ou inaccessible"
            local port_open=false
        fi
        echo ""
    elif command -v nmap >/dev/null 2>&1; then
        echo "📡 Scan du port $port avec nmap..."
        if nmap -p "$port" "$target" 2>/dev/null | grep -q "$port.*open"; then
            echo "✅ Port $port ouvert"
            local port_open=true
        else
            echo "❌ Port $port fermé ou inaccessible"
            local port_open=false
        fi
        echo ""
    else
        echo "⚠️  nc (netcat) ou nmap non disponible pour vérifier le port"
        local port_open="unknown"
    fi
    
    # Méthode 2: Tenter une connexion telnet réelle
    echo "🔌 Tentative de connexion Telnet..."
    if command -v telnet >/dev/null 2>&1; then
        # Utiliser timeout pour éviter que telnet reste bloqué
        local telnet_output=$(timeout 5 telnet "$target" "$port" 2>&1 <<< "quit" || true)
        
        if echo "$telnet_output" | grep -qi "Connected\|Escape character\|Welcome\|login"; then
            echo "✅ Telnet ACTIF - Service accessible"
            echo ""
            echo "📋 Détails de la connexion:"
            echo "$telnet_output" | head -5
            return 0
        elif echo "$telnet_output" | grep -qi "Connection refused\|Connection timed out\|No route"; then
            echo "❌ Telnet INACTIF - Connexion refusée ou timeout"
            return 1
        else
            echo "⚠️  Réponse ambiguë - Vérification manuelle recommandée"
            echo "$telnet_output" | head -3
            return 2
        fi
    else
        echo "⚠️  Client telnet non installé"
        echo "💡 Installez-le: sudo pacman -S inetutils (Arch) ou sudo apt-get install telnet (Debian)"
        
        # Fallback: Utiliser bash avec /dev/tcp
        if [ "$port_open" = "true" ]; then
            echo ""
            echo "✅ Port $port ouvert - Telnet probablement actif"
            echo "💡 Pour confirmer, installez telnet et testez manuellement"
            return 0
        elif [ "$port_open" = "false" ]; then
            echo ""
            echo "❌ Port $port fermé - Telnet probablement inactif"
            return 1
        else
            echo ""
            echo "⚠️  Impossible de déterminer l'état de Telnet"
            return 2
        fi
    fi
}

