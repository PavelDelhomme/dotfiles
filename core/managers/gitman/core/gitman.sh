#!/bin/sh
# =============================================================================
# GITMAN - Git Manager (Code Commun POSIX)
# =============================================================================
# Description: Gestionnaire complet des opérations Git
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

# DESC: Gestionnaire interactif complet pour les opérations Git
# USAGE: gitman [command] [args]
# EXAMPLE: gitman
# EXAMPLE: gitman whoami
# EXAMPLE: gitman switch-identity
# EXAMPLE: gitman status
gitman() {
    # Configuration des couleurs
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
    
    DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
    GITMAN_DIR="$DOTFILES_DIR/zsh/functions/gitman"
    GIT_DIR="$GITMAN_DIR/modules/legacy"
    if [ -f "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh" ]; then
        # shellcheck source=/dev/null
        . "$DOTFILES_DIR/scripts/lib/ncurses_menu.sh"
    fi

    pause_if_tty() {
        if [ -t 0 ] && [ -t 1 ]; then
            printf "Appuyez sur Entrée pour continuer... "
            read dummy
        fi
    }
    
    # Charger les fonctions Git depuis legacy si disponible
    if [ -f "$GIT_DIR/git_functions.sh" ]; then
        . "$GIT_DIR/git_functions.sh" 2>/dev/null || true
    fi
    
    # Fonction pour afficher le header
    show_header() {
        clear
        printf "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    GITMAN - GIT MANAGER                        ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        printf "${RESET}"
    }
    
    # DESC: Estime le temps passé par auteur (toutes branches, refs locaux + distants déjà récupérés)
    # USAGE: appelé par gitman time-spent [--fetch]
    # Algorithme: pour chaque auteur, somme des min(écart entre 2 commits consécutifs, 2h) = temps de session estimé
    gitman_time_spent() {
        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            printf "${RED}❌ Pas un dépôt Git (exécuter depuis la racine du projet)${RESET}\n"
            return 1
        fi
        do_fetch=0
        [ "$1" = "--fetch" ] && do_fetch=1 && shift
        if [ "$do_fetch" -eq 1 ]; then
            printf "${CYAN}Récupération des refs distantes...${RESET}\n"
            git fetch --all 2>/dev/null || true
        fi
        max_gap_sec="${GITMAN_TIME_MAX_GAP:-7200}"
        # Format: timestamp TAB auteur (toutes branches/refs)
        raw=$(git --no-pager log --all --format='%at	%an' 2>/dev/null) || raw=""
        [ -z "$raw" ] && printf "${YELLOW}Aucun commit trouvé.${RESET}\n" && return 0
        printf "${BOLD}⏱ Temps estimé (toutes branches, refs locaux + distants)${RESET}\n"
        printf "${BLUE}   Écart max entre 2 commits = même session = %s secondes${RESET}\n\n" "$max_gap_sec"
        # Tri par auteur puis par date; awk: par auteur somme min(diff, max_gap)
        echo "$raw" | sort -t'	' -k2,2 -k1,1n | awk -F'\t' -v max_gap="$max_gap_sec" '
        BEGIN { prev_ts=0; prev_author=""; total_sec=0 }
        {
            ts=$1; author=$2
            if (prev_author != "" && prev_author == author && prev_ts > 0) {
                d = ts - prev_ts
                if (d < 0) d = -d
                if (d > max_gap) d = max_gap
                sum[author] += d
                total_sec += d
            }
            prev_ts=ts; prev_author=author
            count[author]++
        }
        END {
            for (a in count) {
                h = sum[a] / 3600
                printf "  %-40s %6.1f h  (%d commits)\n", a, h, count[a]
            }
            printf "  %-40s %6.1f h  (total)\n", "TOTAL", total_sec/3600
        }'
    }

    # Journal court : sans pager (CI / Docker) ; dépôt sans commit → message, code 0
    gitman_log_oneline() {
        _gc="${1:-10}"
        if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            printf "${RED}❌ Pas un dépôt Git.${RESET}\n"
            return 1
        fi
        if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
            printf "${YELLOW}⚠️  Aucun commit dans ce dépôt — rien à afficher.${RESET}\n"
            return 0
        fi
        git --no-pager log --oneline -n "$_gc"
    }
    
    # Fonction pour configurer l'identité Git
    configure_git_identity() {
        printf "${CYAN}⚙️  Configuration de l'identité Git${RESET}\n"
        echo ""
        
        printf "📧 Email: "
        read email
        if [ -n "$email" ]; then
            git config user.email "$email"
            printf "${GREEN}✅ Email configuré: $email${RESET}\n"
        fi
        
        printf "👤 Nom: "
        read name
        if [ -n "$name" ]; then
            git config user.name "$name"
            printf "${GREEN}✅ Nom configuré: $name${RESET}\n"
        fi
        
        echo ""
        echo "📋 Configuration actuelle:"
        echo "   Email: $(git config user.email 2>/dev/null || echo 'Non configuré')"
        echo "   Nom: $(git config user.name 2>/dev/null || echo 'Non configuré')"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        printf "${YELLOW}🔧 GESTION GIT${RESET}\n"
        printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n\n"
        
        echo "👤 IDENTITÉ GIT:"
        echo "1.  Qui suis-je ? (whoami)"
        echo "2.  Changer d'identité (switch-identity)"
        echo "3.  Configurer identité Git"
        echo ""
        echo "📊 ÉTAT & INFORMATIONS:"
        echo "4.  Status Git"
        echo "5.  Logs récents"
        echo "6.  Branches"
        echo "7.  Remotes"
        echo ""
        echo "🔄 OPÉRATIONS:"
        echo "8.  Pull"
        echo "9.  Push"
        echo "10. Commit"
        echo "11. Add & Commit"
        echo "12. Diff"
        echo ""
        echo "🌿 BRANCHES:"
        echo "13. Créer branche"
        echo "14. Changer de branche"
        echo "15. Lister branches"
        echo "16. Supprimer branche"
        echo ""
        echo "🔀 MERGE & REBASE:"
        echo "17. Merge"
        echo "18. Rebase"
        echo "19. Abort merge/rebase"
        echo ""
        echo "🧹 NETTOYAGE:"
        echo "20. Clean"
        echo "21. Reset"
        echo "22. Stash"
        echo ""
        echo "⏱ TEMPS ESTIMÉ:"
        echo "23. Temps passé (par auteur, toutes branches)"
        echo ""
        echo "0.  Quitter"
        echo ""
        choice=""
        if [ -t 0 ] && [ -t 1 ] && command -v dotfiles_ncmenu_select >/dev/null 2>&1; then
            menu_input_file=$(mktemp)
            cat > "$menu_input_file" <<'EOF'
Qui suis-je ? (whoami)|1
Changer d'identite (switch-identity)|2
Configurer identite Git|3
Status Git|4
Logs recents|5
Branches|6
Remotes|7
Pull|8
Push|9
Commit|10
Add & Commit|11
Diff|12
Creer branche|13
Changer de branche|14
Lister branches|15
Supprimer branche|16
Merge|17
Rebase|18
Abort merge/rebase|19
Clean|20
Reset|21
Stash|22
Temps passe (par auteur, toutes branches)|23
Quitter|0
EOF
            choice=$(dotfiles_ncmenu_select "GITMAN - Menu principal" < "$menu_input_file" 2>/dev/null || true)
            rm -f "$menu_input_file"
        fi
        if [ -z "$choice" ]; then
            printf "Choix: "
            read choice
            choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        fi
        
        case "$choice" in
            1)
                echo ""
                # Charger les fonctions depuis legacy si nécessaire
                if [ -f "$GIT_DIR/git_functions.sh" ]; then
                    . "$GIT_DIR/git_functions.sh" 2>/dev/null || true
                fi
                if command -v whoami-git >/dev/null 2>&1; then
                    whoami-git
                else
                    echo "📧 Email: $(git config --global user.email 2>/dev/null || echo 'Non configuré')"
                    echo "👤 Nom: $(git config --global user.name 2>/dev/null || echo 'Non configuré')"
                    echo "📁 Répertoire courant: $PWD"
                fi
                echo ""
                pause_if_tty
                ;;
            2)
                echo ""
                # Charger les fonctions depuis legacy si nécessaire
                if [ -f "$GIT_DIR/git_functions.sh" ]; then
                    . "$GIT_DIR/git_functions.sh" 2>/dev/null || true
                fi
                if command -v switch-git-identity >/dev/null 2>&1; then
                    switch-git-identity
                else
                    printf "${YELLOW}⚠️  Fonction switch-git-identity non disponible${RESET}\n"
                    echo "💡 Utilisez: gitman config"
                fi
                echo ""
                pause_if_tty
                ;;
            3)
                echo ""
                configure_git_identity
                echo ""
                pause_if_tty
                ;;
            4)
                echo ""
                git status
                echo ""
                pause_if_tty
                ;;
            5)
                echo ""
                printf "Nombre de commits à afficher (défaut: 10): "
                read count
                count="${count:-10}"
                gitman_log_oneline "$count"
                echo ""
                pause_if_tty
                ;;
            6)
                echo ""
                git branch -a
                echo ""
                pause_if_tty
                ;;
            7)
                echo ""
                git remote -v
                echo ""
                pause_if_tty
                ;;
            8)
                echo ""
                git pull
                echo ""
                pause_if_tty
                ;;
            9)
                echo ""
                printf "Branche à pousser (défaut: actuelle): "
                read branch
                if [ -n "$branch" ]; then
                    git push origin "$branch"
                else
                    git push
                fi
                echo ""
                pause_if_tty
                ;;
            10)
                echo ""
                printf "Message de commit: "
                read message
                if [ -n "$message" ]; then
                    git commit -m "$message"
                else
                    printf "${RED}❌ Message requis${RESET}\n"
                fi
                echo ""
                pause_if_tty
                ;;
            11)
                echo ""
                printf "Fichiers à ajouter (défaut: .): "
                read files
                files="${files:-.}"
                printf "Message de commit: "
                read message
                if [ -n "$message" ]; then
                    git add "$files"
                    git commit -m "$message"
                else
                    printf "${RED}❌ Message requis${RESET}\n"
                fi
                echo ""
                pause_if_tty
                ;;
            12)
                echo ""
                git diff
                echo ""
                pause_if_tty
                ;;
            13)
                echo ""
                printf "Nom de la branche: "
                read branch
                if [ -n "$branch" ]; then
                    git checkout -b "$branch"
                else
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                fi
                echo ""
                pause_if_tty
                ;;
            14)
                echo ""
                printf "Branche à activer: "
                read branch
                if [ -n "$branch" ]; then
                    git checkout "$branch"
                else
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                fi
                echo ""
                pause_if_tty
                ;;
            15)
                echo ""
                git branch -a
                echo ""
                pause_if_tty
                ;;
            16)
                echo ""
                printf "Branche à supprimer: "
                read branch
                if [ -n "$branch" ]; then
                    printf "Supprimer aussi sur remote? (o/N): "
                    read remote
                    if [ "$remote" = "o" ] || [ "$remote" = "O" ]; then
                        git push origin --delete "$branch"
                    fi
                    git branch -d "$branch" || git branch -D "$branch"
                else
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                fi
                echo ""
                pause_if_tty
                ;;
            17)
                echo ""
                printf "Branche à merger: "
                read branch
                if [ -n "$branch" ]; then
                    git merge "$branch"
                else
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                fi
                echo ""
                pause_if_tty
                ;;
            18)
                echo ""
                printf "Branche pour rebase: "
                read branch
                if [ -n "$branch" ]; then
                    git rebase "$branch"
                else
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                fi
                echo ""
                pause_if_tty
                ;;
            19)
                echo ""
                printf "Type (merge/rebase, défaut: merge): "
                read type
                type="${type:-merge}"
                if [ "$type" = "rebase" ]; then
                    git rebase --abort
                else
                    git merge --abort
                fi
                echo ""
                pause_if_tty
                ;;
            20)
                echo ""
                printf "Nettoyer fichiers non trackés? (o/N): "
                read confirm
                if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                    git clean -fd
                else
                    git clean -n
                fi
                echo ""
                pause_if_tty
                ;;
            21)
                echo ""
                printf "${YELLOW}⚠️  ATTENTION: Reset peut être destructif${RESET}\n"
                printf "Type (soft/mixed/hard, défaut: mixed): "
                read type
                type="${type:-mixed}"
                printf "Commit/HEAD (défaut: HEAD): "
                read target
                target="${target:-HEAD}"
                printf "Confirmer reset $type vers $target? (o/N): "
                read confirm
                if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                    git reset --"$type" "$target"
                fi
                echo ""
                pause_if_tty
                ;;
            22)
                echo ""
                echo "1. Créer stash"
                echo "2. Lister stashes"
                echo "3. Appliquer stash"
                echo "4. Supprimer stash"
                printf "Choix: "
                read stash_choice
                case "$stash_choice" in
                    1)
                        printf "Message (optionnel): "
                        read message
                        if [ -n "$message" ]; then
                            git stash push -m "$message"
                        else
                            git stash
                        fi
                        ;;
                    2) git stash list ;;
                    3)
                        printf "Index du stash (défaut: 0): "
                        read index
                        index="${index:-0}"
                        git stash apply "stash@{$index}"
                        ;;
                    4)
                        printf "Index du stash: "
                        read index
                        git stash drop "stash@{$index}"
                        ;;
                esac
                echo ""
                pause_if_tty
                ;;
            23)
                echo ""
                gitman_time_spent
                echo ""
                pause_if_tty
                ;;
            0) return ;;
            *)
                printf "${RED}Choix invalide${RESET}\n"
                sleep 1
                ;;
        esac
    }
    
    # Gestion des arguments en ligne de commande
    if [ $# -eq 0 ] || [ "$1" = "--help" ]; then
        if [ "$1" = "--help" ]; then
            gitman help
            pause_if_tty
        fi
        # Menu interactif
        while true; do
            show_main_menu
        done
    else
        # Commandes directes
        _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
        [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log gitman "$@"
        case "$1" in
            whoami)
                # Charger les fonctions depuis legacy si nécessaire
                if [ -f "$GIT_DIR/git_functions.sh" ]; then
                    . "$GIT_DIR/git_functions.sh" 2>/dev/null || true
                fi
                if command -v whoami-git >/dev/null 2>&1; then
                    whoami-git
                else
                    echo "📧 Email: $(git config --global user.email 2>/dev/null || echo 'Non configuré')"
                    echo "👤 Nom: $(git config --global user.name 2>/dev/null || echo 'Non configuré')"
                    echo "📁 Répertoire courant: $PWD"
                fi
                ;;
            switch-identity|switch)
                # Charger les fonctions depuis legacy si nécessaire
                if [ -f "$GIT_DIR/git_functions.sh" ]; then
                    . "$GIT_DIR/git_functions.sh" 2>/dev/null || true
                fi
                if command -v switch-git-identity >/dev/null 2>&1; then
                    shift
                    switch-git-identity "$@"
                else
                    printf "${YELLOW}⚠️  Fonction switch-git-identity non disponible${RESET}\n"
                    echo "💡 Utilisez: gitman config"
                fi
                ;;
            config|configure)
                configure_git_identity
                ;;
            status|st)
                git status
                ;;
            log|logs)
                count="${2:-10}"
                gitman_log_oneline "$count"
                ;;
            branch|branches|br)
                git branch -a
                ;;
            remote|remotes)
                git remote -v
                ;;
            pull)
                git pull
                ;;
            push)
                branch="${2:-}"
                if [ -n "$branch" ]; then
                    git push origin "$branch"
                else
                    git push
                fi
                ;;
            commit|cm)
                message="$2"
                if [ -z "$message" ]; then
                    printf "${RED}❌ Message de commit requis${RESET}\n"
                    echo "Usage: gitman commit 'message'"
                    return 1
                fi
                git commit -m "$message"
                ;;
            add-commit|ac)
                files="${2:-.}"
                message="$3"
                if [ -z "$message" ]; then
                    printf "${RED}❌ Message de commit requis${RESET}\n"
                    echo "Usage: gitman add-commit [files] 'message'"
                    return 1
                fi
                git add "$files"
                git commit -m "$message"
                ;;
            diff|d)
                git diff
                ;;
            create-branch|cb)
                branch="$2"
                if [ -z "$branch" ]; then
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                    echo "Usage: gitman create-branch <name>"
                    return 1
                fi
                git checkout -b "$branch"
                ;;
            checkout|co)
                branch="$2"
                if [ -z "$branch" ]; then
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                    echo "Usage: gitman checkout <branch>"
                    return 1
                fi
                git checkout "$branch"
                ;;
            delete-branch|db)
                branch="$2"
                if [ -z "$branch" ]; then
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                    echo "Usage: gitman delete-branch <branch>"
                    return 1
                fi
                git branch -d "$branch" || git branch -D "$branch"
                ;;
            merge)
                branch="$2"
                if [ -z "$branch" ]; then
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                    echo "Usage: gitman merge <branch>"
                    return 1
                fi
                git merge "$branch"
                ;;
            rebase)
                branch="$2"
                if [ -z "$branch" ]; then
                    printf "${RED}❌ Nom de branche requis${RESET}\n"
                    echo "Usage: gitman rebase <branch>"
                    return 1
                fi
                git rebase "$branch"
                ;;
            abort)
                type="${2:-merge}"
                if [ "$type" = "rebase" ]; then
                    git rebase --abort
                else
                    git merge --abort
                fi
                ;;
            clean)
                git clean -fd
                ;;
            reset)
                type="${2:-mixed}"
                target="${3:-HEAD}"
                git reset --"$type" "$target"
                ;;
            time-spent|stats-time|time)
                gitman_time_spent "$2"
                ;;
            stash)
                action="${2:-list}"
                case "$action" in
                    create|save)
                        message="$3"
                        if [ -n "$message" ]; then
                            git stash push -m "$message"
                        else
                            git stash
                        fi
                        ;;
                    list|ls)
                        git stash list
                        ;;
                    apply)
                        index="${3:-0}"
                        git stash apply "stash@{$index}"
                        ;;
                    drop|delete)
                        index="$3"
                        if [ -z "$index" ]; then
                            printf "${RED}❌ Index requis${RESET}\n"
                            return 1
                        fi
                        git stash drop "stash@{$index}"
                        ;;
                    *)
                        echo "Usage: gitman stash [create|list|apply|drop] [args]"
                        ;;
                esac
                ;;
            help|-h)
                echo "🔧 GITMAN - Gestionnaire Git"
                echo ""
                echo "Usage: gitman [command] [args]"
                echo ""
                echo "Commandes:"
                echo "  whoami              - Affiche l'identité Git actuelle"
                echo "  switch-identity     - Change l'identité Git"
                echo "  config              - Configure l'identité Git"
                echo "  status              - Affiche le statut Git"
                echo "  log [count]         - Affiche les logs (défaut: 10)"
                echo "  branch              - Liste les branches"
                echo "  remote              - Liste les remotes"
                echo "  pull                - Pull depuis remote"
                echo "  push [branch]       - Push vers remote"
                echo "  commit <message>    - Commit avec message"
                echo "  add-commit <files> <message> - Add et commit"
                echo "  diff                - Affiche les différences"
                echo "  create-branch <name> - Crée une branche"
                echo "  checkout <branch>    - Change de branche"
                echo "  delete-branch <branch> - Supprime une branche"
                echo "  merge <branch>      - Merge une branche"
                echo "  rebase <branch>     - Rebase sur une branche"
                echo "  abort [type]        - Abort merge/rebase"
                echo "  clean               - Nettoie les fichiers non trackés"
                echo "  reset [type] [target] - Reset (soft/mixed/hard)"
                echo "  stash [action]      - Gestion des stashes"
                echo "  time-spent [--fetch] - Temps estimé par auteur (toutes branches)"
                echo "                         Variable: GITMAN_TIME_MAX_GAP (sec, défaut 7200)"
                echo ""
                echo "Sans argument ou gitman --help : menu interactif"
                ;;
            *)
                printf "${RED}❌ Commande inconnue: $1${RESET}\n"
                echo "💡 Utilisez 'gitman help' pour voir les commandes disponibles"
                return 1
                ;;
        esac
    fi
}
