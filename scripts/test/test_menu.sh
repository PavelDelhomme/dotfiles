#!/usr/bin/env bash
# =============================================================================
# Menu interactif — lancer les tests dotfiles (Docker / local)
# =============================================================================
# Lancé par : make tests  (ou make test-menu)
# Ne modifie pas votre shell courant : les tests Docker s'exécutent dans des conteneurs.
# =============================================================================

set -u

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
export DOTFILES_DIR

if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    printf '%s\n' "Ce menu nécessite un terminal interactif (TTY)." >&2
    printf '%s\n' "Sans menu : make test-docker | make test-subcommands | make test-help" >&2
    exit 1
fi

# État session (réinitialisé au lancement du menu ; modifiable via sous-menus)
MENU_TEST_SHELLS=""
MENU_TEST_MANAGERS=""
MENU_ISOLATE="0"
MENU_SUBCOMMAND_TIER="full"

load_migrated_array() {
    MIGRATED=()
    local f line
    f="$DOTFILES_DIR/scripts/test/config/migrated_managers.list"
    if [[ ! -f "$f" ]]; then
        printf '%s\n' "Liste absente : $f" >&2
        return 1
    fi
    while IFS= read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        MIGRATED+=("$line")
    done <"$f"
}

show_config_summary() {
    printf '\n%s\n' "──────── Résumé configuration (cette session menu) ────────"
    printf '  Shells     : %s\n' "${MENU_TEST_SHELLS:-<défaut Docker : zsh bash fish ; matrice inclut sh si non surchargé>}"
    printf '  Managers   : %s\n' "${MENU_TEST_MANAGERS:-<défaut : tous les migrés (migrated_managers.list)>}"
    printf '  Bac à sable: %s\n' "$([[ "$MENU_ISOLATE" == "1" ]] && echo "OUI (copie /tmp avant montage)" || echo "non (montage direct du dépôt en lecture seule)")"
    printf '  Tier matrice: %s\n' "$MENU_SUBCOMMAND_TIER"
    printf '%s\n' "────────────────────────────────────────────────────────────"
}

apply_exports_for_run() {
    export DOTFILES_DIR
    export SUBCOMMAND_TIER="$MENU_SUBCOMMAND_TIER"
    if [[ -n "$MENU_TEST_SHELLS" ]]; then
        export TEST_SHELLS="$MENU_TEST_SHELLS"
    else
        unset TEST_SHELLS 2>/dev/null || true
    fi
    if [[ -n "$MENU_TEST_MANAGERS" ]]; then
        export TEST_MANAGERS="$MENU_TEST_MANAGERS"
    else
        unset TEST_MANAGERS 2>/dev/null || true
    fi
    if [[ "$MENU_ISOLATE" == "1" ]]; then
        export TEST_DOTFILES_ISOLATE=1
    else
        unset TEST_DOTFILES_ISOLATE 2>/dev/null || true
    fi
}

pause() {
    # Ne pas bloquer le terminal après un long Docker : timeout court, ou désactiver totalement.
    if [[ "${DOTFILES_TEST_MENU_SKIP_PAUSE:-0}" == "1" ]]; then
        return 0
    fi
    if [[ ! -t 0 ]]; then
        return 0
    fi
    printf '\n%s' "Entrée pour continuer (max 5 s, ou exportez DOTFILES_TEST_MENU_SKIP_PAUSE=1)… "
    read -r -t 5 _ 2>/dev/null || true
}

submenu_shells() {
    printf '\n%s\n' "══ Shells à tester (variable TEST_SHELLS dans le conteneur) ══"
    printf '%s\n' "  • manager_tester : charge les adapters par shell."
    printf '%s\n' "  • matrice sous-commandes : zsh, bash, fish, sh (si vous ne restreignez pas)."
    printf '%s\n' ""
    printf '%s\n' "  1) Défaut (ne pas fixer TEST_SHELLS — recommandé)"
    printf '%s\n' "  2) zsh uniquement"
    printf '%s\n' "  3) zsh bash"
    printf '%s\n' "  4) zsh bash fish"
    printf '%s\n' "  5) zsh bash fish sh (comme la matrice sous-commandes par défaut)"
    printf '%s\n' "  6) Saisie libre (ex: zsh bash)"
    printf '%s\n' "  0) Retour"
    printf '%s' "Choix : "
    read -r c
    case "$c" in
        1) MENU_TEST_SHELLS="" ;;
        2) MENU_TEST_SHELLS="zsh" ;;
        3) MENU_TEST_SHELLS="zsh bash" ;;
        4) MENU_TEST_SHELLS="zsh bash fish" ;;
        5) MENU_TEST_SHELLS="zsh bash fish sh" ;;
        6)
            printf '%s' "TEST_SHELLS= "
            read -r MENU_TEST_SHELLS
            ;;
        0 | "") ;;
        *) printf '%s\n' "Option non reconnue." ;;
    esac
}

submenu_managers() {
    load_migrated_array || return
    printf '\n%s\n' "══ Managers à tester (TEST_MANAGERS) ══"
    printf '%s\n' "  Vide = tous les managers migrés (fichier migrated_managers.list)."
    printf '%s\n' ""
    local i m
    i=1
    for m in "${MIGRATED[@]}"; do
        printf '  %2d) %s\n' "$i" "$m"
        i=$((i + 1))
    done
    printf '%s\n' ""
    printf '%s\n' "  a) Tous les migrés (réinitialiser la sélection)"
    printf '%s\n' "  b) Saisie manuelle (noms séparés par des espaces, ex: searchman pathman)"
    printf '%s\n' "  c) Choix par numéros (ex: 1 3 5 ou 1-3 pour plage)"
    printf '%s\n' "  0) Retour"
    printf '%s' "Choix : "
    read -r c
    case "$c" in
        a | A) MENU_TEST_MANAGERS="" ;;
        b | B)
            printf '%s' "Managers : "
            read -r MENU_TEST_MANAGERS
            ;;
        c | C)
            printf '%s' "Numéros : "
            read -r nums
            MENU_TEST_MANAGERS=""
            local a b j
            for tok in $nums; do
                if [[ "$tok" =~ ^[0-9]+-[0-9]+$ ]]; then
                    a=${tok%-*}
                    b=${tok#*-}
                    for ((j = a; j <= b; j++)); do
                        if ((j >= 1 && j <= ${#MIGRATED[@]})); then
                            MENU_TEST_MANAGERS+="${MIGRATED[$((j - 1))]} "
                        fi
                    done
                elif [[ "$tok" =~ ^[0-9]+$ ]]; then
                    if ((tok >= 1 && tok <= ${#MIGRATED[@]})); then
                        MENU_TEST_MANAGERS+="${MIGRATED[$((tok - 1))]} "
                    fi
                fi
            done
            MENU_TEST_MANAGERS=$(echo "$MENU_TEST_MANAGERS" | xargs)
            printf '  → TEST_MANAGERS=%s\n' "$MENU_TEST_MANAGERS"
            ;;
        0 | "") ;;
        *)
            if [[ "$c" =~ ^[0-9]+$ ]] && ((c >= 1 && c <= ${#MIGRATED[@]})); then
                MENU_TEST_MANAGERS="${MIGRATED[$((c - 1))]}"
                printf '  → un seul manager : %s\n' "$MENU_TEST_MANAGERS"
            else
                printf '%s\n' "Option non reconnue."
            fi
            ;;
    esac
}

submenu_options() {
    while true; do
        printf '\n%s\n' "══ Options supplémentaires ══"
        printf '%s\n' "  1) Bac à sable (TEST_DOTFILES_ISOLATE=1) : copie du dépôt → /tmp puis montage"
        printf '%s\n' "     (le conteneur ne voit plus directement votre arbre ; plus lent)"
        printf '%s\n' "     État actuel : $([[ "$MENU_ISOLATE" == "1" ]] && echo ACTIF || echo inactif)"
        printf '%s\n' ""
        printf '%s\n' "  2) Tier matrice sous-commandes : full | quick"
        printf '%s\n' "     Actuel : $MENU_SUBCOMMAND_TIER"
        printf '%s\n' ""
        printf '%s\n' "  0) Retour"
        printf '%s' "Choix : "
        read -r c
        case "$c" in
            1)
                if [[ "$MENU_ISOLATE" == "1" ]]; then MENU_ISOLATE=0; else MENU_ISOLATE=1; fi
                printf '  → Bac à sable : %s\n' "$([[ "$MENU_ISOLATE" == "1" ]] && echo ON || echo OFF)"
                ;;
            2)
                printf '%s' "Tier (full ou quick) : "
                read -r t
                if [[ "$t" == "quick" || "$t" == "full" ]]; then
                    MENU_SUBCOMMAND_TIER="$t"
                else
                    printf '%s\n' "  (inchangé : saisir exactement full ou quick)"
                fi
                ;;
            0 | "") break ;;
            *) printf '%s\n' "Option non reconnue." ;;
        esac
    done
}

submenu_configure() {
    while true; do
        printf '\n%s\n' "══ Configuration avant lancement ══"
        show_config_summary
        printf '%s\n' "  1) Choisir les shells"
        printf '%s\n' "  2) Choisir les managers"
        printf '%s\n' "  3) Options (bac à sable, tier quick/full)"
        printf '%s\n' "  0) Retour au menu principal"
        printf '%s' "Choix : "
        read -r c
        case "$c" in
            1) submenu_shells ;;
            2) submenu_managers ;;
            3) submenu_options ;;
            0 | "") break ;;
            *) printf '%s\n' "Option non reconnue." ;;
        esac
    done
}

run_full_docker() {
    printf '\n%s\n' "→ Lancement : suite Docker complète (manager_tester + matrice sous-commandes)…"
    apply_exports_for_run
    export RUN_SUBCOMMAND_MATRIX=1
    bash "$DOTFILES_DIR/scripts/test/test_migrated_managers.sh"
    local rc=$?
    printf '\n%s\n' "Code de sortie : $rc"
    pause
    return "$rc"
}

run_subcommands_only() {
    printf '\n%s\n' "→ Lancement : matrice sous-commandes uniquement (Docker)…"
    apply_exports_for_run
    bash "$DOTFILES_DIR/scripts/test/docker/run_subcommand_matrix_docker.sh"
    local rc=$?
    printf '\n%s\n' "Code de sortie : $rc"
    pause
    return "$rc"
}

run_checks_local() {
    printf '\n%s\n' "→ Lancement : vérifications projet (syntaxe, URLs, …) en local…"
    bash "$DOTFILES_DIR/scripts/test/run_checks.sh"
    local rc=$?
    pause
    return "$rc"
}

run_test_all_local() {
    printf '\n%s\n' "→ Lancement : tests locaux sans Docker (syntaxe / présence)…"
    if [[ -f "$DOTFILES_DIR/scripts/test/test_dotfiles.sh" ]]; then
        bash "$DOTFILES_DIR/scripts/test/test_dotfiles.sh"
    else
        printf '%s\n' "  (test_dotfiles.sh absent — essayez make test-syntax)"
    fi
    pause
}

print_help_text() {
    printf '\n%s\n' "══ Aide rapide ══"
    printf '%s\n' "  • make test-docker      — même chose que l’option 1 du menu (sans interaction)."
    printf '%s\n' "  • make test-subcommands — matrice seule."
    printf '%s\n' "  • make test-help        — variables d’environnement et fichier test.local.env."
    printf '%s\n' "  • Fichier perso : scripts/test/config/test.local.env (voir test.local.env.example)"
    printf '%s\n' ""
    make -C "$DOTFILES_DIR" test-help 2>/dev/null || true
    pause
}

main_menu() {
    while true; do
        clear
        printf '%s\n' "╔════════════════════════════════════════════════════════════╗"
        printf '%s\n' "║           Dotfiles — menu des tests                      ║"
        printf '%s\n' "╚════════════════════════════════════════════════════════════╝"
        printf '%s\n' ""
        printf '%s\n' "Les tests Docker s’exécutent dans un conteneur : votre shell actuel"
        printf '%s\n' "n’est pas modifié. Le dépôt est monté en lecture seule (sauf bac à sable)."
        printf '%s\n' ""
        printf '%s\n' "Pour essayer installman (ollama, pyenv, …) dans un conteneur sans questions :"
        printf '%s\n' "  make docker-in   puis   export INSTALLMAN_ASSUME_YES=1 DOTFILES_DIR=/root/dotfiles"
        printf '%s\n' "  installman help   |   installman ollama   (échec possible si pas sudo dans l’image)"
        printf '%s\n' ""
        show_config_summary
        printf '%s\n' "──────────────── Actions ────────────────"
        printf '%s\n' "  1) Suite complète Docker (managers migrés + matrice sous-commandes)"
        printf '%s\n' "     → identique à « make test-docker » avec RUN_SUBCOMMAND_MATRIX=1."
        printf '%s\n' ""
        printf '%s\n' "  2) Matrice sous-commandes seulement (plus rapide)"
        printf '%s\n' "     → identique à « make test-subcommands »."
        printf '%s\n' ""
        printf '%s\n' "  3) Vérifications projet (local, sans Docker)"
        printf '%s\n' "     → « make test-checks » (syntaxe, URLs, …)."
        printf '%s\n' ""
        printf '%s\n' "  4) Tests locaux légers (sans Docker, si disponible)"
        printf '%s\n' "     → « make test-all » / test_dotfiles.sh."
        printf '%s\n' ""
        printf '%s\n' "  5) Configurer shells / managers / options… puis relancer 1 ou 2"
        printf '%s\n' ""
        printf '%s\n' "  6) Aide (make test-help + rappels)"
        printf '%s\n' ""
        printf '%s\n' "  0) Quitter"
        printf '%s' "Votre choix : "
        read -r choice
        case "$choice" in
            1) run_full_docker ;;
            2) run_subcommands_only ;;
            3) run_checks_local ;;
            4) run_test_all_local ;;
            5) submenu_configure ;;
            6) print_help_text ;;
            0 | q | Q) printf '\n%s\n' "Au revoir."; break ;;
            *) printf '\n%s\n' "Choix invalide."; sleep 1 ;;
        esac
    done
}

load_migrated_array
main_menu
