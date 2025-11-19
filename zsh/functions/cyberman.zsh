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
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE 2: SCANNING & ENUMERATION
    # =========================================================================
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
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE 3: VULNERABILITY ASSESSMENT
    # =========================================================================
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
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # =========================================================================
    # CATÉGORIE 4: NETWORK ATTACKS & EXPLOITATION
    # =========================================================================
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
    # MENU PRINCIPAL
    # =========================================================================
    show_main_menu() {
        show_header
        echo -e "${CYAN}${BOLD}Menu principal${RESET}\n"
        echo "1. 🔍 Reconnaissance & Information Gathering"
        echo "2. 🔎 Scanning & Enumeration"
        echo "3. 🛡️  Vulnerability Assessment"
        echo "4. ⚔️  Network Attacks & Exploitation"
        echo "5. 📡 Network Analysis & Monitoring"
        echo "6. 🔒 Privacy & Anonymity"
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
            h|H) show_help ;;
            q|Q) break ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    done
    echo -e "${GREEN}Au revoir !${RESET}"
}

# Alias
alias cm='cyberman'

