#!/bin/zsh
# =============================================================================
# ASSISTANT - Assistant de test complet pour cyberman
# =============================================================================
# Description: Guide l'utilisateur à travers un test de sécurité complet
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# DESC: Assistant interactif pour guider l'utilisateur dans les tests
# USAGE: show_assistant
# EXAMPLE: show_assistant
show_assistant() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              ASSISTANT DE TEST DE SÉCURITÉ                     ║"
    echo "║              Guide interactif pour cyberman                    ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo ""
    
    echo "🎯 Cet assistant va vous guider à travers un test de sécurité complet."
    echo ""
    echo "Étapes:"
    echo "  1. Configuration des cibles"
    echo "  2. Configuration de l'anonymat (optionnel)"
    echo "  3. Création/sélection d'un environnement"
    echo "  4. Création/sélection d'un workflow"
    echo "  5. Exécution des tests"
    echo "  6. Consultation des rapports"
    echo ""
    
    printf "Commencer? (O/n): "
    read -r start
    if [ "$start" = "n" ] || [ "$start" = "N" ]; then
        return 0
    fi
    
    # Étape 1: Cibles
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ÉTAPE 1: Configuration des cibles"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    
    if ! has_targets; then
        echo "Aucune cible configurée. Ajoutons-en..."
        echo ""
        while true; do
            printf "🎯 Entrez une cible (IP, domaine ou URL) [vide pour terminer]: "
            read -r target
            if [ -z "$target" ]; then
                break
            fi
            add_target "$target"
        done
    else
        echo "Cibles actuelles:"
        show_targets
        echo ""
        printf "Utiliser ces cibles? (O/n): "
        read -r use_current
        if [ "$use_current" = "n" ] || [ "$use_current" = "N" ]; then
            clear_targets
            while true; do
                printf "🎯 Entrez une cible [vide pour terminer]: "
                read -r target
                if [ -z "$target" ]; then
                    break
                fi
                add_target "$target"
            done
        fi
    fi
    
    if ! has_targets; then
        echo "❌ Aucune cible configurée. Assistant annulé."
        return 1
    fi
    
    # Étape 2: Anonymat
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ÉTAPE 2: Configuration de l'anonymat"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    local use_anonymity=false
    
    printf "Utiliser l'anonymat (Tor)? (o/N): "
    read -r use_anon
    if [ "$use_anon" = "o" ] || [ "$use_anon" = "O" ]; then
        use_anonymity=true
        
        if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
            source "$CYBER_DIR/anonymity_manager.sh"
        fi
        
        # Vérifier Tor
        if ! pgrep -x tor >/dev/null 2>&1; then
            echo "Tor n'est pas actif. Démarrage..."
            if [ -f "$CYBER_DIR/privacy/start_tor.sh" ]; then
                source "$CYBER_DIR/privacy/start_tor.sh"
                start_tor
            fi
        fi
        
        # Vérifier l'anonymat
        echo ""
        check_anonymity
    fi
    
    # Étape 3: Environnement
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ÉTAPE 3: Gestion de l'environnement"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
        source "$CYBER_DIR/environment_manager.sh"
    fi
    
    printf "Sauvegarder l'environnement actuel? (O/n): "
    read -r save_env
    if [ "$save_env" != "n" ] && [ "$save_env" != "N" ]; then
        printf "📝 Nom de l'environnement: "
        read -r env_name
        if [ -n "$env_name" ]; then
            printf "📝 Description: "
            read -r env_desc
            save_environment "$env_name" "$env_desc"
        fi
    fi
    
    # Étape 4: Workflow
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ÉTAPE 4: Gestion du workflow"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
        source "$CYBER_DIR/workflow_manager.sh"
    fi
    
    local workflow_name=""
    
    list_workflows 2>/dev/null
    echo ""
    echo "Options:"
    echo "  1. Utiliser un workflow existant"
    echo "  2. Créer un nouveau workflow"
    echo "  3. Exécuter des tests manuels (sans workflow)"
    echo ""
    printf "Choix: "
    read -r workflow_choice
    workflow_choice=$(echo "$workflow_choice" | tr -d '[:space:]')
    
    case "$workflow_choice" in
        1)
            printf "📝 Nom du workflow: "
            read -r workflow_name
            ;;
        2)
            printf "📝 Nom du nouveau workflow: "
            read -r new_workflow
            if [ -n "$new_workflow" ]; then
                printf "📝 Description: "
                read -r workflow_desc
                create_workflow "$new_workflow" "$workflow_desc"
                
                echo ""
                echo "Ajoutons des étapes au workflow..."
                echo "Types disponibles: recon, scan, vuln, attack, analysis"
                echo ""
                
                while true; do
                    printf "📝 Type d'étape [vide pour terminer]: "
                    read -r step_type
                    if [ -z "$step_type" ]; then
                        break
                    fi
                    
                    printf "📝 Nom de la fonction: "
                    read -r func_name
                    if [ -z "$func_name" ]; then
                        continue
                    fi
                    
                    printf "📝 Arguments (optionnel): "
                    read -r step_args
                    
                    add_workflow_step "$new_workflow" "$step_type" "$func_name" "$step_args"
                done
                
                workflow_name="$new_workflow"
            fi
            ;;
        3)
            workflow_name=""
            ;;
    esac
    
    # Étape 5: Exécution
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ÉTAPE 5: Exécution des tests"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ -n "$workflow_name" ]; then
        echo "🚀 Exécution du workflow: $workflow_name"
        echo ""
        
        if [ "$use_anonymity" = true ]; then
            if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                source "$CYBER_DIR/anonymity_manager.sh"
            fi
            run_workflow_anonymized "$workflow_name"
        else
            run_workflow "$workflow_name"
        fi
    else
        echo "🚀 Exécution de tests manuels"
        echo ""
        echo "Tests disponibles:"
        echo "  1. Reconnaissance complète"
        echo "  2. Scan de ports"
        echo "  3. Scan de vulnérabilités"
        echo "  4. Tout (recon + scan + vuln)"
        echo ""
        printf "Choix: "
        read -r test_choice
        test_choice=$(echo "$test_choice" | tr -d '[:space:]')
        
        case "$test_choice" in
            1)
                echo "🔍 Reconnaissance..."
                for target in "${CYBER_TARGETS[@]}"; do
                    source "$CYBER_DIR/reconnaissance/domain_whois.sh" && domain_whois "$target"
                    source "$CYBER_DIR/reconnaissance/dns_lookup.sh" && dns_lookup "$target"
                done
                ;;
            2)
                echo "🔎 Scan de ports..."
                for target in "${CYBER_TARGETS[@]}"; do
                    source "$CYBER_DIR/scanning/port_scan.sh" && port_scan "$target"
                done
                ;;
            3)
                echo "🛡️  Scan de vulnérabilités..."
                for target in "${CYBER_TARGETS[@]}"; do
                    source "$CYBER_DIR/vulnerability/nmap_vuln_scan.sh" && nmap_vuln_scan "$target"
                done
                ;;
            4)
                echo "🚀 Tests complets..."
                for target in "${CYBER_TARGETS[@]}"; do
                    echo "🎯 Cible: $target"
                    source "$CYBER_DIR/reconnaissance/domain_whois.sh" && domain_whois "$target"
                    source "$CYBER_DIR/scanning/port_scan.sh" && port_scan "$target"
                    source "$CYBER_DIR/vulnerability/nmap_vuln_scan.sh" && nmap_vuln_scan "$target"
                done
                ;;
        esac
    fi
    
    # Étape 6: Rapports
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ÉTAPE 6: Consultation des rapports"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    if [ -f "$CYBER_DIR/report_manager.sh" ]; then
        source "$CYBER_DIR/report_manager.sh"
    fi
    
    echo "📊 Rapports disponibles:"
    list_reports --recent 5
    echo ""
    printf "Afficher un rapport? (o/N): "
    read -r show_report
    if [ "$show_report" = "o" ] || [ "$show_report" = "O" ]; then
        printf "📝 Nom du rapport: "
        read -r report_name
        if [ -n "$report_name" ]; then
            show_report "$report_name"
        fi
    fi
    
    echo ""
    echo "✅ Assistant terminé!"
    echo ""
    echo "💡 Vous pouvez maintenant:"
    echo "  - Consulter les rapports: cyberman → Option 10"
    echo "  - Gérer les environnements: cyberman → Option 8"
    echo "  - Gérer les workflows: cyberman → Option 9"
    echo ""
}

