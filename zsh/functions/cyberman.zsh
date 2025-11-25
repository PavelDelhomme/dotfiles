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
    
    # Charger le gestionnaire de cibles si pas déjà chargé
    if [ -f "$CYBER_DIR/target_manager.sh" ]; then
        source "$CYBER_DIR/target_manager.sh"
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
        case "$choice" in
            1) source "$CYBER_DIR/reconnaissance/domain_whois.sh" && domain_whois ;;
            2) source "$CYBER_DIR/reconnaissance/dns_lookup.sh" && dns_lookup ;;
            3) source "$CYBER_DIR/reconnaissance/dnsenum_scan.sh" && ensure_tool dnsenum && dnsenum_scan ;;
            4) source "$CYBER_DIR/reconnaissance/find_subdomains.sh" && find_subdomains ;;
            5) source "$CYBER_DIR/reconnaissance/recon_domain.sh" && ensure_tool theHarvester && recon_domain ;;
            6) source "$CYBER_DIR/reconnaissance/enhanced_traceroute.sh" && enhanced_traceroute ;;
            7) source "$CYBER_DIR/reconnaissance/network_map.sh" && network_map ;;
            8) source "$CYBER_DIR/reconnaissance/get_http_headers.sh" && get_http_headers ;;
            9) source "$CYBER_DIR/reconnaissance/analyze_headers.sh" && analyze_headers ;;
            10) source "$CYBER_DIR/reconnaissance/get_robots_txt.sh" && get_robots_txt ;;
            11)
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
        echo "10. Scan toutes les cibles    (Scan complet sur toutes les cibles)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        case "$choice" in
            1) source "$CYBER_DIR/scanning/port_scan.sh" && ensure_tool nmap && port_scan ;;
            2) source "$CYBER_DIR/scanning/scan_ports.sh" && ensure_tool nmap && scan_ports ;;
            3) source "$CYBER_DIR/scanning/web_port_scan.sh" && ensure_tool nmap && web_port_scan ;;
            4) source "$CYBER_DIR/scanning/scan_web_ports.sh" && ensure_tool nmap && scan_web_ports ;;
            5) source "$CYBER_DIR/scanning/enum_dirs.sh" && enum_dirs ;;
            6) source "$CYBER_DIR/scanning/enum_shares.sh" && enum_shares ;;
            7) source "$CYBER_DIR/scanning/enumerate_users.sh" && enumerate_users ;;
            8) source "$CYBER_DIR/scanning/web_dir_enum.sh" && ensure_tool gobuster && web_dir_enum ;;
            9) source "$CYBER_DIR/reconnaissance/network_map.sh" && network_map ;;
            10)
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
        echo -e "${YELLOW}🛡️ VULNERABILITY ASSESSMENT${RESET}"
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
        case "$choice" in
            1) source "$CYBER_DIR/vulnerability/nmap_vuln_scan.sh" && ensure_tool nmap && nmap_vuln_scan ;;
            2) source "$CYBER_DIR/vulnerability/vuln_scan.sh" && vuln_scan ;;
            3) source "$CYBER_DIR/vulnerability/scan_vulns.sh" && scan_vulns ;;
            4) source "$CYBER_DIR/vulnerability/nikto_scan.sh" && ensure_tool nikto && nikto_scan ;;
            5) source "$CYBER_DIR/vulnerability/web_vuln_scan.sh" && web_vuln_scan ;;
            6) source "$CYBER_DIR/vulnerability/check_ssl.sh" && check_ssl ;;
            7) source "$CYBER_DIR/vulnerability/check_ssl_cert.sh" && check_ssl_cert ;;
            8) source "$CYBER_DIR/vulnerability/check_heartbleed.sh" && check_heartbleed ;;
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
        case "$choice" in
            1) source "$CYBER_DIR/analysis/sniff_traffic.sh" && ensure_tool tcpdump && sniff_traffic ;;
            2) source "$CYBER_DIR/analysis/wifi_scan.sh" && wifi_scan ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE 6: PRIVACY & ANONYMITY
    # =========================================================================
    # DESC: Affiche le menu de privacy et anonymisation
    # USAGE: show_privacy_menu
    # EXAMPLE: show_privacy_menu
    show_privacy_menu() {
        show_header
        echo -e "${YELLOW}🔒 PRIVACY & ANONYMITY${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        echo "1.  Start Tor                 (Démarrer Tor)"
        echo "2.  Stop Tor                  (Arrêter Tor)"
        echo "3.  Proxy command             (Exécution via proxy)"
        echo "0.  Retour au menu principal"
        echo ""
        printf "Choix: "
        read -r choice
        case "$choice" in
            1) source "$CYBER_DIR/privacy/start_tor.sh" && ensure_tool tor && start_tor ;;
            2) source "$CYBER_DIR/privacy/stop_tor.sh" && stop_tor ;;
            3) source "$CYBER_DIR/privacy/proxycmd.sh" && ensure_tool proxychains && proxycmd ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
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
        
        # Afficher les cibles configurées
        if has_targets; then
            echo -e "${GREEN}🎯 Cibles actives: ${#CYBER_TARGETS[@]}${RESET}"
            local i=1
            for target in "${CYBER_TARGETS[@]}"; do
                echo -e "   ${GREEN}$i.${RESET} $target"
                ((i++))
            done
            echo ""
        else
            echo -e "${YELLOW}⚠️  Aucune cible configurée${RESET}"
            echo ""
        fi
        
        echo -e "${CYAN}${BOLD}Menu principal${RESET}\n"
        echo "1. 🔍 Reconnaissance & Information Gathering"
        echo "2. 🔎 Scanning & Enumeration"
        echo "3. 🛡️  Vulnerability Assessment"
        echo "4. ⚔️  Network Attacks & Exploitation"
        echo "5. 📡 Network Analysis & Monitoring"
        echo "6. 🔒 Privacy & Anonymity"
        echo "7. 🎯 Gestion des cibles"
        echo ""
        echo "h. Aide"
        echo "q. Quitter"
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
    
    # Gestion des arguments rapides
    if [[ "$1" == "recon" ]]; then show_recon_menu; return; fi
    if [[ "$1" == "scan" ]]; then show_scan_menu; return; fi
    if [[ "$1" == "vuln" ]]; then show_vuln_menu; return; fi
    if [[ "$1" == "attack" ]]; then show_attack_menu; return; fi
    if [[ "$1" == "analysis" ]]; then show_analysis_menu; return; fi
    if [[ "$1" == "privacy" ]]; then show_privacy_menu; return; fi
    if [[ "$1" == "help" ]]; then show_help; return; fi
    
    # Menu interactif principal
    while true; do
        show_main_menu
        printf "Choix: "
        read -k 1 choice
        echo
        case "$choice" in
            1) show_recon_menu ;;
            2) show_scan_menu ;;
            3) show_vuln_menu ;;
            4) show_attack_menu ;;
            5) show_analysis_menu ;;
            6) show_privacy_menu ;;
            7) show_target_menu ;;
            h|H) show_help ;;
            q|Q) break ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
    echo -e "${GREEN}Au revoir !${RESET}"
}

# Alias
alias cm='cyberman'

