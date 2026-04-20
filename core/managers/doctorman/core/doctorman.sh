#!/bin/sh
# =============================================================================
# DOCTORMAN - Diagnostic dotfiles + environnement dev (POSIX)
# =============================================================================
# USAGE: doctorman | doctorman all | doctorman dotfiles | doctorman dev | doctorman fish
# =============================================================================

__doctorman_ok()  { printf "  \033[0;32m✓\033[0m %s\n" "$1"; }
__doctorman_fail(){ printf "  \033[0;31m✗\033[0m %s\n" "$1"; }
__doctorman_warn(){ printf "  \033[1;33m!\033[0m %s\n" "$1"; }
__doctorman_sec() { printf "\n\033[1m%s\033[0m\n" "$1"; }

__doctorman_help() {
    printf "\033[0;36m\033[1mDOCTORMAN\033[0m — diagnostic dotfiles et outils dev\n\n"
    printf "  \033[1mdoctorman\033[0m ou \033[1mdoctorman all\033[0m   tout exécuter\n"
    printf "  \033[1mdoctorman dotfiles\033[0m   syntaxe cores/adapters + run_checks si présent\n"
    printf "  \033[1mdoctorman fish\033[0m       vérification config fish (fish -n)\n"
    printf "  \033[1mdoctorman dev\033[0m        Flutter (SDK inscriptible), Android cmdline-tools, Chrome\n"
    printf "  \033[1mdoctorman help\033[0m       cette aide\n"
}

__doctorman_dotfiles() {
    DF="${DOTFILES_DIR:-$HOME/dotfiles}"
    __doctorman_sec "Dotfiles — syntaxe POSIX (core/managers)"
    n=0
    ok=0
    for f in "$DF"/core/managers/*/core/*.sh; do
        [ -f "$f" ] || continue
        n=$((n+1))
        if sh -n "$f" 2>/dev/null; then ok=$((ok+1)); else __doctorman_fail "Syntaxe: $f"; fi
    done
    [ "$n" -gt 0 ] && __doctorman_ok "Cores POSIX: $ok/$n OK"

    __doctorman_sec "Dotfiles — adapters ZSH"
    if command -v zsh >/dev/null 2>&1; then
        nz=0
        oz=0
        for f in "$DF"/shells/zsh/adapters/*.zsh; do
            [ -f "$f" ] || continue
            nz=$((nz+1))
            if zsh -n "$f" 2>/dev/null; then oz=$((oz+1)); else __doctorman_fail "ZSH: $f"; fi
        done
        [ "$nz" -gt 0 ] && __doctorman_ok "Adapters ZSH: $oz/$nz OK"
    else
        __doctorman_warn "zsh absent — skip adapters"
    fi

    __doctorman_sec "Dotfiles — run_checks (syntaxe + URLs)"
    if [ -f "$DF/scripts/test/run_checks.sh" ]; then
        if bash "$DF/scripts/test/run_checks.sh"; then
            __doctorman_ok "run_checks.sh terminé"
        else
            __doctorman_warn "run_checks.sh a signalé des problèmes (voir ci-dessus)"
        fi
    else
        __doctorman_warn "run_checks.sh introuvable"
    fi
}

__doctorman_fish() {
    DF="${DOTFILES_DIR:-$HOME/dotfiles}"
    __doctorman_sec "Fish — configuration"
    if ! command -v fish >/dev/null 2>&1; then
        __doctorman_warn "fish non installé"
        return 0
    fi
    for c in "$HOME/.config/fish/config.fish" "$DF/fish/config_custom.fish"; do
        if [ -f "$c" ]; then
            if fish -n "$c" 2>/dev/null; then
                __doctorman_ok "Syntaxe OK: $c"
            else
                __doctorman_fail "Syntaxe fish: $c"
            fi
        fi
    done
}

__doctorman_dev() {
    DF="${DOTFILES_DIR:-$HOME/dotfiles}"
    __doctorman_sec "Flutter"
    if command -v flutter >/dev/null 2>&1; then
        __doctorman_ok "flutter: $(command -v flutter)"
        gradle_dir="/usr/lib/flutter/packages/flutter_tools/gradle"
        if [ -d "$gradle_dir" ]; then
            if [ -w "$gradle_dir" ]; then
                __doctorman_ok "SDK système inscriptible: $gradle_dir (builds Android OK)"
            else
                __doctorman_fail "SDK Flutter système NON inscriptible: $gradle_dir"
                printf "      \033[1;33m→\033[0m sudo chown -R \"\$(whoami)\" /usr/lib/flutter\n"
                printf "      \033[1;33mou\033[0m Flutter dans \$HOME + PATH avant /usr/bin\n"
            fi
        else
            __doctorman_warn "Pas de /usr/lib/flutter/.../gradle (Flutter user ou autre layout)"
        fi
    else
        __doctorman_warn "flutter absent du PATH"
    fi

    __doctorman_sec "Android (licences / sdkmanager)"
    ah="${ANDROID_HOME:-$HOME/Android/Sdk}"
    [ -d "$ah" ] || ah="/opt/android-sdk"
    if [ -d "$ah" ]; then
        __doctorman_ok "ANDROID_HOME candidate: $ah"
        sm=""
        for p in "$ah/cmdline-tools/latest/bin/sdkmanager" "$ah/cmdline-tools/bin/sdkmanager"; do
            if [ -x "$p" ]; then sm="$p"; break; fi
        done
        if [ -n "$sm" ]; then
            __doctorman_ok "sdkmanager: $sm"
        else
            __doctorman_fail "sdkmanager introuvable (installer cmdline-tools dans le SDK)"
            printf "      \033[1;33m→\033[0m installman android-tools ou Android Studio → SDK Manager\n"
        fi
    else
        __doctorman_warn "Répertoire SDK Android introuvable (ANDROID_HOME)"
    fi

    __doctorman_sec "Chrome / Chromium (flutter web)"
    if [ -x /usr/bin/google-chrome-stable ] || [ -x /usr/bin/google-chrome ]; then
        __doctorman_ok "Chrome: google-chrome présent"
    elif [ -x /usr/bin/chromium ]; then
        __doctorman_ok "Chromium: /usr/bin/chromium"
    elif [ -x /usr/bin/chromium-browser ]; then
        __doctorman_ok "Chromium: chromium-browser"
    else
        __doctorman_fail "Pas d'exécutable Chrome/Chromium standard pour flutter web"
        printf "      \033[1;33m→\033[0m CHROME_EXECUTABLE ou installman chrome\n"
    fi
}

__doctorman_all() {
    printf "\033[1m═══════════════════════════════════════════════════════════════\033[0m\n"
    printf "\033[1m  DOCTORMAN — rapport complet\033[0m\n"
    printf "\033[1m═══════════════════════════════════════════════════════════════\033[0m\n"
    __doctorman_dotfiles
    __doctorman_fish
    __doctorman_dev
    printf "\n\033[0;36mTerminé.\033[0m Corrige les ✗ avant de relancer les builds.\n\n"
}

doctorman() {
    _logdf="${DOTFILES_DIR:-$HOME/dotfiles}"
    [ -f "$_logdf/scripts/lib/managers_log_posix.sh" ] && . "$_logdf/scripts/lib/managers_log_posix.sh" && managers_cli_log doctorman "$@"
    cmd="${1:-all}"
    case "$cmd" in
        help|-h|--help) __doctorman_help ;;
        all|run)       __doctorman_all ;;
        dotfiles|df)   __doctorman_dotfiles ;;
        fish)          __doctorman_fish ;;
        dev|flutter)   __doctorman_dev ;;
        *)
            printf "\033[0;31mCommande inconnue:\033[0m %s\n" "$cmd"
            __doctorman_help
            ;;
    esac
}
