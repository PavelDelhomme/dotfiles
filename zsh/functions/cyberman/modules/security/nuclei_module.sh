#!/bin/zsh
# =============================================================================
# NUCLEI MODULE - Module complet pour Nuclei Scanner
# =============================================================================
# Description: Intégration complète de Nuclei avec toutes ses fonctionnalités
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger les dépendances
CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyber}"
CYBERMAN_DIR="${CYBERMAN_DIR:-$HOME/dotfiles/zsh/functions/cyberman}"

if [ -f "$CYBER_DIR/target_manager.sh" ]; then
    source "$CYBER_DIR/target_manager.sh"
fi
if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
    source "$CYBER_DIR/environment_manager.sh"
fi
if [ -f "$CYBER_DIR/utils/ensure_tool.sh" ]; then
    source "$CYBER_DIR/utils/ensure_tool.sh"
fi

# Répertoires
NUCLEI_TEMPLATES_DIR="${HOME}/nuclei-templates"
NUCLEI_CUSTOM_TEMPLATES_DIR="${HOME}/.cyberman/templates/nuclei"
NUCLEI_SCANS_DIR="${HOME}/.cyberman/scans/nuclei"
mkdir -p "$NUCLEI_CUSTOM_TEMPLATES_DIR" "$NUCLEI_SCANS_DIR"

# DESC: Vérifie et installe Nuclei si nécessaire
# USAGE: ensure_nuclei
ensure_nuclei() {
    if ! command -v nuclei >/dev/null 2>&1; then
        echo "📦 Installation de Nuclei..."
        if command -v yay >/dev/null 2>&1; then
            yay -S --noconfirm nuclei
        elif command -v pacman >/dev/null 2>&1; then
            echo "⚠️  Nuclei n'est pas disponible via pacman"
            echo "💡 Installez-le via: yay -S nuclei"
            return 1
        else
            echo "⚠️  Gestionnaire de paquets non détecté"
            return 1
        fi
    fi
    
    # Mettre à jour les templates si nécessaire
    if [ -d "$NUCLEI_TEMPLATES_DIR" ]; then
        echo "🔄 Mise à jour des templates Nuclei..."
        nuclei -update-templates 2>/dev/null || true
    fi
    
    return 0
}

# DESC: Scan Nuclei rapide (vulnérabilités communes)
# USAGE: nuclei_quick_scan <target>
# EXAMPLE: nuclei_quick_scan https://example.com
nuclei_quick_scan() {
    local target="$1"
    
    if [ -z "$target" ]; then
        if has_targets 2>/dev/null; then
            target=$(prompt_target "🎯 Cible pour scan Nuclei rapide: ")
        else
            target=$(prompt_target "🎯 Cible pour scan Nuclei rapide: ")
        fi
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    ensure_nuclei || return 1
    
    local output_file="$NUCLEI_SCANS_DIR/quick-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Scan Nuclei rapide sur: $target"
    echo "📁 Résultats: $output_file"
    echo ""
    
    nuclei -u "$target" \
        -t exposures/ \
        -t misconfiguration/ \
        -t default-logins/ \
        -severity critical,high \
        -o "$output_file" \
        -stats \
        -silent
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats:"
        cat "$output_file"
        
        # Sauvegarder dans l'environnement actif si disponible
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "nuclei_quick" "Nuclei quick scan sur $target" "$(cat "$output_file")" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune vulnérabilité trouvée"
    fi
    
    return 0
}

# DESC: Scan Nuclei CVE (vulnérabilités CVE)
# USAGE: nuclei_cve_scan <target>
# EXAMPLE: nuclei_cve_scan https://example.com
nuclei_cve_scan() {
    local target="$1"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 Cible pour scan Nuclei CVE: ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    ensure_nuclei || return 1
    
    local output_file="$NUCLEI_SCANS_DIR/cve-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Scan Nuclei CVE sur: $target"
    echo "📁 Résultats: $output_file"
    echo ""
    
    nuclei -u "$target" \
        -t cves/ \
        -severity critical,high,medium \
        -o "$output_file" \
        -stats \
        -silent
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats:"
        cat "$output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "nuclei_cve" "Nuclei CVE scan sur $target" "$(cat "$output_file")" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune CVE trouvée"
    fi
    
    return 0
}

# DESC: Scan Nuclei XSS (vulnérabilités XSS)
# USAGE: nuclei_xss_scan <target>
# EXAMPLE: nuclei_xss_scan https://example.com
nuclei_xss_scan() {
    local target="$1"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 Cible pour scan Nuclei XSS: ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    ensure_nuclei || return 1
    
    local output_file="$NUCLEI_SCANS_DIR/xss-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Scan Nuclei XSS sur: $target"
    echo "📁 Résultats: $output_file"
    echo ""
    
    nuclei -u "$target" \
        -tags xss \
        -severity critical,high,medium \
        -o "$output_file" \
        -stats \
        -silent
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats:"
        cat "$output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "nuclei_xss" "Nuclei XSS scan sur $target" "$(cat "$output_file")" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune vulnérabilité XSS trouvée"
    fi
    
    return 0
}

# DESC: Scan Nuclei SQL Injection
# USAGE: nuclei_sqli_scan <target>
# EXAMPLE: nuclei_sqli_scan https://example.com
nuclei_sqli_scan() {
    local target="$1"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 Cible pour scan Nuclei SQLi: ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    ensure_nuclei || return 1
    
    local output_file="$NUCLEI_SCANS_DIR/sqli-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Scan Nuclei SQL Injection sur: $target"
    echo "📁 Résultats: $output_file"
    echo ""
    
    nuclei -u "$target" \
        -tags sqli \
        -severity critical,high,medium \
        -o "$output_file" \
        -stats \
        -silent
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats:"
        cat "$output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "nuclei_sqli" "Nuclei SQLi scan sur $target" "$(cat "$output_file")" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune vulnérabilité SQLi trouvée"
    fi
    
    return 0
}

# DESC: Scan Nuclei complet (tous les templates)
# USAGE: nuclei_full_scan <target>
# EXAMPLE: nuclei_full_scan https://example.com
nuclei_full_scan() {
    local target="$1"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 Cible pour scan Nuclei complet: ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    ensure_nuclei || return 1
    
    local output_file="$NUCLEI_SCANS_DIR/full-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Scan Nuclei complet sur: $target"
    echo "⚠️  Ce scan peut prendre du temps..."
    echo "📁 Résultats: $output_file"
    echo ""
    
    nuclei -u "$target" \
        -t "$NUCLEI_TEMPLATES_DIR" \
        -severity critical,high,medium,low \
        -o "$output_file" \
        -stats \
        -rate-limit 150
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats:"
        cat "$output_file" | head -100
        echo ""
        echo "📊 Total de lignes: $(wc -l < "$output_file")"
        echo "📁 Fichier complet: $output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "nuclei_full" "Nuclei full scan sur $target" "Résultats dans: $output_file" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune vulnérabilité trouvée"
    fi
    
    return 0
}

# DESC: Scan Nuclei avec templates personnalisés
# USAGE: nuclei_custom_scan <target> <template_path>
# EXAMPLE: nuclei_custom_scan https://example.com ~/.cyberman/templates/nuclei/
nuclei_custom_scan() {
    local target="$1"
    local template_path="$2"
    
    if [ -z "$target" ]; then
        target=$(prompt_target "🎯 Cible pour scan Nuclei personnalisé: ")
        if [ -z "$target" ]; then
            echo "❌ Aucune cible spécifiée"
            return 1
        fi
    fi
    
    if [ -z "$template_path" ]; then
        template_path="$NUCLEI_CUSTOM_TEMPLATES_DIR"
        echo "💡 Utilisation des templates personnalisés: $template_path"
    fi
    
    if [ ! -d "$template_path" ]; then
        echo "❌ Répertoire de templates introuvable: $template_path"
        return 1
    fi
    
    ensure_nuclei || return 1
    
    local output_file="$NUCLEI_SCANS_DIR/custom-$(date +%Y%m%d-%H%M%S).txt"
    
    echo "🔍 Scan Nuclei avec templates personnalisés sur: $target"
    echo "📁 Templates: $template_path"
    echo "📁 Résultats: $output_file"
    echo ""
    
    nuclei -u "$target" \
        -t "$template_path" \
        -severity critical,high,medium \
        -o "$output_file" \
        -stats \
        -silent
    
    if [ -f "$output_file" ] && [ -s "$output_file" ]; then
        echo ""
        echo "✅ Scan terminé. Résultats:"
        cat "$output_file"
        
        # Sauvegarder dans l'environnement actif
        if has_active_environment 2>/dev/null; then
            local env_name=$(get_current_environment 2>/dev/null)
            if [ -f "$CYBER_DIR/helpers/auto_save_helper.sh" ]; then
                source "$CYBER_DIR/helpers/auto_save_helper.sh" 2>/dev/null
                auto_save_recon_result "nuclei_custom" "Nuclei custom scan sur $target" "$(cat "$output_file")" "success" 2>/dev/null
            fi
        fi
    else
        echo "⚠️  Aucune vulnérabilité trouvée"
    fi
    
    return 0
}

# DESC: Met à jour les templates Nuclei
# USAGE: nuclei_update_templates
nuclei_update_templates() {
    ensure_nuclei || return 1
    
    echo "🔄 Mise à jour des templates Nuclei..."
    nuclei -update-templates
    
    if [ $? -eq 0 ]; then
        echo "✅ Templates mis à jour avec succès"
        return 0
    else
        echo "❌ Erreur lors de la mise à jour des templates"
        return 1
    fi
}

# DESC: Liste les templates Nuclei disponibles
# USAGE: nuclei_list_templates [filter]
# EXAMPLE: nuclei_list_templates xss
nuclei_list_templates() {
    local filter="$1"
    
    ensure_nuclei || return 1
    
    if [ -n "$filter" ]; then
        echo "📋 Templates Nuclei (filtre: $filter):"
        nuclei -tl | grep -i "$filter"
    else
        echo "📋 Tous les templates Nuclei disponibles:"
        nuclei -tl
    fi
}

# DESC: Crée un template Nuclei personnalisé
# USAGE: nuclei_create_template <template_name>
# EXAMPLE: nuclei_create_template custom-xss
nuclei_create_template() {
    local template_name="$1"
    
    if [ -z "$template_name" ]; then
        printf "📝 Nom du template: "
        read -r template_name
        if [ -z "$template_name" ]; then
            echo "❌ Nom requis"
            return 1
        fi
    fi
    
    local template_file="$NUCLEI_CUSTOM_TEMPLATES_DIR/${template_name}.yaml"
    
    if [ -f "$template_file" ]; then
        printf "⚠️  Le template existe déjà. Remplacer? (o/N): "
        read -r confirm
        if [ "$confirm" != "o" ] && [ "$confirm" != "O" ]; then
            return 1
        fi
    fi
    
    # Template de base
    cat > "$template_file" <<EOF
id: $template_name

info:
  name: $(echo "$template_name" | tr '_' ' ' | sed 's/\b\(.\)/\u\1/g')
  author: $(whoami)
  severity: medium
  description: Template personnalisé créé le $(date '+%Y-%m-%d')
  tags: custom

requests:
  - method: GET
    path:
      - "{{BaseURL}}"
    
    matchers:
      - type: word
        words:
          - "vulnerable"
          - "error"
        condition: or
EOF
    
    echo "✅ Template créé: $template_file"
    echo "💡 Éditez-le avec: \$EDITOR $template_file"
    
    return 0
}

# DESC: Affiche le menu Nuclei
# USAGE: show_nuclei_menu
show_nuclei_menu() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    while true; do
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    NUCLEI SCANNER - CYBERMAN                   ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
        echo ""
        
        echo "1.  🔍 Scan rapide (vulnérabilités communes)"
        echo "2.  🔍 Scan CVE (vulnérabilités CVE)"
        echo "3.  🔍 Scan XSS (vulnérabilités XSS)"
        echo "4.  🔍 Scan SQL Injection (vulnérabilités SQLi)"
        echo "5.  🔍 Scan complet (tous les templates)"
        echo "6.  🔍 Scan avec templates personnalisés"
        echo "7.  📋 Lister les templates disponibles"
        echo "8.  📝 Créer un template personnalisé"
        echo "9.  🔄 Mettre à jour les templates"
        echo "10. 🔍 Rechercher des templates"
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                nuclei_quick_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                nuclei_cve_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                nuclei_xss_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                nuclei_sqli_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                echo ""
                printf "⚠️  Le scan complet peut prendre beaucoup de temps. Continuer? (o/N): "
                read -r confirm
                if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                    nuclei_full_scan
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                echo ""
                printf "📁 Chemin des templates personnalisés (défaut: $NUCLEI_CUSTOM_TEMPLATES_DIR): "
                read -r custom_path
                nuclei_custom_scan "" "${custom_path:-$NUCLEI_CUSTOM_TEMPLATES_DIR}"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7)
                echo ""
                nuclei_list_templates
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8)
                echo ""
                nuclei_create_template
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9)
                echo ""
                nuclei_update_templates
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            10)
                echo ""
                printf "🔍 Terme de recherche: "
                read -r search_term
                if [ -n "$search_term" ]; then
                    nuclei_list_templates "$search_term"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
}

