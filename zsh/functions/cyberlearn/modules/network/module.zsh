#!/bin/zsh
# =============================================================================
# MODULE NETWORK - Sécurité Réseau
# =============================================================================
# Description: Module d'apprentissage de la sécurité réseau
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

CYBERLEARN_DIR="${CYBERLEARN_DIR:-$HOME/dotfiles/zsh/functions/cyberlearn}"
CYBERLEARN_MODULES_DIR="${CYBERLEARN_DIR}/modules"

# Charger les utilitaires
[ -f "$CYBERLEARN_DIR/utils/progress.sh" ] && source "$CYBERLEARN_DIR/utils/progress.sh"
[ -f "$CYBERLEARN_DIR/utils/validator.sh" ] && source "$CYBERLEARN_DIR/utils/validator.sh"

# Fonction pour exécuter le module
run_module() {
    local module_name="$1"
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
    echo "║         MODULE: SÉCURITÉ RÉSEAU                                ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}\n"
    
    # Marquer le module comme démarré
    start_module_progress "$module_name"
    
    echo -e "${GREEN}${BOLD}📚 Leçons disponibles:${RESET}\n"
    echo -e "${BOLD}1.${RESET} Protocoles Réseau et TCP/IP"
    echo -e "${BOLD}2.${RESET} Scanning et Énumération"
    echo -e "${BOLD}3.${RESET} Attaques Réseau (MITM, ARP Spoofing)"
    echo -e "${BOLD}4.${RESET} Analyse de Trafic (Wireshark, tcpdump)"
    echo -e "${BOLD}5.${RESET} Défense Réseau (Firewall, IDS/IPS)"
    echo -e "${BOLD}6.${RESET} Exercices Pratiques"
    echo -e "${BOLD}0.${RESET} Retour"
    echo ""
    printf "Choix: "
    read -r choice
    
    case "$choice" in
        1) show_lesson_protocols ;;
        2) show_lesson_scanning ;;
        3) show_lesson_attacks ;;
        4) show_lesson_analysis ;;
        5) show_lesson_defense ;;
        6) show_exercises_network ;;
        0) return ;;
        *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
    esac
}

# Leçon 1: Protocoles Réseau
show_lesson_protocols() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 1: Protocoles Réseau et TCP/IP${RESET}\n"
    
    cat <<EOF
${BOLD}Modèle TCP/IP:${RESET}

${GREEN}Couche Application${RESET}
  • HTTP/HTTPS, FTP, SSH, DNS, SMTP
  • Ports bien connus (0-1023)

${GREEN}Couche Transport${RESET}
  • TCP (Transmission Control Protocol) - fiable, connexion
  • UDP (User Datagram Protocol) - rapide, sans connexion
  • Ports: 16 bits (0-65535)

${GREEN}Couche Internet${RESET}
  • IP (Internet Protocol) - routage
  • IPv4: 32 bits (ex: 192.168.1.1)
  • IPv6: 128 bits (ex: 2001:0db8::1)

${GREEN}Couche Accès Réseau${RESET}
  • Ethernet, Wi-Fi, ARP
  • Adresses MAC (48 bits)

${BOLD}Commandes utiles:${RESET}
  • ip addr show          # Afficher les interfaces réseau
  • ip route              # Afficher la table de routage
  • arp -a                # Afficher la table ARP
  • netstat -tuln         # Afficher les ports ouverts
  • ss -tuln              # Alternative moderne à netstat

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 2: Scanning
show_lesson_scanning() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 2: Scanning et Énumération${RESET}\n"
    
    cat <<EOF
${BOLD}Types de Scans:${RESET}

${GREEN}1. Ping Scan (ICMP)${RESET}
   nmap -sn 192.168.1.0/24
   Découvre les hôtes actifs

${GREEN}2. Port Scan${RESET}
   nmap -p- 192.168.1.1
   Scan tous les ports (1-65535)

${GREEN}3. Service Detection${RESET}
   nmap -sV 192.168.1.1
   Détecte les versions de services

${GREEN}4. OS Detection${RESET}
   nmap -O 192.168.1.1
   Détecte le système d'exploitation

${GREEN}5. Stealth Scan (SYN)${RESET}
   nmap -sS 192.168.1.1
   Scan furtif (ne complète pas la connexion TCP)

${BOLD}Énumération:${RESET}
  • DNS: dig example.com, nslookup example.com
  • SNMP: snmpwalk, snmp-check
  • SMB: enum4linux, smbclient
  • HTTP: curl, wget, dirb, gobuster

${BOLD}Outils:${RESET}
  • nmap - Scanner réseau complet
  • masscan - Scanner ultra-rapide
  • zmap - Scanner Internet
  • nikto - Scanner web

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 3: Attaques Réseau
show_lesson_attacks() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 3: Attaques Réseau${RESET}\n"
    
    cat <<EOF
${BOLD}Types d'Attaques:${RESET}

${GREEN}1. Man-in-the-Middle (MITM)${RESET}
   Interception du trafic entre deux parties
   Outils: ettercap, bettercap, arpspoof

${GREEN}2. ARP Spoofing${RESET}
   Empoisonnement de la table ARP
   arpspoof -i eth0 -t target_ip gateway_ip

${GREEN}3. DNS Spoofing${RESET}
   Redirection de requêtes DNS
   bettercap -caplet dns-spoof.cap

${GREEN}4. DDoS (Déni de Service)${RESET}
   Rendre un service indisponible
   Types: SYN flood, UDP flood, ICMP flood

${GREEN}5. Packet Sniffing${RESET}
   Capture de paquets réseau
   Outils: wireshark, tcpdump, tshark

${BOLD}Défense:${RESET}
  • Utiliser HTTPS (TLS/SSL)
  • Vérifier les certificats
  • Utiliser VPN
  • Détecter les anomalies réseau

${YELLOW}⚠️  Ces techniques sont à utiliser uniquement dans des environnements autorisés !${RESET}

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 4: Analyse de Trafic
show_lesson_analysis() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 4: Analyse de Trafic${RESET}\n"
    
    cat <<EOF
${BOLD}Outils d'Analyse:${RESET}

${GREEN}Wireshark (GUI)${RESET}
  • Capture et analyse de paquets
  • Filtres: ip.addr == 192.168.1.1
  • Décodage de protocoles

${GREEN}tcpdump (CLI)${RESET}
  • Capture en ligne de commande
  • tcpdump -i eth0 -n 'tcp port 80'
  • Sauvegarde: -w fichier.pcap

${GREEN}tshark (CLI Wireshark)${RESET}
  • Version CLI de Wireshark
  • tshark -i eth0 -f 'tcp port 80'

${BOLD}Filtres courants:${RESET}
  • host 192.168.1.1
  • port 80
  • tcp port 443
  • icmp
  • arp

${BOLD}Analyse de trafic:${RESET}
  • Identifier les protocoles
  • Détecter les anomalies
  • Analyser les performances
  • Détecter les intrusions

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 5: Défense Réseau
show_lesson_defense() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 5: Défense Réseau${RESET}\n"
    
    cat <<EOF
${BOLD}Outils de Défense:${RESET}

${GREEN}1. Firewall${RESET}
   • iptables (Linux)
   • ufw (Ubuntu)
   • firewalld (RHEL/CentOS)
   • pfSense (Dedicated)

${GREEN}2. IDS/IPS${RESET}
   • IDS: Détection d'intrusion (Suricata, Snort)
   • IPS: Prévention d'intrusion (bloque les attaques)

${GREEN}3. VPN${RESET}
   • OpenVPN, WireGuard
   • Chiffrement du trafic
   • Authentification forte

${GREEN}4. Segmentation Réseau${RESET}
   • VLANs
   • Sous-réseaux isolés
   • DMZ (Zone démilitarisée)

${BOLD}Bonnes Pratiques:${RESET}
  • Principe du moindre privilège
  • Monitoring continu
  • Mises à jour régulières
  • Audit de sécurité
  • Formation des utilisateurs

${BOLD}Commandes iptables de base:${RESET}
  iptables -L                    # Lister les règles
  iptables -A INPUT -p tcp --dport 22 -j ACCEPT  # Autoriser SSH
  iptables -A INPUT -j DROP      # Bloquer tout le reste

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercices pratiques
show_exercises_network() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercices Pratiques - Réseau${RESET}\n"
    
    echo -e "${BOLD}1.${RESET} Scanner un réseau local"
    echo -e "${BOLD}2.${RESET} Analyser les ports ouverts"
    echo -e "${BOLD}3.${RESET} Capturer du trafic réseau"
    echo -e "${BOLD}4.${RESET} Analyser un fichier pcap"
    echo -e "${BOLD}5.${RESET} Configurer un firewall basique"
    echo -e "${BOLD}0.${RESET} Retour"
    echo ""
    printf "Choix: "
    read -r choice
    
    case "$choice" in
        1) exercise_scan_network ;;
        2) exercise_scan_ports ;;
        3) exercise_capture_traffic ;;
        4) exercise_analyze_pcap ;;
        5) exercise_firewall_basic ;;
        0) return ;;
        *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
    esac
}

# Exercice: Scanner un réseau
exercise_scan_network() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Scanner un Réseau Local${RESET}\n"
    
    if ! command -v nmap &>/dev/null; then
        echo -e "${RED}❌ nmap n'est pas installé${RESET}"
        echo -e "${YELLOW}💡 Installez-le avec: installman network-tools${RESET}"
        sleep 2
        return
    fi
    
    echo "Objectif: Découvrir les hôtes actifs sur votre réseau local"
    echo ""
    printf "Adresse réseau à scanner (ex: 192.168.1.0/24): "
    read -r network
    
    if [ -n "$network" ]; then
        echo ""
        echo -e "${GREEN}Exécution du scan...${RESET}"
        echo ""
        nmap -sn "$network" | head -20
        echo ""
        echo -e "${GREEN}✅ Exercice complété !${RESET}"
        echo ""
        echo "Commandes apprises:"
        echo "  • nmap -sn <réseau>  # Ping scan"
        echo "  • nmap -p- <host>    # Scan tous les ports"
        echo "  • nmap -sV <host>    # Détection de services"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Scanner les ports
exercise_scan_ports() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Analyser les Ports Ouverts${RESET}\n"
    
    if ! command -v nmap &>/dev/null; then
        echo -e "${RED}❌ nmap n'est pas installé${RESET}"
        sleep 2
        return
    fi
    
    echo "Objectif: Identifier les ports ouverts sur une machine"
    echo ""
    printf "Adresse IP à scanner (ex: localhost ou 192.168.1.1): "
    read -r target
    
    if [ -n "$target" ]; then
        echo ""
        echo -e "${GREEN}Scan des ports communs...${RESET}"
        echo ""
        nmap -p 1-1000 -sV "$target" 2>/dev/null | head -30
        echo ""
        echo -e "${GREEN}✅ Exercice complété !${RESET}"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Capturer du trafic
exercise_capture_traffic() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Capturer du Trafic Réseau${RESET}\n"
    
    if ! command -v tcpdump &>/dev/null && ! command -v wireshark &>/dev/null; then
        echo -e "${RED}❌ tcpdump ou wireshark n'est pas installé${RESET}"
        echo -e "${YELLOW}💡 Installez-les avec: installman network-tools${RESET}"
        sleep 2
        return
    fi
    
    echo "Objectif: Capturer et analyser du trafic réseau"
    echo ""
    echo "Options:"
    echo "  1. Utiliser tcpdump (CLI)"
    echo "  2. Utiliser wireshark (GUI)"
    echo ""
    printf "Choix: "
    read -r tool_choice
    
    case "$tool_choice" in
        1)
            if command -v tcpdump &>/dev/null; then
                echo ""
                echo "Capture de 10 paquets sur l'interface principale..."
                echo ""
                local iface=$(ip route | awk '/default/ {print $5}' | head -1)
                if [ -n "$iface" ]; then
                    sudo tcpdump -i "$iface" -c 10 -n 2>/dev/null || echo -e "${YELLOW}⚠️  Capture nécessite les droits root${RESET}"
                fi
            fi
            ;;
        2)
            if command -v wireshark &>/dev/null; then
                echo -e "${GREEN}Lancement de Wireshark...${RESET}"
                echo "Dans Wireshark:"
                echo "  1. Sélectionnez une interface"
                echo "  2. Cliquez sur 'Start capturing packets'"
                echo "  3. Analysez le trafic capturé"
                wireshark 2>/dev/null &
            fi
            ;;
    esac
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Analyser un pcap
exercise_analyze_pcap() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Analyser un Fichier PCAP${RESET}\n"
    
    echo "Objectif: Analyser un fichier de capture réseau"
    echo ""
    printf "Chemin du fichier .pcap (ou appuyez sur Entrée pour créer un exemple): "
    read -r pcap_file
    
    if [ -z "$pcap_file" ]; then
        echo ""
        echo "Pour analyser un fichier pcap:"
        echo "  • tcpdump -r fichier.pcap"
        echo "  • wireshark fichier.pcap"
        echo "  • tshark -r fichier.pcap"
    elif [ -f "$pcap_file" ]; then
        if command -v tshark &>/dev/null; then
            echo ""
            echo -e "${GREEN}Analyse du fichier...${RESET}"
            tshark -r "$pcap_file" | head -20
        elif command -v tcpdump &>/dev/null; then
            tcpdump -r "$pcap_file" | head -20
        fi
    else
        echo -e "${RED}❌ Fichier non trouvé${RESET}"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Firewall basique
exercise_firewall_basic() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Configurer un Firewall Basique${RESET}\n"
    
    echo "Objectif: Comprendre les bases de la configuration firewall"
    echo ""
    echo "Commandes iptables de base:"
    echo ""
    echo -e "${GREEN}Lister les règles:${RESET}"
    echo "  sudo iptables -L -n -v"
    echo ""
    echo -e "${GREEN}Autoriser SSH (port 22):${RESET}"
    echo "  sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT"
    echo ""
    echo -e "${GREEN}Autoriser HTTP/HTTPS:${RESET}"
    echo "  sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
    echo "  sudo iptables -A INPUT -p tcp --dport 443 -j ACCEPT"
    echo ""
    echo -e "${GREEN}Bloquer tout le reste:${RESET}"
    echo "  sudo iptables -A INPUT -j DROP"
    echo ""
    echo -e "${YELLOW}⚠️  Attention: Ces commandes modifient le firewall !${RESET}"
    echo -e "${YELLOW}⚠️  Testez d'abord dans un environnement de test${RESET}"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

