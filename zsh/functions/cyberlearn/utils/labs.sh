#!/bin/zsh
# =============================================================================
# LABS - Gestion des labs pratiques
# =============================================================================
# Description: Gestion des environnements Docker pour les labs pratiques
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

CYBERLEARN_LABS_DIR="${HOME}/.cyberlearn/labs"

# Fonction pour afficher le header (si nécessaire)
show_header() {
    clear
    echo -e "\033[0;36m\033[1m"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║            CYBERLEARN - Apprentissage Cybersécurité              ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "\033[0m"
}

# Lister les labs disponibles
list_available_labs() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    show_header
    echo -e "${CYAN}${BOLD}📋 LABS DISPONIBLES${RESET}\n"
    
    echo -e "${BOLD}1.${RESET} 🕸️  web-basics - Lab Sécurité Web de Base"
    echo "   Description: Apprenez les bases de la sécurité web (XSS, SQLi, etc.)"
    echo "   Difficulté: ⭐⭐"
    echo ""
    
    echo -e "${BOLD}2.${RESET} 🌐 network-scan - Lab Scan Réseau"
    echo "   Description: Pratiquez le scanning réseau avec nmap, wireshark"
    echo "   Difficulté: ⭐⭐"
    echo ""
    
    echo -e "${BOLD}3.${RESET} 🔐 crypto-basics - Lab Cryptographie"
    echo "   Description: Apprenez la cryptographie pratique"
    echo "   Difficulté: ⭐⭐⭐"
    echo ""
    
    echo -e "${BOLD}4.${RESET} 🐧 linux-pentest - Lab Pentest Linux"
    echo "   Description: Test de pénétration sur système Linux"
    echo "   Difficulté: ⭐⭐⭐⭐"
    echo ""
    
    echo -e "${BOLD}5.${RESET} 🔍 forensics-basic - Lab Forensique de Base"
    echo "   Description: Analyse forensique de base"
    echo "   Difficulté: ⭐⭐⭐"
    echo ""
    
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Démarrer un lab
start_lab() {
    local lab_name="$1"
    
    if [ -z "$lab_name" ]; then
        start_lab_interactive
        return
    fi
    
    echo -e "${GREEN}🚀 Démarrage du lab: $lab_name${RESET}"
    
    # Vérifier si Docker est installé
    if ! command -v docker &>/dev/null; then
        echo -e "${RED}❌ Docker n'est pas installé${RESET}"
        echo -e "${YELLOW}💡 Installez Docker avec: installman docker${RESET}"
        return 1
    fi
    
    # Vérifier si Docker est en cours d'exécution
    if ! docker info &>/dev/null; then
        echo -e "${RED}❌ Docker n'est pas en cours d'exécution${RESET}"
        echo -e "${YELLOW}💡 Démarrez Docker avec: sudo systemctl start docker${RESET}"
        return 1
    fi
    
    case "$lab_name" in
        web-basics)
            start_web_basics_lab
            ;;
        network-scan)
            start_network_scan_lab
            ;;
        crypto-basics)
            start_crypto_basics_lab
            ;;
        linux-pentest)
            start_linux_pentest_lab
            ;;
        forensics-basic)
            start_forensics_basic_lab
            ;;
        *)
            echo -e "${RED}❌ Lab inconnu: $lab_name${RESET}"
            return 1
            ;;
    esac
}

# Démarrer un lab de manière interactive
start_lab_interactive() {
    show_header
    echo -e "${CYAN}${BOLD}🚀 DÉMARRER UN LAB${RESET}\n"
    
    list_available_labs
    echo ""
    printf "Nom du lab à démarrer: "
    read -r lab_name
    
    if [ -n "$lab_name" ]; then
        start_lab "$lab_name"
    fi
}

# Arrêter un lab
stop_lab() {
    local lab_name="$1"
    
    if [ -z "$lab_name" ]; then
        stop_lab_interactive
        return
    fi
    
    echo -e "${YELLOW}🛑 Arrêt du lab: $lab_name${RESET}"
    
    # Arrêter le container Docker
    local container_name="cyberlearn-${lab_name}"
    if docker ps -a --format '{{.Names}}' | grep -q "^${container_name}$"; then
        docker stop "$container_name" 2>/dev/null && docker rm "$container_name" 2>/dev/null
        echo -e "${GREEN}✅ Lab arrêté${RESET}"
    else
        echo -e "${YELLOW}⚠️  Lab non trouvé ou déjà arrêté${RESET}"
    fi
}

# Arrêter un lab de manière interactive
stop_lab_interactive() {
    show_header
    echo -e "${CYAN}${BOLD}🛑 ARRÊTER UN LAB${RESET}\n"
    
    # Lister les labs actifs
    echo -e "${YELLOW}Labs actifs:${RESET}"
    docker ps --format '{{.Names}}' | grep '^cyberlearn-' | sed 's/^cyberlearn-//' | nl || echo "  Aucun lab actif"
    echo ""
    
    printf "Nom du lab à arrêter: "
    read -r lab_name
    
    if [ -n "$lab_name" ]; then
        stop_lab "$lab_name"
    fi
}

# Afficher le statut des labs
show_labs_status() {
    show_header
    echo -e "${CYAN}${BOLD}📊 STATUT DES LABS${RESET}\n"
    
    if command -v docker &>/dev/null; then
        echo -e "${YELLOW}Labs actifs:${RESET}"
        docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep '^cyberlearn-' || echo "  Aucun lab actif"
        echo ""
        
        echo -e "${YELLOW}Labs arrêtés:${RESET}"
        docker ps -a --format 'table {{.Names}}\t{{.Status}}' | grep '^cyberlearn-' || echo "  Aucun lab arrêté"
    else
        echo -e "${RED}❌ Docker n'est pas installé${RESET}"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Démarrer le lab web-basics
start_web_basics_lab() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local CYAN='\033[0;36m'
    local RESET='\033[0m'
    
    echo -e "${CYAN}📦 Construction de l'image Docker...${RESET}"
    
    # Vérifier si le container existe déjà
    if docker ps -a --format '{{.Names}}' | grep -q "^cyberlearn-web-basics$"; then
        echo -e "${YELLOW}⚠️  Container existant détecté. Redémarrage...${RESET}"
        docker start cyberlearn-web-basics 2>/dev/null && {
            echo -e "${GREEN}✅ Lab web-basics redémarré${RESET}"
            echo -e "${CYAN}🌐 Accédez à: http://localhost:8080${RESET}"
            return 0
        }
    fi
    
    # Créer le Dockerfile pour web-basics
    # S'assurer que le dossier labs existe avec permissions sécurisées
    mkdir -p "$CYBERLEARN_LABS_DIR" 2>/dev/null || true
    chmod 700 "$CYBERLEARN_LABS_DIR" 2>/dev/null || true
    chown "$USER:$USER" "$CYBERLEARN_LABS_DIR" 2>/dev/null || true
    
    local lab_dir="${CYBERLEARN_LABS_DIR}/web-basics"
    mkdir -p "$lab_dir"
    
    cat > "${lab_dir}/Dockerfile" <<'EOF'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    php-mysql \
    php-sqlite3 \
    mysql-server \
    sqlite3 \
    curl \
    wget \
    nano \
    git \
    && rm -rf /var/lib/apt/lists/*

# Créer une application web vulnérable simple
RUN mkdir -p /var/www/html && \
    echo '<?php
// Application web vulnérable pour lab
if (isset($_GET["search"])) {
    echo "<h2>Résultats pour: " . $_GET["search"] . "</h2>";
    // VULNÉRABILITÉ XSS: Pas d'échappement
}
if (isset($_GET["id"])) {
    // VULNÉRABILITÉ SQLi: Requête non préparée
    $db = new SQLite3("/tmp/test.db");
    $result = $db->query("SELECT * FROM users WHERE id=" . $_GET["id"]);
    while ($row = $result->fetchArray()) {
        echo "<p>User: " . $row["name"] . "</p>";
    }
}
?>' > /var/www/html/index.php && \
    echo '<!DOCTYPE html>
<html>
<head><title>Lab Web Basics - Application Vulnérable</title></head>
<body>
<h1>🔓 Lab Web Basics</h1>
<p>Application web vulnérable pour apprendre la sécurité web</p>
<h2>Tests à effectuer:</h2>
<ul>
<li>XSS: ?search=<script>alert("XSS")</script></li>
<li>SQLi: ?id=1 OR 1=1</li>
</ul>
</body>
</html>' > /var/www/html/index.html

# Créer une base de données SQLite de test
RUN sqlite3 /tmp/test.db "CREATE TABLE users(id INTEGER, name TEXT); INSERT INTO users VALUES(1, 'admin'); INSERT INTO users VALUES(2, 'user');"

# Configurer Apache
RUN a2enmod php8.1 && \
    service apache2 start || true

EXPOSE 80

CMD ["apache2ctl", "-D", "FOREGROUND"]
EOF
    
    # Construire et démarrer le container
    echo -e "${CYAN}Construction de l'image...${RESET}"
    docker build -t cyberlearn-web-basics "$lab_dir" 2>/dev/null || {
        echo -e "${RED}❌ Erreur lors de la construction${RESET}"
        return 1
    }
    
    echo -e "${CYAN}Démarrage du container...${RESET}"
    docker run -d --name cyberlearn-web-basics -p 8080:80 cyberlearn-web-basics 2>/dev/null || {
        echo -e "${RED}❌ Erreur lors du démarrage${RESET}"
        return 1
    }
    
    echo -e "${GREEN}✅ Lab web-basics démarré${RESET}"
    echo -e "${CYAN}🌐 Accédez à: http://localhost:8080${RESET}"
    echo ""
    echo -e "${YELLOW}💡 Tests à effectuer:${RESET}"
    echo "  • XSS: http://localhost:8080/?search=<script>alert('XSS')</script>"
    echo "  • SQLi: http://localhost:8080/?id=1 OR 1=1"
    echo ""
    echo -e "${YELLOW}💡 Utilisez 'cyberlearn lab stop web-basics' pour arrêter${RESET}"
}

# Démarrer le lab network-scan
start_network_scan_lab() {
    echo -e "${CYAN}📦 Construction de l'image Docker...${RESET}"
    
    local lab_dir="${CYBERLEARN_LABS_DIR}/network-scan"
    mkdir -p "$lab_dir"
    
    cat > "${lab_dir}/Dockerfile" <<'EOF'
FROM kalilinux/kali-rolling

RUN apt-get update && apt-get install -y \
    nmap \
    wireshark \
    tcpdump \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Créer un serveur simple pour scanner
RUN echo '#!/bin/bash\nwhile true; do nc -l -p 80 -e /bin/bash; done' > /start_server.sh && chmod +x /start_server.sh

EXPOSE 80 22 443

CMD ["/start_server.sh"]
EOF
    
    docker build -t cyberlearn-network-scan "$lab_dir" 2>/dev/null
    docker run -d --name cyberlearn-network-scan -p 8081:80 cyberlearn-network-scan 2>/dev/null
    
    echo -e "${GREEN}✅ Lab network-scan démarré${RESET}"
    echo -e "${CYAN}🎯 Cible: localhost:8081${RESET}"
}

# Démarrer les autres labs (stubs pour l'instant)
start_crypto_basics_lab() {
    echo -e "${YELLOW}⚠️  Lab crypto-basics en cours de développement${RESET}"
}

start_linux_pentest_lab() {
    echo -e "${YELLOW}⚠️  Lab linux-pentest en cours de développement${RESET}"
}

start_forensics_basic_lab() {
    echo -e "${YELLOW}⚠️  Lab forensics-basic en cours de développement${RESET}"
}

