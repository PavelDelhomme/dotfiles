# Fonction pour effectuer un whois sur un domaine
# DESC: Effectue une recherche WHOIS sur un domaine pour obtenir des informations sur le propriétaire, le registrar, les serveurs DNS, etc. Utilise les cibles configurées si aucune n'est fournie.
# USAGE: domain_whois [domain]
# EXAMPLE: domain_whois example.com
# EXAMPLE: domain_whois  # Utilise les cibles configurées
function domain_whois() {
    # Couleurs
    local CYAN='\033[0;36m'
    local RESET='\033[0m'
    
    # Charger ensure_tool une seule fois au début
    local UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    local whois_available=false
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh" 2>/dev/null
        if ensure_tool whois; then
            whois_available=true
        else
            echo ""
            echo "❌ Impossible de continuer sans whois"
            return 1
        fi
    elif command -v whois >/dev/null 2>&1; then
        whois_available=true
    else
        echo "❌ whois non installé"
        echo "💡 Installez-le: sudo pacman -S whois"
        return 1
    fi
    
    # Charger le gestionnaire de cibles et le helper d'enregistrement
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyberman/modules/legacy"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
        source "$CYBER_DIR/helpers/auto_save_helper.sh"
    fi
    
    local target=""
    
    if [ $# -gt 0 ]; then
        target="$1"
    elif has_targets; then
        echo "🎯 Utilisation des cibles configurées:"
        show_targets
        echo ""
        printf "Utiliser toutes les cibles? (O/n): "
        read -r use_all
        if [ "$use_all" != "n" ] && [ "$use_all" != "N" ]; then
            # Utiliser toutes les cibles
            for t in "${CYBER_TARGETS[@]}"; do
                # Extraire le domaine si c'est une URL
                local domain="$t"
                if [[ "$t" =~ ^https?:// ]]; then
                    domain=$(echo "$t" | sed -E 's|^https?://||' | sed 's|/.*||')
                fi
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "🎯 WHOIS: $domain"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                if [ "$whois_available" = true ]; then
                    local whois_output=$(whois "$domain" 2>&1)
                    
                    # Filtrer et formater la sortie WHOIS
                    local formatted_output=$(echo "$whois_output" | grep -v "^%" | grep -v "^$" | grep -v "^# " | head -100)
                    
                    # Si c'est une IP, extraire les informations importantes
                    if [[ "$domain" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        echo -e "${CYAN}📋 Informations IP (RIPE/ARIN/APNIC):${RESET}\n"
                        echo "$formatted_output" | grep -E "^(inetnum|netname|descr|country|admin-c|tech-c|status|route|origin|mnt-by|created|last-modified|abuse-mailbox|address|phone|fax-no|nic-hdl|role|AS)" | head -30
                    else
                        echo -e "${CYAN}📋 Informations domaine:${RESET}\n"
                        echo "$formatted_output" | head -50
                    fi
                    
                    # Enregistrer automatiquement le résultat (sortie complète)
                    if typeset -f auto_save_recon_result >/dev/null 2>&1; then
                        auto_save_recon_result "whois" "WHOIS lookup pour $domain" "$whois_output" "success" 2>/dev/null
                        echo -e "${GREEN}✓ Résultats sauvegardés dans l'environnement actif${RESET}"
                    fi
                fi
                echo ""
            done
            # Ne pas faire return ici, laisser cyberman gérer le retour au menu
        else
            target=$(prompt_target "🎯 Entrez le domaine: ")
            if [ -z "$target" ]; then
                return 1
            fi
        fi
    else
        target=$(prompt_target "🎯 Entrez le domaine: ")
        if [ -z "$target" ]; then
            return 1
        fi
    fi
    
    # Extraire le domaine si c'est une URL
    local domain="$target"
    if [[ "$target" =~ ^https?:// ]]; then
        domain=$(echo "$target" | sed -E 's|^https?://||' | sed 's|/.*||')
    fi
    
    echo "🔍 WHOIS pour: $domain"
    echo ""
    
    # whois devrait déjà être disponible (vérifié au début)
    if [ "$whois_available" = true ]; then
        local whois_output=$(whois "$domain" 2>&1)
        
        # Filtrer et formater la sortie WHOIS
        local formatted_output=$(echo "$whois_output" | grep -v "^%" | grep -v "^$" | grep -v "^# " | head -100)
        
        # Si c'est une IP, extraire les informations importantes
        if [[ "$domain" =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
            echo -e "${CYAN}📋 Informations IP (RIPE/ARIN/APNIC):${RESET}\n"
            echo "$formatted_output" | grep -E "^(inetnum|netname|descr|country|admin-c|tech-c|status|route|origin|mnt-by|created|last-modified|abuse-mailbox|address|phone|fax-no|nic-hdl|role|AS)" | head -30
        else
            echo -e "${CYAN}📋 Informations domaine:${RESET}\n"
            echo "$formatted_output" | head -50
        fi
        
        # Enregistrer automatiquement le résultat dans l'environnement actif (sortie complète)
        if typeset -f auto_save_recon_result >/dev/null 2>&1; then
            auto_save_recon_result "whois" "WHOIS lookup pour $domain" "$whois_output" "success" 2>/dev/null
            echo -e "${GREEN}✓ Résultats sauvegardés dans l'environnement actif${RESET}"
        fi
        
        echo ""
        # Ne pas faire return ici, laisser cyberman gérer le retour au menu
    else
        return 1
    fi
}
