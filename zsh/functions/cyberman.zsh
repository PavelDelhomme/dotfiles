#!/bin/zsh
# =============================================================================
# CYBERMAN - Cyber Security Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des outils de sécurité cyber
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Charger la fonction utilitaire ensure_tool
UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
    source "$UTILS_DIR/ensure_tool.sh"
fi

# Charger le gestionnaire de cibles
CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
if [ -f "$CYBER_DIR/target_manager.sh" ]; then
    source "$CYBER_DIR/target_manager.sh"
fi

# DESC: Gestionnaire interactif complet pour les outils de cybersécurité. Organise les outils en catégories : reconnaissance, scanning, vulnérabilités, attaques, analyse et privacy. Installe automatiquement les outils manquants.
# USAGE: cyberman [category]
# EXAMPLE: cyberman
# EXAMPLE: cyberman recon
# EXAMPLE: cyberman scan
cyberman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    local CYBER_DIR="$HOME/dotfiles/zsh/functions/cyber"
    
    # Charger tous les gestionnaires
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
    fi
    if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
        source "$CYBER_DIR/environment_manager.sh"
    fi
    if [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
        source "$CYBER_DIR/workflow_manager.sh"
    fi
    if [ -f "$CYBER_DIR/report_manager.sh" ]; then
        source "$CYBER_DIR/report_manager.sh"
    fi
    if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
        source "$CYBER_DIR/anonymity_manager.sh"
    fi
    if [ -f "$CYBER_DIR/management_menu.sh" ]; then
        source "$CYBER_DIR/management_menu.sh"
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  CYBERMAN - Cyber Security Manager             ║"
        echo "║                  Gestionnaire Sécurité Cyber ZSH              ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # =========================================================================
    # CATÉGORIE 1: RECONNAISSANCE & INFORMATION GATHERING
    # =========================================================================
    # DESC: Affiche le menu de reconnaissance et information gathering
    # USAGE: show_recon_menu
    # EXAMPLE: show_recon_menu
    show_recon_menu() {
        show_header
        echo -e "${YELLOW}🔍 RECONNAISSANCE & INFORMATION GATHERING${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  WHOIS domain              (Informations domaine)"
        echo "2.  DNS Lookup                (Requêtes DNS)"
        echo "3.  DNSEnum scan              (Énumération DNS)"
        echo "4.  Find subdomains           (Recherche sous-domaines)"
        echo "5.  Recon domain              (Reconnaissance complète domaine)"
        echo "6.  Enhanced traceroute       (Traceroute amélioré)"
        echo "7.  Network map               (Cartographie réseau)"
        echo "8.  Get HTTP headers          (En-têtes HTTP)"
        echo "9.  Analyze headers           (Analyse en-têtes)"
        echo "10. Get robots.txt            (Récupération robots.txt)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) 
                source "$CYBER_DIR/reconnaissance/domain_whois.sh" && domain_whois
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2) 
                source "$CYBER_DIR/reconnaissance/dns_lookup.sh" && dns_lookup
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3) 
                source "$CYBER_DIR/reconnaissance/dnsenum_scan.sh" && ensure_tool dnsenum && dnsenum_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4) 
                source "$CYBER_DIR/reconnaissance/find_subdomains.sh" && find_subdomains
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5) 
                source "$CYBER_DIR/reconnaissance/recon_domain.sh" && ensure_tool theHarvester && recon_domain
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6) 
                source "$CYBER_DIR/reconnaissance/enhanced_traceroute.sh" && enhanced_traceroute
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7) 
                source "$CYBER_DIR/reconnaissance/network_map.sh" && network_map
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8) 
                source "$CYBER_DIR/reconnaissance/get_http_headers.sh" && get_http_headers
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9) 
                source "$CYBER_DIR/reconnaissance/analyze_headers.sh" && analyze_headers
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            10) 
                source "$CYBER_DIR/reconnaissance/get_robots_txt.sh" && get_robots_txt
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            11) 
                source "$CYBER_DIR/scanning/check_telnet.sh" && check_telnet
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            12)
                if has_targets; then
                    echo "🔄 Reconnaissance sur toutes les cibles..."
                    for target in "${CYBER_TARGETS[@]}"; do
                        echo ""
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        echo "🎯 Cible: $target"
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        source "$CYBER_DIR/reconnaissance/domain_whois.sh" && domain_whois "$target"
                        source "$CYBER_DIR/reconnaissance/dns_lookup.sh" && dns_lookup "$target"
                        source "$CYBER_DIR/reconnaissance/get_http_headers.sh" && get_http_headers "$target"
                    done
                    echo ""
                    echo "✅ Reconnaissance terminée sur toutes les cibles"
                    read -k 1 "?Appuyez sur une touche pour continuer..."
                else
                    echo "❌ Aucune cible configurée. Utilisez le menu 'Gestion des cibles' d'abord."
                    sleep 2
                fi
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE 2: SCANNING & ENUMERATION
    # =========================================================================
    # DESC: Affiche le menu de scanning réseau
    # USAGE: show_scan_menu
    # EXAMPLE: show_scan_menu
    show_scan_menu() {
        show_header
        echo -e "${YELLOW}🔎 SCANNING & ENUMERATION${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Port scan                 (Scan de ports)"
        echo "2.  Scan ports                (Alternative scan ports)"
        echo "3.  Web port scan             (Scan ports web)"
        echo "4.  Scan web ports            (Alternative scan ports web)"
        echo "5.  Enum dirs                 (Énumération répertoires)"
        echo "6.  Enum shares               (Énumération partages)"
        echo "7.  Enumerate users           (Énumération utilisateurs)"
        echo "8.  Web dir enum              (Énumération répertoires web)"
        echo "9.  Network map               (Cartographie réseau)"
        echo "10. Check Telnet              (Vérifier si telnet est actif)"
        echo "11. Scan toutes les cibles    (Scan complet sur toutes les cibles)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) 
                source "$CYBER_DIR/scanning/port_scan.sh" && ensure_tool nmap && port_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2) 
                source "$CYBER_DIR/scanning/scan_ports.sh" && ensure_tool nmap && scan_ports
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3) 
                source "$CYBER_DIR/scanning/web_port_scan.sh" && ensure_tool nmap && web_port_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4) 
                source "$CYBER_DIR/scanning/scan_web_ports.sh" && ensure_tool nmap && scan_web_ports
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5) 
                source "$CYBER_DIR/scanning/enum_dirs.sh" && enum_dirs
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6) 
                source "$CYBER_DIR/scanning/enum_shares.sh" && enum_shares
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7) 
                source "$CYBER_DIR/scanning/enumerate_users.sh" && enumerate_users
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8) 
                source "$CYBER_DIR/scanning/web_dir_enum.sh" && ensure_tool gobuster && web_dir_enum
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9) 
                source "$CYBER_DIR/reconnaissance/network_map.sh" && network_map
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            10) 
                source "$CYBER_DIR/scanning/check_telnet.sh" && check_telnet
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            11)
                if has_targets; then
                    echo "🔄 Scan complet sur toutes les cibles..."
                    for target in "${CYBER_TARGETS[@]}"; do
                        echo ""
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        echo "🎯 Cible: $target"
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        source "$CYBER_DIR/scanning/port_scan.sh" && ensure_tool nmap && port_scan "$target"
                        source "$CYBER_DIR/scanning/web_dir_enum.sh" && ensure_tool gobuster && web_dir_enum "$target"
                    done
                else
                    echo "❌ Aucune cible configurée. Utilisez le menu 'Gestion des cibles' d'abord."
                    sleep 2
                fi
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE 3: VULNERABILITY ASSESSMENT
    # =========================================================================
    # DESC: Affiche le menu de scan de vulnérabilités
    # USAGE: show_vuln_menu
    # EXAMPLE: show_vuln_menu
    show_vuln_menu() {
        show_header
        echo -e "${YELLOW}🛡️ VULNERABILITY ASSESSMENT & SESSION${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Nmap vuln scan            (Scan vulnérabilités Nmap)"
        echo "2.  Vuln scan                 (Scan vulnérabilités général)"
        echo "3.  Scan vulns                (Alternative scan vulnérabilités)"
        echo "4.  Nikto scan                (Scan Nikto)"
        echo "5.  Web vuln scan             (Scan vulnérabilités web)"
        echo "6.  Check SSL                 (Vérification SSL)"
        echo "7.  Check SSL cert            (Vérification certificat SSL)"
        echo "8.  Check Heartbleed          (Vérification Heartbleed)"
        echo "9.  Scan vuln toutes cibles   (Scan vulnérabilités sur toutes les cibles)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) 
                source "$CYBER_DIR/vulnerability/nmap_vuln_scan.sh" && ensure_tool nmap && nmap_vuln_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2) 
                source "$CYBER_DIR/vulnerability/vuln_scan.sh" && vuln_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3) 
                source "$CYBER_DIR/vulnerability/scan_vulns.sh" && scan_vulns
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4) 
                source "$CYBER_DIR/vulnerability/nikto_scan.sh" && ensure_tool nikto && nikto_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5) 
                source "$CYBER_DIR/vulnerability/web_vuln_scan.sh" && web_vuln_scan
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6) 
                source "$CYBER_DIR/vulnerability/check_ssl.sh" && check_ssl
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7) 
                source "$CYBER_DIR/vulnerability/check_ssl_cert.sh" && check_ssl_cert
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8) 
                source "$CYBER_DIR/vulnerability/check_heartbleed.sh" && check_heartbleed
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9)
                if has_targets; then
                    echo "🔄 Scan de vulnérabilités sur toutes les cibles..."
                    for target in "${CYBER_TARGETS[@]}"; do
                        echo ""
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        echo "🎯 Cible: $target"
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        source "$CYBER_DIR/vulnerability/nmap_vuln_scan.sh" && ensure_tool nmap && nmap_vuln_scan "$target"
                        if [[ "$target" =~ ^https?:// ]]; then
                            source "$CYBER_DIR/vulnerability/nikto_scan.sh" && ensure_tool nikto && nikto_scan "$target"
                            source "$CYBER_DIR/vulnerability/check_ssl.sh" && check_ssl "$target"
                        fi
                    done
                    echo ""
                    echo "✅ Scan de vulnérabilités terminé sur toutes les cibles"
                    read -k 1 "?Appuyez sur une touche pour continuer..."
                else
                    echo "❌ Aucune cible configurée. Utilisez le menu 'Gestion des cibles' d'abord."
                    sleep 2
                fi
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE 4: NETWORK ATTACKS & EXPLOITATION
    # =========================================================================
    # DESC: Affiche le menu d'attaques réseau
    # USAGE: show_attack_menu
    # EXAMPLE: show_attack_menu
    show_attack_menu() {
        show_header
        echo -e "${YELLOW}⚔️ NETWORK ATTACKS & EXPLOITATION${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  ARP Spoof                 (Attaque ARP spoofing)"
        echo "2.  Brute SSH                 (Brute force SSH)"
        echo "3.  Password crack            (Cracking de mots de passe)"
        echo "4.  Deauth attack             (Attaque désauthentification Wi-Fi)"
        echo "5.  Web traceroute            (Traceroute web)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) source "$CYBER_DIR/attacks/arp_spoof.sh" && ensure_tool arpspoof && arp_spoof ;;
            2) source "$CYBER_DIR/attacks/brute_ssh.sh" && ensure_tool hydra && brute_ssh ;;
            3) source "$CYBER_DIR/attacks/password_crack.sh" && password_crack ;;
            4) source "$CYBER_DIR/attacks/deauth_attack.sh" && ensure_tool aireplay-ng && deauth_attack ;;
            5) source "$CYBER_DIR/attacks/web_traceroute.sh" && web_traceroute ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE 5: NETWORK ANALYSIS & MONITORING
    # =========================================================================
    # DESC: Affiche le menu d'analyse réseau
    # USAGE: show_analysis_menu
    # EXAMPLE: show_analysis_menu
    show_analysis_menu() {
        show_header
        echo -e "${YELLOW}📡 NETWORK ANALYSIS & MONITORING${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Sniff traffic             (Capture trafic réseau)"
        echo "2.  Wifi scan                 (Scan réseaux Wi-Fi)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) source "$CYBER_DIR/analysis/sniff_traffic.sh" && ensure_tool tcpdump && sniff_traffic ;;
            2) source "$CYBER_DIR/analysis/wifi_scan.sh" && wifi_scan ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # GESTION DES ENVIRONNEMENTS
    # =========================================================================
    # DESC: Affiche le menu de gestion des environnements
    # USAGE: show_environment_menu
    # EXAMPLE: show_environment_menu
    show_environment_menu() {
        if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            source "$CYBER_DIR/environment_manager.sh"
            show_environment_menu
        else
            echo "❌ Gestionnaire d'environnements non disponible"
            sleep 1
        fi
    }
    
    # =========================================================================
    # GESTION DES WORKFLOWS
    # =========================================================================
    # DESC: Affiche le menu de gestion des workflows
    # USAGE: show_workflow_menu
    # EXAMPLE: show_workflow_menu
    show_workflow_menu() {
        if [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
            source "$CYBER_DIR/workflow_manager.sh"
            show_workflow_menu
        else
            echo "❌ Gestionnaire de workflows non disponible"
            sleep 1
        fi
    }
    
    # =========================================================================
    # GESTION DES RAPPORTS
    # =========================================================================
    # DESC: Affiche le menu de gestion des rapports
    # USAGE: show_report_menu
    # EXAMPLE: show_report_menu
    show_report_menu() {
        if [ -f "$CYBER_DIR/report_manager.sh" ]; then
            source "$CYBER_DIR/report_manager.sh"
            show_report_menu
        else
            echo "❌ Gestionnaire de rapports non disponible"
            sleep 1
        fi
    }
    
    # =========================================================================
    # GESTION DES CIBLES
    # =========================================================================
    # DESC: Affiche le menu de gestion des cibles
    # USAGE: show_target_menu
    # EXAMPLE: show_target_menu
    show_target_menu() {
        show_header
        echo -e "${YELLOW}🎯 GESTION DES CIBLES${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        if has_targets; then
            show_targets
            echo ""
        else
            echo "⚠️  Aucune cible configurée"
            echo ""
        fi
        
        echo "1.  Ajouter une cible"
        echo "2.  Ajouter plusieurs cibles"
        echo "3.  Supprimer une cible"
        echo "4.  Vider toutes les cibles"
        echo "5.  Afficher les cibles"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                echo ""
                printf "🎯 Entrez la cible (IP, domaine ou URL): "
                read -r target
                if [ -n "$target" ]; then
                    add_target "$target"
                    echo ""
                    read -k 1 "?Appuyez sur une touche pour continuer..."
                fi
                ;;
            2)
                echo ""
                echo "🎯 Entrez les cibles (séparées par des espaces): "
                echo "Exemple: 192.168.1.1 192.168.1.2 example.com"
                printf "Cibles: "
                read -r targets
                if [ -n "$targets" ]; then
                    add_target $targets
                    echo ""
                    read -k 1 "?Appuyez sur une touche pour continuer..."
                fi
                ;;
            3)
                if has_targets; then
                    echo ""
                    show_targets
                    echo ""
                    printf "🎯 Entrez l'index ou le nom de la cible à supprimer: "
                    read -r target
                    if [ -n "$target" ]; then
                        remove_target "$target"
                        echo ""
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                else
                    echo "❌ Aucune cible à supprimer"
                    sleep 1
                fi
                ;;
            4)
                if has_targets; then
                    echo ""
                    printf "⚠️  Êtes-vous sûr de vouloir supprimer toutes les cibles? (o/N): "
                    read -r confirm
                    if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                        clear_targets
                        echo ""
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                else
                    echo "❌ Aucune cible à supprimer"
                    sleep 1
                fi
                ;;
            5)
                echo ""
                if has_targets; then
                    show_targets
                else
                    echo "⚠️  Aucune cible configurée"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # MENU PRINCIPAL
    # =========================================================================
    # DESC: Affiche le menu principal de cyberman
    # USAGE: show_main_menu
    # EXAMPLE: show_main_menu
    show_main_menu() {
        show_header
        
        # Afficher l'environnement actif et les cibles configurées
        echo -e "${CYAN}${BOLD}État actuel:${RESET}"
        
        # Afficher l'environnement actif
        if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            source "$CYBER_DIR/environment_manager.sh" 2>/dev/null
            
            # Vérifier si un environnement est actif
            local current_env=""
            if has_active_environment 2>/dev/null; then
                current_env=$(get_current_environment 2>/dev/null)
            fi
            
            # Si pas d'environnement actif mais des cibles chargées, vérifier si elles viennent d'un environnement
            if [ -z "$current_env" ] && has_targets 2>/dev/null; then
                # Chercher dans les fichiers d'environnement pour trouver celui qui correspond aux cibles actuelles
                local env_dir="${HOME}/.cyberman/environments"
                if [ -d "$env_dir" ] && command -v jq >/dev/null 2>&1; then
                    for env_file in "$env_dir"/*.json; do
                        if [ -f "$env_file" ]; then
                            local env_targets=$(jq -r '.targets[]?' "$env_file" 2>/dev/null | sort)
                            local current_targets=$(printf '%s\n' "${CYBER_TARGETS[@]}" | sort)
                            if [ "$env_targets" = "$current_targets" ] && [ -n "$env_targets" ]; then
                                current_env=$(basename "$env_file" .json)
                                # Définir l'environnement actif
                                CYBER_CURRENT_ENV="$current_env"
                                break
                            fi
                        fi
                    done
                fi
            fi
            
            if [ -n "$current_env" ]; then
                echo -e "   ${GREEN}🌍 Environnement actif: ${BOLD}${current_env}${RESET}"
                
                # Afficher les statistiques de l'environnement actif
                local env_file="${HOME}/.cyberman/environments/${current_env}.json"
                if [ -f "$env_file" ] && command -v jq >/dev/null 2>&1; then
                    local notes_count=$(jq '.notes | length' "$env_file" 2>/dev/null || echo "0")
                    local history_count=$(jq '.history | length' "$env_file" 2>/dev/null || echo "0")
                    local results_count=$(jq '.results | length' "$env_file" 2>/dev/null || echo "0")
                    local todos_count=$(jq '.todos | length' "$env_file" 2>/dev/null || echo "0")
                    local todos_pending=$(jq '[.todos[]? | select(.status == "pending")] | length' "$env_file" 2>/dev/null || echo "0")
                    echo -e "      ${CYAN}📌 Notes: ${notes_count} | 📜 Actions: ${history_count} | 📊 Résultats: ${results_count} | ✅ TODOs: ${todos_count} (${todos_pending} en attente)${RESET}"
                fi
            else
                echo -e "   ${YELLOW}🌍 Aucun environnement actif${RESET}"
            fi
        else
            echo -e "   ${YELLOW}🌍 Aucun environnement actif${RESET}"
        fi
        
        # Afficher les cibles configurées
        if has_targets; then
            echo -e "   ${GREEN}🎯 Cibles actives: ${#CYBER_TARGETS[@]}${RESET}"
            local i=1
            for target in "${CYBER_TARGETS[@]}"; do
                echo -e "      ${GREEN}$i.${RESET} $target"
                ((i++))
            done
        else
            echo -e "   ${YELLOW}🎯 Aucune cible configurée${RESET}"
        fi
        echo ""
        
        echo -e "${CYAN}${BOLD}Menu principal${RESET}\n"
        echo "1.  ⚙️  Gestion & Configuration (environnements, cibles, workflows, rapports, anonymat)"
        echo ""
        echo "2.  🔍 Reconnaissance & Information Gathering"
        echo "3.  🔎 Scanning & Enumeration"
        echo "4.  🛡️  Vulnerability Assessment & Session"
        echo "5.  🌐 Web Security & Testing"
        echo "6.  📡 Network Tools (Analysis, Attacks, Devices)"
        echo "7.  📱 IoT Devices & Embedded Systems"
        echo "8.  🔧 Advanced Tools (Metasploit, Custom Scripts)"
        echo ""
        echo "9.  🚀 Assistant de test complet"
        
        # Afficher l'option d'accès rapide aux notes si un environnement est actif
        if has_active_environment 2>/dev/null; then
            local current_env=$(get_current_environment 2>/dev/null)
            echo ""
            echo -e "${GREEN}📝 Environnement actif: $current_env${RESET}"
            echo "10. 📝 Notes & Informations de l'environnement actif"
        fi
        echo ""
        echo "h.  Aide"
        echo "q.  Quitter"
        echo ""
    }
    
    show_help() {
        show_header
        cat <<EOF
${CYAN}${BOLD}CYBERMAN - Aide${RESET}

${BOLD}Catégories disponibles:${RESET}

${GREEN}1. Reconnaissance & Information Gathering${RESET}
   - Collecte d'informations sur les cibles
   - WHOIS, DNS, sous-domaines, etc.

${GREEN}2. Scanning & Enumeration${RESET}
   - Scan de ports et services
   - Énumération répertoires et partages

${GREEN}3. Vulnerability Assessment${RESET}
   - Détection de vulnérabilités
   - Tests SSL/TLS

${GREEN}4. Network Attacks & Exploitation${RESET}
   - Attaques réseau
   - Exploitation de vulnérabilités

${GREEN}5. Network Analysis & Monitoring${RESET}
   - Analyse et surveillance réseau
   - Capture de trafic

${GREEN}6. Privacy & Anonymity${RESET}
   - Outils d'anonymat
   - Proxy et Tor

${BOLD}Utilisation:${RESET}
Toutes les fonctions vérifient automatiquement si les outils requis
sont installés et proposent de les installer si nécessaire.

${BOLD}Note:${RESET}
Certaines fonctions nécessitent des privilèges sudo.
EOF
        echo ""
        read -k 1 "?Appuyez sur une touche pour revenir au menu..."
    }
    
    # =========================================================================
    # GESTION DE L'ANONYMAT
    # =========================================================================
    # DESC: Affiche le menu de gestion de l'anonymat
    # USAGE: show_anonymity_menu
    # EXAMPLE: show_anonymity_menu
    show_anonymity_menu() {
        show_header
        echo -e "${YELLOW}🔒 GESTION DE L'ANONYMAT${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo "1.  Vérifier l'anonymat"
        echo "2.  Afficher les informations d'anonymat"
        echo "3.  Exécuter une commande avec anonymat"
        echo "4.  Configurer l'usurpation d'IP (IP spoofing)"
        echo "5.  Supprimer l'usurpation d'IP"
        echo "6.  Exécuter un workflow avec anonymat"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    source "$CYBER_DIR/anonymity_manager.sh"
                    check_anonymity
                    echo ""
                    read -k 1 "?Appuyez sur une touche pour continuer..."
                fi
                ;;
            2)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    source "$CYBER_DIR/anonymity_manager.sh"
                    show_anonymity_info
                    echo ""
                    read -k 1 "?Appuyez sur une touche pour continuer..."
                fi
                ;;
            3)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    source "$CYBER_DIR/anonymity_manager.sh"
                    echo ""
                    printf "🔒 Commande à exécuter avec anonymat: "
                    read -r cmd
                    if [ -n "$cmd" ]; then
                        run_with_anonymity $cmd
                        echo ""
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                fi
                ;;
            4)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    source "$CYBER_DIR/anonymity_manager.sh"
                    echo ""
                    printf "🔧 IP à usurper: "
                    read -r fake_ip
                    if [ -n "$fake_ip" ]; then
                        setup_ip_spoofing "$fake_ip"
                        echo ""
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                fi
                ;;
            5)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    source "$CYBER_DIR/anonymity_manager.sh"
                    echo ""
                    printf "🔧 IP usurpée à supprimer: "
                    read -r fake_ip
                    if [ -n "$fake_ip" ]; then
                        remove_ip_spoofing "$fake_ip"
                        echo ""
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                fi
                ;;
            6)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ] && [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
                    source "$CYBER_DIR/anonymity_manager.sh"
                    source "$CYBER_DIR/workflow_manager.sh"
                    echo ""
                    list_workflows
                    echo ""
                    printf "📝 Nom du workflow: "
                    read -r workflow_name
                    if [ -n "$workflow_name" ]; then
                        run_workflow_anonymized "$workflow_name"
                        echo ""
                        read -k 1 "?Appuyez sur une touche pour continuer..."
                    fi
                fi
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # ASSISTANT DE TEST COMPLET
    # =========================================================================
    # DESC: Affiche le menu de l'assistant
    # USAGE: show_assistant_menu
    # EXAMPLE: show_assistant_menu
    show_assistant_menu() {
        show_header
        echo -e "${YELLOW}🚀 ASSISTANT DE TEST COMPLET${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
        echo "L'assistant vous guidera à travers:"
        echo "  • Configuration des cibles"
        echo "  • Configuration de l'anonymat"
        echo "  • Création/gestion d'environnements"
        echo "  • Création/gestion de workflows"
        echo "  • Exécution des tests"
        echo "  • Consultation des rapports"
        echo ""
        printf "Lancer l'assistant? (O/n): "
        read -r confirm
        if [ "$confirm" != "n" ] && [ "$confirm" != "N" ]; then
            if [ -f "$CYBER_DIR/assistant.sh" ]; then
                source "$CYBER_DIR/assistant.sh"
                show_assistant
            else
                echo "❌ Assistant non disponible"
                sleep 1
            fi
        fi
    }
    
    # =========================================================================
    # CATÉGORIE: WEB SECURITY & TESTING
    # =========================================================================
    # DESC: Affiche le menu de sécurité web
    # USAGE: show_web_menu
    # EXAMPLE: show_web_menu
    show_web_menu() {
        show_header
        echo -e "${YELLOW}🌐 WEB SECURITY & TESTING${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Web dir enum              (Énumération répertoires web)"
        echo "2.  Web port scan             (Scan ports web)"
        echo "3.  Web vuln scan             (Scan vulnérabilités web)"
        echo "4.  Get HTTP headers          (En-têtes HTTP)"
        echo "5.  Analyze headers           (Analyse en-têtes)"
        echo "6.  Get robots.txt            (Récupération robots.txt)"
        echo "7.  Check SSL                 (Vérification SSL)"
        echo "8.  Check SSL cert            (Vérification certificat SSL)"
        echo "9.  Nikto scan                (Scan Nikto)"
        echo "10. SQL Injection test         (Test injection SQL)"
        echo "11. XSS test                  (Test XSS)"
        echo "12. CSRF test                 (Test CSRF)"
        echo "13. Web app fingerprint       (Empreinte application web)"
        echo "14. CMS detection             (Détection CMS)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) source "$CYBER_DIR/scanning/web_dir_enum.sh" && ensure_tool gobuster && web_dir_enum ;;
            2) source "$CYBER_DIR/scanning/web_port_scan.sh" && ensure_tool nmap && web_port_scan ;;
            3) source "$CYBER_DIR/vulnerability/web_vuln_scan.sh" && web_vuln_scan ;;
            4) source "$CYBER_DIR/reconnaissance/get_http_headers.sh" && get_http_headers ;;
            5) source "$CYBER_DIR/reconnaissance/analyze_headers.sh" && analyze_headers ;;
            6) source "$CYBER_DIR/reconnaissance/get_robots_txt.sh" && get_robots_txt ;;
            7) source "$CYBER_DIR/vulnerability/check_ssl.sh" && check_ssl ;;
            8) source "$CYBER_DIR/vulnerability/check_ssl_cert.sh" && check_ssl_cert ;;
            9) source "$CYBER_DIR/vulnerability/nikto_scan.sh" && ensure_tool nikto && nikto_scan ;;
            10) echo "⚠️  Fonction SQL Injection test à implémenter" ; sleep 2 ;;
            11) echo "⚠️  Fonction XSS test à implémenter" ; sleep 2 ;;
            12) echo "⚠️  Fonction CSRF test à implémenter" ; sleep 2 ;;
            13) echo "⚠️  Fonction Web app fingerprint à implémenter" ; sleep 2 ;;
            14) echo "⚠️  Fonction CMS detection à implémenter" ; sleep 2 ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE: IoT DEVICES & EMBEDDED SYSTEMS
    # =========================================================================
    # DESC: Affiche le menu pour les appareils IoT et systèmes embarqués
    # USAGE: show_iot_menu
    # EXAMPLE: show_iot_menu
    show_iot_menu() {
        show_header
        echo -e "${YELLOW}📱 IoT DEVICES & EMBEDDED SYSTEMS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  IoT device scan           (Scan appareils IoT)"
        echo "2.  MQTT scan                 (Scan serveurs MQTT)"
        echo "3.  CoAP scan                 (Scan CoAP)"
        echo "4.  Zigbee scan               (Scan réseaux Zigbee)"
        echo "5.  Bluetooth scan            (Scan appareils Bluetooth)"
        echo "6.  Firmware analysis         (Analyse firmware)"
        echo "7.  Default credentials       (Test identifiants par défaut)"
        echo "8.  UPnP scan                 (Scan UPnP)"
        echo "9.  Modbus scan               (Scan Modbus)"
        echo "10. BACnet scan               (Scan BACnet)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) echo "⚠️  Fonction IoT device scan à implémenter" ; sleep 2 ;;
            2) echo "⚠️  Fonction MQTT scan à implémenter" ; sleep 2 ;;
            3) echo "⚠️  Fonction CoAP scan à implémenter" ; sleep 2 ;;
            4) echo "⚠️  Fonction Zigbee scan à implémenter" ; sleep 2 ;;
            5) echo "⚠️  Fonction Bluetooth scan à implémenter" ; sleep 2 ;;
            6) echo "⚠️  Fonction Firmware analysis à implémenter" ; sleep 2 ;;
            7) echo "⚠️  Fonction Default credentials à implémenter" ; sleep 2 ;;
            8) echo "⚠️  Fonction UPnP scan à implémenter" ; sleep 2 ;;
            9) echo "⚠️  Fonction Modbus scan à implémenter" ; sleep 2 ;;
            10) echo "⚠️  Fonction BACnet scan à implémenter" ; sleep 2 ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE: NETWORK TOOLS (regroupe Analysis, Attacks, Devices)
    # =========================================================================
    # DESC: Affiche le menu regroupé pour les outils réseau
    # USAGE: show_network_tools_menu
    # EXAMPLE: show_network_tools_menu
    show_network_tools_menu() {
        show_header
        echo -e "${YELLOW}📡 NETWORK TOOLS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  📊 Network Analysis & Monitoring"
        echo "2.  ⚔️  Network Attacks & Exploitation"
        echo "3.  🔌 Network Devices & Infrastructure"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) show_analysis_menu ;;
            2) show_attack_menu ;;
            3) show_network_devices_menu ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE: ADVANCED TOOLS (Metasploit, Custom Scripts)
    # =========================================================================
    # DESC: Affiche le menu pour les outils avancés
    # USAGE: show_advanced_tools_menu
    # EXAMPLE: show_advanced_tools_menu
    show_advanced_tools_menu() {
        show_header
        echo -e "${YELLOW}🔧 ADVANCED TOOLS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  🎯 Metasploit Framework"
        echo "2.  📜 Custom Nmap Scripts"
        echo "3.  🔨 Custom Exploitation Scripts"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) show_metasploit_menu ;;
            2) show_custom_nmap_menu ;;
            3) show_custom_exploit_menu ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # DESC: Affiche le menu Metasploit
    # USAGE: show_metasploit_menu
    show_metasploit_menu() {
        show_header
        echo -e "${YELLOW}🎯 METASPLOIT FRAMEWORK${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Lancer msfconsole"
        echo "2.  Rechercher un exploit"
        echo "3.  Rechercher un payload"
        echo "4.  Rechercher un auxiliary"
        echo "5.  Lister les exploits récents"
        echo "6.  Générer un payload"
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                if command -v msfconsole >/dev/null 2>&1; then
                    msfconsole
                else
                    echo "❌ Metasploit non installé"
                    echo "💡 Installez-le: sudo pacman -S metasploit"
                    sleep 2
                fi
                ;;
            2)
                printf "🔍 Rechercher un exploit: "
                read -r search_term
                if [ -n "$search_term" ] && command -v msfconsole >/dev/null 2>&1; then
                    msfconsole -q -x "search exploit $search_term; exit"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                printf "🔍 Rechercher un payload: "
                read -r search_term
                if [ -n "$search_term" ] && command -v msfconsole >/dev/null 2>&1; then
                    msfconsole -q -x "search payload $search_term; exit"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                printf "🔍 Rechercher un auxiliary: "
                read -r search_term
                if [ -n "$search_term" ] && command -v msfconsole >/dev/null 2>&1; then
                    msfconsole -q -x "search auxiliary $search_term; exit"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                if command -v msfconsole >/dev/null 2>&1; then
                    msfconsole -q -x "show exploits; exit" | head -50
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                echo "💡 Utilisez msfvenom pour générer des payloads"
                if command -v msfvenom >/dev/null 2>&1; then
                    echo "Exemple: msfvenom -p windows/meterpreter/reverse_tcp LHOST=IP LPORT=PORT -f exe > payload.exe"
                else
                    echo "❌ msfvenom non disponible"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # DESC: Affiche le menu Custom Nmap Scripts
    # USAGE: show_custom_nmap_menu
    show_custom_nmap_menu() {
        show_header
        echo -e "${YELLOW}📜 CUSTOM NMAP SCRIPTS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Lister les scripts nmap disponibles"
        echo "2.  Exécuter un script nmap personnalisé"
        echo "3.  Créer un script nmap personnalisé"
        echo "4.  Scan avec scripts vuln"
        echo "5.  Scan avec scripts exploit"
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                if command -v nmap >/dev/null 2>&1; then
                    local scripts_dir="/usr/share/nmap/scripts"
                    if [ -d "$scripts_dir" ]; then
                        echo "📜 Scripts nmap disponibles:"
                        ls -1 "$scripts_dir"/*.nse 2>/dev/null | wc -l | xargs echo "   Total:"
                        echo ""
                        printf "Afficher la liste complète? (o/N): "
                        read -r show_all
                        if [ "$show_all" = "o" ] || [ "$show_all" = "O" ]; then
                            ls -1 "$scripts_dir"/*.nse 2>/dev/null | head -50
                        fi
                    else
                        echo "⚠️  Répertoire des scripts nmap non trouvé"
                    fi
                else
                    echo "❌ nmap non installé"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                if has_targets; then
                    printf "📜 Nom du script (sans .nse): "
                    read -r script_name
                    if [ -n "$script_name" ]; then
                        for target in "${CYBER_TARGETS[@]}"; do
                            echo "🎯 Scan avec script $script_name sur $target"
                            nmap --script "$script_name" "$target"
                        done
                    fi
                else
                    echo "❌ Aucune cible configurée"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo "💡 Créez vos scripts dans ~/.nmap/scripts/"
                echo "💡 Documentation: https://nmap.org/book/nse.html"
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                if has_targets; then
                    for target in "${CYBER_TARGETS[@]}"; do
                        echo "🎯 Scan vuln sur $target"
                        nmap --script vuln "$target"
                    done
                else
                    echo "❌ Aucune cible configurée"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                if has_targets; then
                    for target in "${CYBER_TARGETS[@]}"; do
                        echo "🎯 Scan exploit sur $target"
                        nmap --script exploit "$target"
                    done
                else
                    echo "❌ Aucune cible configurée"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # DESC: Affiche le menu Custom Exploitation Scripts
    # USAGE: show_custom_exploit_menu
    show_custom_exploit_menu() {
        show_header
        echo -e "${YELLOW}🔨 CUSTOM EXPLOITATION SCRIPTS${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Lister les scripts personnalisés"
        echo "2.  Exécuter un script personnalisé"
        echo "3.  Créer un nouveau script"
        echo "0.  Retour"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                local scripts_dir="$HOME/.cyberman/scripts"
                if [ -d "$scripts_dir" ]; then
                    echo "📜 Scripts personnalisés:"
                    ls -1 "$scripts_dir"/*.sh 2>/dev/null || echo "   Aucun script trouvé"
                else
                    echo "⚠️  Répertoire des scripts non trouvé: $scripts_dir"
                    echo "💡 Créez-le: mkdir -p $scripts_dir"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                local scripts_dir="$HOME/.cyberman/scripts"
                if [ -d "$scripts_dir" ]; then
                    echo "📜 Scripts disponibles:"
                    ls -1 "$scripts_dir"/*.sh 2>/dev/null | nl
                    echo ""
                    printf "📝 Nom du script: "
                    read -r script_name
                    if [ -n "$script_name" ] && [ -f "$scripts_dir/$script_name" ]; then
                        bash "$scripts_dir/$script_name"
                    else
                        echo "❌ Script non trouvé"
                    fi
                else
                    echo "❌ Répertoire des scripts non trouvé"
                fi
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo "💡 Créez vos scripts dans ~/.cyberman/scripts/"
                echo "💡 Les scripts peuvent utiliser les variables CYBER_TARGETS"
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE: NETWORK DEVICES & INFRASTRUCTURE
    # =========================================================================
    # DESC: Affiche le menu pour les appareils réseau et infrastructure
    # USAGE: show_network_devices_menu
    # EXAMPLE: show_network_devices_menu
    show_network_devices_menu() {
        show_header
        echo -e "${YELLOW}🔌 NETWORK DEVICES & INFRASTRUCTURE${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Router scan               (Scan routeurs)"
        echo "2.  Switch scan               (Scan switches)"
        echo "3.  Firewall scan             (Scan pare-feu)"
        echo "4.  SNMP scan                 (Scan SNMP)"
        echo "5.  Check Telnet              (Vérifier si telnet est actif)"
        echo "6.  SSH scan                  (Scan SSH)"
        echo "7.  FTP scan                  (Scan FTP)"
        echo "8.  SMB scan                  (Scan SMB/CIFS)"
        echo "9.  Network topology          (Topologie réseau)"
        echo "10. VLAN scan                 (Scan VLAN)"
        echo "11. OSPF scan                 (Scan OSPF)"
        echo "12. BGP scan                  (Scan BGP)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) echo "⚠️  Fonction Router scan à implémenter" ; sleep 2 ;;
            2) echo "⚠️  Fonction Switch scan à implémenter" ; sleep 2 ;;
            3) echo "⚠️  Fonction Firewall scan à implémenter" ; sleep 2 ;;
            4) echo "⚠️  Fonction SNMP scan à implémenter" ; sleep 2 ;;
            5) source "$CYBER_DIR/scanning/check_telnet.sh" && check_telnet ;;
            6) echo "⚠️  Fonction SSH scan à implémenter" ; sleep 2 ;;
            7) echo "⚠️  Fonction FTP scan à implémenter" ; sleep 2 ;;
            8) source "$CYBER_DIR/scanning/enum_shares.sh" && enum_shares ;;
            9) source "$CYBER_DIR/reconnaissance/network_map.sh" && network_map ;;
            10) echo "⚠️  Fonction VLAN scan à implémenter" ; sleep 2 ;;
            11) echo "⚠️  Fonction OSPF scan à implémenter" ; sleep 2 ;;
            12) echo "⚠️  Fonction BGP scan à implémenter" ; sleep 2 ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Gestion des arguments rapides
    if [[ "$1" == "recon" ]]; then show_recon_menu; return; fi
    if [[ "$1" == "scan" ]]; then show_scan_menu; return; fi
    if [[ "$1" == "vuln" ]]; then show_vuln_menu; return; fi
    if [[ "$1" == "attack" ]]; then show_attack_menu; return; fi
    if [[ "$1" == "analysis" ]]; then show_analysis_menu; return; fi
    if [[ "$1" == "privacy" ]]; then show_privacy_menu; return; fi
    if [[ "$1" == "env" ]]; then show_environment_menu; return; fi
    if [[ "$1" == "workflow" ]]; then show_workflow_menu; return; fi
    if [[ "$1" == "report" ]]; then show_report_menu; return; fi
    if [[ "$1" == "anon" ]]; then show_anonymity_menu; return; fi
    if [[ "$1" == "assistant" ]]; then show_assistant_menu; return; fi
    if [[ "$1" == "web" ]]; then show_web_menu; return; fi
    if [[ "$1" == "iot" ]]; then show_iot_menu; return; fi
    if [[ "$1" == "network" ]]; then show_network_devices_menu; return; fi
    if [[ "$1" == "help" ]]; then show_help; return; fi
    if [[ "$1" == "load_infos" && -n "$2" ]]; then
        if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            source "$CYBER_DIR/environment_manager.sh" 2>/dev/null
            load_infos "$2"
        fi
        return
    fi
    
    # Menu interactif principal
    while true; do
        show_main_menu
        printf "Choix: "
        read -r choice
        # Nettoyer le choix pour éviter les problèmes avec "10", "11", etc.
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                # Menu de gestion et configuration
                if [ -f "$CYBER_DIR/management_menu.sh" ]; then
                    source "$CYBER_DIR/management_menu.sh"
                    show_management_menu
                else
                    echo "❌ Menu de gestion non disponible"
                    sleep 1
                fi
                ;;
            2) show_recon_menu ;;
            3) show_scan_menu ;;
            4) show_vuln_menu ;;
            5) show_web_menu ;;
            6) show_network_tools_menu ;;
            7) show_iot_menu ;;
            8) show_advanced_tools_menu ;;
            9) show_assistant_menu ;;
            h|H) show_help ;;
            q|Q) break ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
    echo -e "${GREEN}Au revoir !${RESET}"
}

# Alias
alias cm='cyberman'

