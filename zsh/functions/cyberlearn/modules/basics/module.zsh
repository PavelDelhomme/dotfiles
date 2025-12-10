#!/bin/zsh
# =============================================================================
# MODULE BASICS - Bases de la Cybersécurité
# =============================================================================
# Description: Module d'apprentissage des bases de la cybersécurité
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

CYBERLEARN_DIR="${CYBERLEARN_DIR:-$HOME/dotfiles/zsh/functions/cyberlearn}"
CYBERLEARN_MODULES_DIR="${CYBERLEARN_DIR}/modules"

# Charger les utilitaires
[ -f "$CYBERLEARN_DIR/utils/progress.sh" ] && source "$CYBERLEARN_DIR/utils/progress.sh"

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
    echo "║         MODULE: BASES DE LA CYBERSÉCURITÉ                     ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}\n"
    
    # Marquer le module comme démarré
    start_module_progress "$module_name"
    
    echo -e "${GREEN}${BOLD}📚 Leçons disponibles:${RESET}\n"
    echo -e "${BOLD}1.${RESET} Introduction à la Cybersécurité"
    echo -e "${BOLD}2.${RESET} Types de Menaces"
    echo -e "${BOLD}3.${RESET} Principes de Sécurité (CIA)"
    echo -e "${BOLD}4.${RESET} Vulnérabilités et Exploits"
    echo -e "${BOLD}5.${RESET} Bonnes Pratiques"
    echo -e "${BOLD}6.${RESET} Exercices Pratiques"
    echo -e "${BOLD}0.${RESET} Retour"
    echo ""
    printf "Choix: "
    read -r choice
    
    case "$choice" in
        1) show_lesson_introduction ;;
        2) show_lesson_threats ;;
        3) show_lesson_cia ;;
        4) show_lesson_vulnerabilities ;;
        5) show_lesson_best_practices ;;
        6) show_exercises_basics ;;
        0) return ;;
        *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
    esac
}

# Leçon 1: Introduction
show_lesson_introduction() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 1: Introduction à la Cybersécurité${RESET}\n"
    
    cat <<EOF
${BOLD}Qu'est-ce que la Cybersécurité ?${RESET}

La cybersécurité est la pratique de protéger les systèmes, réseaux et programmes
contre les attaques numériques. Ces attaques visent généralement à accéder, modifier
ou détruire des informations sensibles, extorquer de l'argent aux utilisateurs ou
interrompre les processus métier.

${BOLD}Domaines principaux:${RESET}
  • Sécurité réseau
  • Sécurité applicative
  • Sécurité des informations
  • Gestion des identités
  • Sécurité opérationnelle
  • Récupération après sinistre
  • Formation des utilisateurs

${BOLD}Pourquoi c'est important ?${RESET}
  • Protection des données personnelles et professionnelles
  • Prévention des pertes financières
  • Maintien de la confiance des clients
  • Conformité réglementaire
  • Protection de la réputation

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 2: Types de Menaces
show_lesson_threats() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 2: Types de Menaces${RESET}\n"
    
    cat <<EOF
${BOLD}Types de Menaces Cyber:${RESET}

${GREEN}1. Malware${RESET}
   Logiciels malveillants (virus, vers, trojans, ransomware)
   
${GREEN}2. Phishing${RESET}
   Tentatives d'obtenir des informations sensibles via email
   
${GREEN}3. Attaques DDoS${RESET}
   Déni de service distribué pour rendre un service indisponible
   
${GREEN}4. Injection SQL${RESET}
   Insertion de code SQL malveillant dans une application
   
${GREEN}5. Cross-Site Scripting (XSS)${RESET}
   Injection de scripts dans des pages web
   
${GREEN}6. Man-in-the-Middle${RESET}
   Interception de communications entre deux parties
   
${GREEN}7. Zero-Day${RESET}
   Exploitation de vulnérabilités inconnues

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 3: Principes CIA
show_lesson_cia() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 3: Principes de Sécurité (CIA)${RESET}\n"
    
    cat <<EOF
${BOLD}Le Trio CIA:${RESET}

${GREEN}Confidentialité (Confidentiality)${RESET}
   Assurer que les informations ne sont accessibles qu'aux personnes autorisées.
   Outils: Chiffrement, contrôle d'accès, authentification

${GREEN}Intégrité (Integrity)${RESET}
   Garantir que les données ne sont pas modifiées de manière non autorisée.
   Outils: Hash, signatures numériques, contrôles d'accès

${GREEN}Disponibilité (Availability)${RESET}
   S'assurer que les systèmes et données sont accessibles quand nécessaire.
   Outils: Redondance, sauvegardes, plan de reprise

${BOLD}Exemples pratiques:${RESET}
  • Confidentialité: Chiffrer un fichier avec GPG
  • Intégrité: Vérifier l'intégrité avec SHA256
  • Disponibilité: Mettre en place des sauvegardes automatiques

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 4: Vulnérabilités
show_lesson_vulnerabilities() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 4: Vulnérabilités et Exploits${RESET}\n"
    
    cat <<EOF
${BOLD}Qu'est-ce qu'une Vulnérabilité ?${RESET}

Une vulnérabilité est une faiblesse dans un système qui peut être exploitée
pour compromettre la sécurité.

${BOLD}Types de Vulnérabilités:${RESET}
  • Vulnérabilités logicielles (bugs, erreurs de code)
  • Vulnérabilités de configuration (mauvaises configurations)
  • Vulnérabilités humaines (ingénierie sociale)
  • Vulnérabilités physiques (accès non autorisé)

${BOLD}Cycle de vie d'une vulnérabilité:${RESET}
  1. Découverte
  2. Divulgation responsable
  3. Patch/Correction
  4. Déploiement
  5. Vérification

${BOLD}Bases de données de vulnérabilités:${RESET}
  • CVE (Common Vulnerabilities and Exposures)
  • NVD (National Vulnerability Database)
  • Exploit-DB

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 5: Bonnes Pratiques
show_lesson_best_practices() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 5: Bonnes Pratiques${RESET}\n"
    
    cat <<EOF
${BOLD}Bonnes Pratiques de Cybersécurité:${RESET}

${GREEN}1. Mots de passe forts${RESET}
   • Minimum 12 caractères
   • Mélange de lettres, chiffres, symboles
   • Utiliser un gestionnaire de mots de passe
   • Activer l'authentification à deux facteurs

${GREEN}2. Mises à jour régulières${RESET}
   • Système d'exploitation
   • Applications
   • Firmware

${GREEN}3. Sauvegardes${RESET}
   • Règle 3-2-1 (3 copies, 2 supports, 1 hors-site)
   • Tester les restaurations

${GREEN}4. Principe du moindre privilège${RESET}
   • Accès minimal nécessaire
   • Séparation des rôles

${GREEN}5. Sensibilisation${RESET}
   • Formation continue
   • Tests de phishing
   • Culture de sécurité

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercices pratiques
show_exercises_basics() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercices Pratiques - Bases${RESET}\n"
    
    echo -e "${BOLD}1.${RESET} Créer un mot de passe fort"
    echo -e "${BOLD}2.${RESET} Vérifier l'intégrité d'un fichier (SHA256)"
    echo -e "${BOLD}3.${RESET} Chiffrer un fichier avec GPG"
    echo -e "${BOLD}4.${RESET} Analyser les permissions d'un fichier"
    echo -e "${BOLD}0.${RESET} Retour"
    echo ""
    printf "Choix: "
    read -r choice
    
    case "$choice" in
        1) exercise_password_strength ;;
        2) exercise_file_integrity ;;
        3) exercise_gpg_encrypt ;;
        4) exercise_file_permissions ;;
        0) return ;;
        *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
    esac
}

# Exercice: Force du mot de passe
exercise_password_strength() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Créer un Mot de Passe Fort${RESET}\n"
    
    echo "Créez un mot de passe fort et vérifiez sa force."
    echo ""
    printf "Votre mot de passe: "
    read -s password
    echo ""
    
    local strength=0
    [ ${#password} -ge 12 ] && ((strength++))
    echo "$password" | grep -q '[A-Z]' && ((strength++))
    echo "$password" | grep -q '[a-z]' && ((strength++))
    echo "$password" | grep -q '[0-9]' && ((strength++))
    echo "$password" | grep -q '[^A-Za-z0-9]' && ((strength++))
    
    case "$strength" in
        5) echo -e "${GREEN}✅ Excellent mot de passe !${RESET}" ;;
        4) echo -e "${YELLOW}⚠️  Bon mot de passe, mais peut être amélioré${RESET}" ;;
        *) echo -e "${RED}❌ Mot de passe faible. Utilisez au moins 12 caractères avec majuscules, minuscules, chiffres et symboles${RESET}" ;;
    esac
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Intégrité de fichier
exercise_file_integrity() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Vérifier l'Intégrité d'un Fichier${RESET}\n"
    
    echo "Créez un fichier test et calculez son hash SHA256:"
    echo ""
    printf "Nom du fichier (ou chemin): "
    read -r file_path
    
    if [ -f "$file_path" ]; then
        if command -v sha256sum &>/dev/null; then
            local hash=$(sha256sum "$file_path" | awk '{print $1}')
            echo -e "${GREEN}Hash SHA256: $hash${RESET}"
            echo ""
            echo "Modifiez le fichier et recalculez le hash pour voir la différence."
        else
            echo -e "${RED}❌ sha256sum n'est pas installé${RESET}"
        fi
    else
        echo -e "${YELLOW}⚠️  Fichier non trouvé. Créez-en un d'abord.${RESET}"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Chiffrement GPG
exercise_gpg_encrypt() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Chiffrer un Fichier avec GPG${RESET}\n"
    
    if ! command -v gpg &>/dev/null; then
        echo -e "${RED}❌ GPG n'est pas installé${RESET}"
        echo -e "${YELLOW}💡 Installez-le avec: sudo pacman -S gnupg${RESET}"
        sleep 2
        return
    fi
    
    echo "Pour chiffrer un fichier avec GPG:"
    echo "  1. Créez une paire de clés: gpg --gen-key"
    echo "  2. Chiffrez: gpg -e -r votre-email fichier.txt"
    echo "  3. Déchiffrez: gpg -d fichier.txt.gpg"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Permissions de fichier
exercise_file_permissions() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Analyser les Permissions${RESET}\n"
    
    printf "Chemin du fichier à analyser: "
    read -r file_path
    
    if [ -f "$file_path" ] || [ -d "$file_path" ]; then
        echo ""
        echo -e "${GREEN}Permissions:${RESET}"
        ls -l "$file_path"
        echo ""
        echo -e "${GREEN}Permissions en octal:${RESET}"
        stat -c "%a" "$file_path"
        echo ""
        echo "Modifiez les permissions avec: chmod 644 fichier"
    else
        echo -e "${RED}❌ Fichier non trouvé${RESET}"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

