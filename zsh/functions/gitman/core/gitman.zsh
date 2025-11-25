#!/bin/zsh
# =============================================================================
# GITMAN - Git Manager pour ZSH
# =============================================================================
# Description: Gestionnaire complet des opérations Git
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

# Répertoires de base
GITMAN_DIR="${GITMAN_DIR:-$HOME/dotfiles/zsh/functions/gitman}"
GIT_DIR="${GIT_DIR:-$HOME/dotfiles/zsh/functions/gitman/modules/legacy}"

# Charger les fonctions Git depuis legacy
if [ -f "$GIT_DIR/git_functions.sh" ]; then
    source "$GIT_DIR/git_functions.sh"
fi

# DESC: Gestionnaire interactif complet pour les opérations Git
# USAGE: gitman [command] [args]
# EXAMPLE: gitman
# EXAMPLE: gitman whoami
# EXAMPLE: gitman switch-identity
# EXAMPLE: gitman status
gitman() {
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local MAGENTA='\033[0;35m'
    local CYAN='\033[0;36m'
    local BOLD='\033[1m'
    local RESET='\033[0m'
    
    # Fonction pour afficher le header
    show_header() {
        clear
        echo -e "${CYAN}${BOLD}"
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║                    GITMAN - GIT MANAGER                        ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo -e "${RESET}"
    }
    
    # Fonction pour afficher le menu principal
    show_main_menu() {
        show_header
        echo -e "${YELLOW}🔧 GESTION GIT${RESET}"
        echo -e "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"
        
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
        echo "0.  Quitter"
        echo ""
        printf "Choix: "
        read -r choice
        choice=$(echo "$choice" | tr -d '[:space:]' | head -c 2)
        
        case "$choice" in
            1)
                echo ""
                # Charger les fonctions depuis legacy si nécessaire
                if [ -f "$GIT_DIR/git_functions.sh" ]; then
                    source "$GIT_DIR/git_functions.sh" 2>/dev/null
                fi
                if command -v whoami-git >/dev/null 2>&1; then
                    whoami-git
                else
                    echo "📧 Email: $(git config --global user.email 2>/dev/null || echo 'Non configuré')"
                    echo "👤 Nom: $(git config --global user.name 2>/dev/null || echo 'Non configuré')"
                    echo "📁 Répertoire courant: $PWD"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            2)
                echo ""
                # Charger les fonctions depuis legacy si nécessaire
                if [ -f "$GIT_DIR/git_functions.sh" ]; then
                    source "$GIT_DIR/git_functions.sh" 2>/dev/null
                fi
                if command -v switch-git-identity >/dev/null 2>&1; then
                    switch-git-identity
                else
                    echo "⚠️  Fonction switch-git-identity non disponible"
                    echo "💡 Utilisez: gitman config"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            3)
                echo ""
                configure_git_identity
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            4)
                echo ""
                git status
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            5)
                echo ""
                printf "Nombre de commits à afficher (défaut: 10): "
                read -r count
                count="${count:-10}"
                git log --oneline -n "$count"
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            6)
                echo ""
                git branch -a
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            7)
                echo ""
                git remote -v
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            8)
                echo ""
                git pull
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            9)
                echo ""
                printf "Branche à pousser (défaut: actuelle): "
                read -r branch
                if [ -n "$branch" ]; then
                    git push origin "$branch"
                else
                    git push
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            10)
                echo ""
                printf "Message de commit: "
                read -r message
                if [ -n "$message" ]; then
                    git commit -m "$message"
                else
                    echo "❌ Message requis"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            11)
                echo ""
                printf "Fichiers à ajouter (défaut: .): "
                read -r files
                files="${files:-.}"
                printf "Message de commit: "
                read -r message
                if [ -n "$message" ]; then
                    git add "$files"
                    git commit -m "$message"
                else
                    echo "❌ Message requis"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            12)
                echo ""
                git diff
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            13)
                echo ""
                printf "Nom de la branche: "
                read -r branch
                if [ -n "$branch" ]; then
                    git checkout -b "$branch"
                else
                    echo "❌ Nom de branche requis"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            14)
                echo ""
                printf "Branche à activer: "
                read -r branch
                if [ -n "$branch" ]; then
                    git checkout "$branch"
                else
                    echo "❌ Nom de branche requis"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            15)
                echo ""
                git branch -a
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            16)
                echo ""
                printf "Branche à supprimer: "
                read -r branch
                if [ -n "$branch" ]; then
                    printf "Supprimer aussi sur remote? (o/N): "
                    read -r remote
                    if [ "$remote" = "o" ] || [ "$remote" = "O" ]; then
                        git push origin --delete "$branch"
                    fi
                    git branch -d "$branch" || git branch -D "$branch"
                else
                    echo "❌ Nom de branche requis"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            17)
                echo ""
                printf "Branche à merger: "
                read -r branch
                if [ -n "$branch" ]; then
                    git merge "$branch"
                else
                    echo "❌ Nom de branche requis"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            18)
                echo ""
                printf "Branche pour rebase: "
                read -r branch
                if [ -n "$branch" ]; then
                    git rebase "$branch"
                else
                    echo "❌ Nom de branche requis"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            19)
                echo ""
                printf "Type (merge/rebase, défaut: merge): "
                read -r type
                type="${type:-merge}"
                if [ "$type" = "rebase" ]; then
                    git rebase --abort
                else
                    git merge --abort
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            20)
                echo ""
                printf "Nettoyer fichiers non trackés? (o/N): "
                read -r confirm
                if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                    git clean -fd
                else
                    git clean -n
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            21)
                echo ""
                echo "⚠️  ATTENTION: Reset peut être destructif"
                printf "Type (soft/mixed/hard, défaut: mixed): "
                read -r type
                type="${type:-mixed}"
                printf "Commit/HEAD (défaut: HEAD): "
                read -r target
                target="${target:-HEAD}"
                printf "Confirmer reset $type vers $target? (o/N): "
                read -r confirm
                if [ "$confirm" = "o" ] || [ "$confirm" = "O" ]; then
                    git reset --"$type" "$target"
                fi
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            22)
                echo ""
                echo "1. Créer stash"
                echo "2. Lister stashes"
                echo "3. Appliquer stash"
                echo "4. Supprimer stash"
                printf "Choix: "
                read -r stash_choice
                case "$stash_choice" in
                    1)
                        printf "Message (optionnel): "
                        read -r message
                        if [ -n "$message" ]; then
                            git stash push -m "$message"
                        else
                            git stash
                        fi
                        ;;
                    2) git stash list ;;
                    3)
                        printf "Index du stash (défaut: 0): "
                        read -r index
                        index="${index:-0}"
                        git stash apply "stash@{$index}"
                        ;;
                    4)
                        printf "Index du stash: "
                        read -r index
                        git stash drop "stash@{$index}"
                        ;;
                esac
                echo ""
                read -k 1 "?Appuyez sur une touche pour continuer..."
                ;;
            0) return ;;
            *) echo -e "${RED}Choix invalide${RESET}"; sleep 1 ;;
        esac
    }
    
    # Fonction pour configurer l'identité Git
    configure_git_identity() {
        echo -e "${CYAN}⚙️  Configuration de l'identité Git${RESET}"
        echo ""
        
        printf "📧 Email: "
        read -r email
        if [ -n "$email" ]; then
            git config user.email "$email"
            echo "✅ Email configuré: $email"
        fi
        
        printf "👤 Nom: "
        read -r name
        if [ -n "$name" ]; then
            git config user.name "$name"
            echo "✅ Nom configuré: $name"
        fi
        
        echo ""
        echo "📋 Configuration actuelle:"
        echo "   Email: $(git config user.email)"
        echo "   Nom: $(git config user.name)"
    }
    
    # Gestion des arguments en ligne de commande
    if [ $# -eq 0 ]; then
        # Menu interactif
        while true; do
            show_main_menu
        done
    else
        # Commandes directes
        case "$1" in
            whoami)
                # Charger les fonctions depuis legacy si nécessaire
                if [ -f "$GIT_DIR/git_functions.sh" ]; then
                    source "$GIT_DIR/git_functions.sh" 2>/dev/null
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
                    source "$GIT_DIR/git_functions.sh" 2>/dev/null
                fi
                if command -v switch-git-identity >/dev/null 2>&1; then
                    shift
                    switch-git-identity "$@"
                else
                    echo "⚠️  Fonction switch-git-identity non disponible"
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
                local count="${2:-10}"
                git log --oneline -n "$count"
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
                local branch="${2:-}"
                if [ -n "$branch" ]; then
                    git push origin "$branch"
                else
                    git push
                fi
                ;;
            commit|cm)
                local message="$2"
                if [ -z "$message" ]; then
                    echo "❌ Message de commit requis"
                    echo "Usage: gitman commit 'message'"
                    return 1
                fi
                git commit -m "$message"
                ;;
            add-commit|ac)
                local files="${2:-.}"
                local message="$3"
                if [ -z "$message" ]; then
                    echo "❌ Message de commit requis"
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
                local branch="$2"
                if [ -z "$branch" ]; then
                    echo "❌ Nom de branche requis"
                    echo "Usage: gitman create-branch <name>"
                    return 1
                fi
                git checkout -b "$branch"
                ;;
            checkout|co)
                local branch="$2"
                if [ -z "$branch" ]; then
                    echo "❌ Nom de branche requis"
                    echo "Usage: gitman checkout <branch>"
                    return 1
                fi
                git checkout "$branch"
                ;;
            delete-branch|db)
                local branch="$2"
                if [ -z "$branch" ]; then
                    echo "❌ Nom de branche requis"
                    echo "Usage: gitman delete-branch <branch>"
                    return 1
                fi
                git branch -d "$branch" || git branch -D "$branch"
                ;;
            merge)
                local branch="$2"
                if [ -z "$branch" ]; then
                    echo "❌ Nom de branche requis"
                    echo "Usage: gitman merge <branch>"
                    return 1
                fi
                git merge "$branch"
                ;;
            rebase)
                local branch="$2"
                if [ -z "$branch" ]; then
                    echo "❌ Nom de branche requis"
                    echo "Usage: gitman rebase <branch>"
                    return 1
                fi
                git rebase "$branch"
                ;;
            abort)
                local type="${2:-merge}"
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
                local type="${2:-mixed}"
                local target="${3:-HEAD}"
                git reset --"$type" "$target"
                ;;
            stash)
                local action="${2:-list}"
                case "$action" in
                    create|save)
                        local message="$3"
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
                        local index="${3:-0}"
                        git stash apply "stash@{$index}"
                        ;;
                    drop|delete)
                        local index="$3"
                        if [ -z "$index" ]; then
                            echo "❌ Index requis"
                            return 1
                        fi
                        git stash drop "stash@{$index}"
                        ;;
                    *)
                        echo "Usage: gitman stash [create|list|apply|drop] [args]"
                        ;;
                esac
                ;;
            help|--help|-h)
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
                echo ""
                echo "Sans argument: menu interactif"
                ;;
            *)
                echo "❌ Commande inconnue: $1"
                echo "💡 Utilisez 'gitman help' pour voir les commandes disponibles"
                return 1
                ;;
        esac
    fi
}

