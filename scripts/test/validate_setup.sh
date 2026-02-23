#!/bin/bash

################################################################################
# Validation complète du setup dotfiles
# Vérifie ABSOLUMENT TOUT : installations, configurations, fichiers, scripts,
# fonctions, structure, services, outils, symlinks, etc.
################################################################################

set +e  # Ne pas arrêter sur erreurs pour continuer toutes les vérifications

# Charger la bibliothèque commune
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# S'assurer que DOTFILES_DIR pointe vers la racine du dépôt
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
# Si SCRIPT_DIR contient "scripts", alors DOTFILES_DIR est le parent
if [[ "$SCRIPT_DIR" == *"/scripts" ]]; then
    DOTFILES_DIR="${SCRIPT_DIR%/scripts}"
elif [ -z "$DOTFILES_DIR" ] || [ ! -d "$DOTFILES_DIR" ]; then
    # Essayer de détecter depuis le script
    DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi
# Vérification finale
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "Erreur: Impossible de déterminer DOTFILES_DIR" >&2
    exit 1
fi

source "$SCRIPT_DIR/lib/common.sh" || {
    echo "Erreur: Impossible de charger la bibliothèque commune"
    exit 1
}

# Initialiser les compteurs
PASSED=0
FAILED=0
WARNINGS=0

# Tableaux pour stocker les messages
FAILED_ITEMS=()
WARNED_ITEMS=()

check_pass() {
    echo -e "${GREEN}✅${NC} $1"
    ((PASSED++))
}

check_fail() {
    echo -e "${RED}❌${NC} $1"
    ((FAILED++))
    FAILED_ITEMS+=("$1")
}

check_warn() {
    echo -e "${YELLOW}⚠️${NC} $1"
    ((WARNINGS++))
    WARNED_ITEMS+=("$1")
}

log_section() {
    echo -e "\n${BLUE}═══════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}═══════════════════════════════════${NC}\n"
}

################################################################################
# VÉRIFICATIONS FONCTIONS ZSH
################################################################################
log_section "Vérifications fonctions ZSH"

# Note: Les fonctions ZSH ne sont disponibles que dans un shell ZSH interactif
# Dans un script bash, elles ne seront pas disponibles - c'est normal
# On vérifie si les fichiers sources existent et sont correctement chargés

# Vérifier add_alias (définie dans alias_utils.zsh)
if type add_alias &> /dev/null; then
    check_pass "add_alias disponible"
else
    # Vérifier si le fichier source existe et est chargé dans zshrc_custom
    if [ -f "$DOTFILES_DIR/zsh/functions/utils/alias_utils.zsh" ]; then
        if grep -q "alias_utils.zsh" "$DOTFILES_DIR/zsh/zshrc_custom" 2>/dev/null || \
           grep -q "zshrc_custom\|dotfiles" "$HOME/.zshrc" 2>/dev/null; then
            check_pass "add_alias configuré (disponible dans ZSH interactif)"
        else
            check_warn "add_alias: fichier présent mais non chargé dans zshrc_custom"
        fi
    else
        check_warn "add_alias: fichier source manquant (alias_utils.zsh)"
    fi
fi

# Vérifier add_to_path (définie dans pathman.zsh, utilisée dans env.sh)
if type add_to_path &> /dev/null; then
    check_pass "add_to_path disponible"
else
    # Vérifier si pathman.zsh existe et est chargé, et si env.sh l'utilise
    if [ -f "$DOTFILES_DIR/zsh/functions/pathman.zsh" ]; then
        if grep -q "pathman.zsh" "$DOTFILES_DIR/zsh/zshrc_custom" 2>/dev/null && \
           grep -q "add_to_path" "$DOTFILES_DIR/zsh/env.sh" 2>/dev/null; then
            check_pass "add_to_path configuré (disponible dans ZSH interactif via pathman)"
        else
            check_warn "add_to_path: pathman.zsh présent mais configuration incomplète"
        fi
    else
        check_warn "add_to_path: fichier source manquant (pathman.zsh)"
    fi
fi

# Vérifier clean_path (définie dans pathman.zsh, utilisée dans env.sh)
if type clean_path &> /dev/null; then
    check_pass "clean_path disponible"
else
    # Vérifier si pathman.zsh existe et est chargé, et si env.sh l'utilise
    if [ -f "$DOTFILES_DIR/zsh/functions/pathman.zsh" ]; then
        if grep -q "pathman.zsh" "$DOTFILES_DIR/zsh/zshrc_custom" 2>/dev/null && \
           grep -q "clean_path" "$DOTFILES_DIR/zsh/env.sh" 2>/dev/null; then
            check_pass "clean_path configuré (disponible dans ZSH interactif via pathman)"
        else
            check_warn "clean_path: pathman.zsh présent mais configuration incomplète"
        fi
    else
        check_warn "clean_path: fichier source manquant (pathman.zsh)"
    fi
fi

################################################################################
# VÉRIFICATIONS PATH
################################################################################
log_section "Vérifications PATH"

PATHS_TO_CHECK=(
    "/usr/local/go/bin:Go"
    "$HOME/go/bin:Go (GOPATH)"
    "/opt/flutter/bin:Flutter"
    "$ANDROID_SDK_ROOT/platform-tools:Android SDK"
    "$HOME/.pub-cache/bin:Dart pub-cache"
)

for path_entry in "${PATHS_TO_CHECK[@]}"; do
    IFS=':' read -r path name <<< "$path_entry"
    if [ -n "$path" ] && [[ ":$PATH:" == *":$path:"* ]]; then
        check_pass "Chemin présent: $name ($path)"
    else
        check_warn "Chemin manquant: $name ($path)"
    fi
done

# Vérification spécifique Flutter dans PATH
if command -v flutter &> /dev/null; then
    FLUTTER_PATH=$(which flutter)
    check_pass "Flutter trouvé dans PATH: $FLUTTER_PATH"
else
    # Flutter n'est pas critique, juste un avertissement
    check_warn "Flutter non trouvé dans PATH (optionnel, vérifiez /opt/flutter/bin si nécessaire)"
fi

################################################################################
# VÉRIFICATIONS SERVICES
################################################################################
log_section "Vérifications services systemd"

if systemctl --user is-active --quiet dotfiles-sync.timer 2>/dev/null; then
    NEXT_RUN=$(systemctl --user list-timers dotfiles-sync.timer --no-legend 2>/dev/null | awk '{print $1, $2, $3}' | head -n1)
    check_pass "Timer auto-sync actif (prochain: $NEXT_RUN)"
elif systemctl --user is-enabled --quiet dotfiles-sync.timer 2>/dev/null; then
    check_warn "Timer auto-sync activé mais arrêté"
    echo "  → Solution: systemctl --user start dotfiles-sync.timer"
else
    check_warn "Timer auto-sync non configuré"
    echo "  → Solution: setup.sh option 12 (Installation auto-sync Git)"
fi

if systemctl is-active --quiet docker 2>/dev/null; then
    check_pass "Service Docker actif"
else
    check_warn "Service Docker non actif (optionnel)"
fi

# Vérification permissions Docker
if command -v docker &> /dev/null; then
    if docker ps &> /dev/null; then
        check_pass "Permissions Docker OK (utilisateur dans groupe docker)"
    else
        check_fail "Permissions Docker refusées"
        echo "  → Solution: sudo usermod -aG docker \$USER"
        echo "  → Puis: déconnectez-vous et reconnectez-vous"
    fi
fi

# Vérification SSH agent
if pgrep -x ssh-agent > /dev/null; then
    check_pass "SSH agent actif"
else
    # Vérifier si le socket systemd est configuré (démarre automatiquement)
    if systemctl --user is-enabled ssh-agent.socket &>/dev/null 2>&1; then
        check_pass "SSH agent configuré via systemd socket (démarre automatiquement)"
    elif systemctl --user list-unit-files | grep -q "ssh-agent" 2>/dev/null; then
        check_warn "SSH agent non actif mais disponible via systemd (optionnel, démarre à la demande)"
        echo "  → Solution: make fix FIX=ssh-agent"
    else
        check_warn "SSH agent non actif (peut être normal, démarre à la demande)"
        echo "  → Solution: make fix FIX=ssh-agent"
    fi
fi

################################################################################
# VÉRIFICATIONS GIT
################################################################################
log_section "Vérifications Git"

if [ -n "$(git config --global user.name)" ]; then
    check_pass "Git user.name configuré: $(git config --global user.name)"
else
    check_fail "Git user.name non configuré"
fi

if [ -n "$(git config --global user.email)" ]; then
    check_pass "Git user.email configuré: $(git config --global user.email)"
else
    check_fail "Git user.email non configuré"
fi

if [ -n "$(git config --global credential.helper)" ]; then
    check_pass "Git credential.helper configuré: $(git config --global credential.helper)"
else
    check_warn "Git credential.helper non configuré (optionnel)"
fi

if [ -f "$HOME/.ssh/id_ed25519" ]; then
    check_pass "Clé SSH ED25519 présente"
else
    check_warn "Clé SSH ED25519 absente (optionnel)"
fi

# Test connexion GitHub
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    check_pass "Connexion GitHub SSH OK"
else
    check_warn "Connexion GitHub SSH non vérifiée"
    echo "  → Vérifiez que votre clé SSH est ajoutée sur GitHub"
    echo "  → URL: https://github.com/settings/keys"
    echo "  → Test manuel: ssh -T git@github.com"
fi

################################################################################
# VÉRIFICATIONS OUTILS
################################################################################
log_section "Vérifications outils installés"

TOOLS_TO_CHECK=(
    "go:Go"
    "docker:Docker"
    "docker-compose:Docker Compose"
    "cursor:Cursor IDE"
    "yay:yay (AUR)"
    "make:make"
    "gcc:gcc"
    # "cmake:cmake"  # Commenté - vérification spéciale en dessous si nécessaire
    "pkg-config:pkg-config"
    "neofetch:neofetch"
)

for tool_entry in "${TOOLS_TO_CHECK[@]}"; do
    IFS=':' read -r tool name <<< "$tool_entry"
    
    # Vérification spéciale pour Cursor AppImage (vérifier d'abord le fichier)
    if [ "$tool" = "cursor" ]; then
        CURSOR_APPIMAGE="$HOME/Applications/cursor.AppImage"
        if [ -f "$CURSOR_APPIMAGE" ]; then
            # Vérifier si le fichier est exécutable
            if [ -x "$CURSOR_APPIMAGE" ]; then
                # Ne pas exécuter l'AppImage pour obtenir la version (cela lance Cursor)
                # Vérifier juste la présence et l'exécutabilité
                check_pass "Cursor IDE: AppImage présent et exécutable ($CURSOR_APPIMAGE)"
            else
                check_warn "Cursor IDE: AppImage présent mais non exécutable ($CURSOR_APPIMAGE)"
                echo "  → Solution: chmod +x $CURSOR_APPIMAGE"
            fi
            continue  # Passer au suivant, on a déjà vérifié Cursor
        fi
    fi
    
    # Vérification standard pour les autres outils
    if command -v "$tool" &> /dev/null; then
        VERSION=$($tool --version 2>/dev/null | head -n1 || echo "version inconnue")
        check_pass "$name: $VERSION"
    else
        # Vérification spéciale pour cmake (COMMENTÉ - décommenter si nécessaire)
        # Chercher dans plusieurs emplacements communs: /usr, /opt, /var, ~/.local, ~, etc.
        # if [ "$tool" = "cmake" ]; then
        if false && [ "$tool" = "cmake" ]; then
            CMAKE_FOUND=0
            CMAKE_PATH=""
            CMAKE_VERSION=""
            
            # Liste des emplacements à vérifier
            SEARCH_PATHS=(
                "/usr/bin/cmake"
                "/usr/local/bin/cmake"
                "/opt/cmake/bin/cmake"
                "/opt/*/bin/cmake"
                "$HOME/.local/bin/cmake"
                "$HOME/bin/cmake"
                "$HOME/Applications/cmake"
                "/var/cache/cmake"
                "/var/lib/cmake"
            )
            
            # Chercher dans les chemins standards
            for search_path in "${SEARCH_PATHS[@]}"; do
                # Gérer les wildcards
                if [[ "$search_path" == *"*"* ]]; then
                    # Chercher dans les sous-dossiers (utiliser find pour les wildcards)
                    while IFS= read -r found_path; do
                        if [ -f "$found_path" ] && [ -x "$found_path" ]; then
                            CMAKE_PATH="$found_path"
                            CMAKE_FOUND=1
                            break 2  # Break de la boucle for et while
                        fi
                    done < <(find /opt -path "*/bin/cmake" -type f 2>/dev/null)
                else
                    if [ -f "$search_path" ] && [ -x "$search_path" ]; then
                        CMAKE_PATH="$search_path"
                        CMAKE_FOUND=1
                        break
                    fi
                fi
            done
            
            # Si pas trouvé, chercher avec find dans les emplacements communs
            if [ $CMAKE_FOUND -eq 0 ]; then
                for search_dir in "/usr" "/usr/local" "/opt" "$HOME/.local" "$HOME" "/var"; do
                    if [ -d "$search_dir" ]; then
                        CMAKE_PATH=$(find "$search_dir" -name "cmake" -type f -executable 2>/dev/null | head -1)
                        if [ -n "$CMAKE_PATH" ]; then
                            CMAKE_FOUND=1
                            break
                        fi
                    fi
                done
            fi
            
            # Vérifier aussi si le package est installé (Arch Linux)
            if [ $CMAKE_FOUND -eq 0 ] && [ -f /etc/arch-release ]; then
                if pacman -Q cmake &>/dev/null 2>&1 || yay -Q cmake &>/dev/null 2>&1; then
                    # Package installé mais binaire non trouvé
                    CMAKE_FOUND=2  # Code spécial pour package installé mais non accessible
                fi
            fi
            
            # Afficher le résultat
            if [ $CMAKE_FOUND -eq 1 ] && [ -n "$CMAKE_PATH" ]; then
                CMAKE_VERSION=$("$CMAKE_PATH" --version 2>/dev/null | head -n1 || echo "installé mais version non accessible")
                check_warn "cmake trouvé mais non dans PATH: $CMAKE_VERSION"
                echo "  → Chemin trouvé: $CMAKE_PATH"
                echo "  → Solution: ajouter au PATH ou créer un symlink"
            elif [ $CMAKE_FOUND -eq 2 ]; then
                check_warn "cmake: package installé mais binaire non accessible"
                echo "  → Solution: réinstaller cmake ou vérifier l'installation"
            else
                check_warn "cmake non installé (optionnel)"
            fi
        # fi  # Fin de la vérification cmake (décommenter si nécessaire)
        elif [ "$tool" = "yay" ] && [ ! -f /etc/arch-release ]; then
            # yay n'est applicable que sur Arch
            continue
        # Pour Cursor, si command -v ne le trouve pas et que l'AppImage n'existe pas
        elif [ "$tool" = "cursor" ]; then
            check_warn "Cursor IDE non installé (optionnel)"
            echo "  → Emplacement attendu: $HOME/Applications/cursor.AppImage"
        else
            check_warn "$name non installé (optionnel)"
        fi
    fi
done


################################################################################
# VÉRIFICATIONS NVIDIA
################################################################################
log_section "Vérifications NVIDIA (si présent)"

if command -v nvidia-smi &> /dev/null; then
    if nvidia-smi &> /dev/null; then
        GPU_INFO=$(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -n1)
        check_pass "NVIDIA GPU détecté: $GPU_INFO"
        
        # Vérifier configuration Xorg
        if [ -f /etc/X11/xorg.conf ] || [ -f /etc/X11/xorg.conf.d/*nvidia* ]; then
            check_pass "Configuration Xorg NVIDIA présente"
        else
            check_warn "Configuration Xorg NVIDIA non trouvée (peut être normal)"
        fi
        
        # Vérifier nvidia-prime
        if command -v prime-run &> /dev/null; then
            check_pass "nvidia-prime installé (prime-run disponible)"
        else
            check_warn "nvidia-prime non installé (optionnel)"
        fi
    else
        check_fail "nvidia-smi échoue (GPU non détecté ou pilotes non chargés)"
    fi
else
    check_warn "NVIDIA non détecté (normal si pas de GPU NVIDIA)"
fi

################################################################################
# VÉRIFICATIONS STRUCTURE DOTFILES
################################################################################
log_section "Vérifications structure dotfiles"

# Fichiers principaux racine
ROOT_FILES=(
    "$DOTFILES_DIR/bootstrap.sh:bootstrap.sh"
    "$DOTFILES_DIR/scripts/setup.sh:scripts/setup.sh"
    "$DOTFILES_DIR/Makefile:Makefile"
    "$DOTFILES_DIR/README.md:README.md"
    "$DOTFILES_DIR/docs/STATUS.md:docs/STATUS.md"
    "$DOTFILES_DIR/docs/STRUCTURE.md:docs/STRUCTURE.md"
    "$DOTFILES_DIR/zshrc:zshrc (shell detector)"
)

for file_entry in "${ROOT_FILES[@]}"; do
    IFS=':' read -r file name <<< "$file_entry"
    if [ -f "$file" ]; then
        check_pass "Fichier racine: $name"
    else
        check_fail "Fichier racine manquant: $name"
    fi
done

# Bibliothèque commune
if [ -f "$SCRIPT_DIR/lib/common.sh" ]; then
    check_pass "Bibliothèque commune: common.sh"
    if [ -x "$SCRIPT_DIR/lib/common.sh" ]; then
        check_pass "Bibliothèque commune exécutable"
    else
        check_warn "Bibliothèque commune non exécutable (normal)"
    fi
else
    check_fail "Bibliothèque commune manquante: lib/common.sh"
fi

# Structure ZSH
ZSH_FILES=(
    "$DOTFILES_DIR/zsh/zshrc_custom:zshrc_custom"
    "$DOTFILES_DIR/zsh/env.sh:env.sh"
    "$DOTFILES_DIR/zsh/aliases.zsh:aliases.zsh"
    "$DOTFILES_DIR/zsh/path_log.txt:path_log.txt"
    "$DOTFILES_DIR/zsh/PATH_SAVE:PATH_SAVE"
)

for file_entry in "${ZSH_FILES[@]}"; do
    IFS=':' read -r file name <<< "$file_entry"
    if [ -f "$file" ]; then
        check_pass "Fichier ZSH: $name"
    else
        check_warn "Fichier ZSH manquant (optionnel): $name"
    fi
done

# Structure Fish
if command -v fish &> /dev/null; then
    FISH_FILES=(
        "$DOTFILES_DIR/fish/config_custom.fish:config_custom.fish"
        "$DOTFILES_DIR/fish/aliases.fish:aliases.fish"
        "$DOTFILES_DIR/fish/env.fish:env.fish"
    )
    for file_entry in "${FISH_FILES[@]}"; do
        IFS=':' read -r file name <<< "$file_entry"
        if [ -f "$file" ]; then
            check_pass "Fichier Fish: $name"
        else
            check_warn "Fichier Fish manquant: $name"
        fi
    done
else
    check_warn "Fish non installé (vérifications Fish ignorées)"
fi

# Images
if [ -f "$DOTFILES_DIR/images/icons/cursor.png" ]; then
    check_pass "Image Cursor: cursor.png"
else
    check_warn "Image Cursor manquante (optionnel): cursor.png"
fi

################################################################################
# VÉRIFICATIONS SCRIPTS D'INSTALLATION
################################################################################
log_section "Vérifications scripts d'installation"

INSTALL_SCRIPTS=(
    "$SCRIPT_DIR/install/system/packages_base.sh:packages_base.sh"
    "$SCRIPT_DIR/install/system/package_managers.sh:package_managers.sh"
    "$SCRIPT_DIR/install/apps/install_brave.sh:install_brave.sh"
    "$SCRIPT_DIR/install/apps/install_chrome.sh:install_chrome.sh"
    "$SCRIPT_DIR/install/apps/install_cursor.sh:install_cursor.sh"
    "$SCRIPT_DIR/install/apps/install_portproton.sh:install_portproton.sh"
    "$SCRIPT_DIR/install/dev/install_docker.sh:install_docker.sh"
    "$SCRIPT_DIR/install/dev/install_docker_tools.sh:install_docker_tools.sh"
    "$SCRIPT_DIR/install/dev/install_go.sh:install_go.sh"
    "$SCRIPT_DIR/install/tools/install_yay.sh:install_yay.sh"
    "$SCRIPT_DIR/install/tools/install_qemu_full.sh:install_qemu_full.sh"
    "$SCRIPT_DIR/install/tools/verify_network.sh:verify_network.sh"
    "$SCRIPT_DIR/install/install_all.sh:install_all.sh"
)

for script_entry in "${INSTALL_SCRIPTS[@]}"; do
    IFS=':' read -r script name <<< "$script_entry"
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            check_pass "Script install: $name (exécutable)"
        else
            check_warn "Script install: $name (non exécutable)"
        fi
    else
        check_fail "Script install manquant: $name"
    fi
done

################################################################################
# VÉRIFICATIONS SCRIPTS CONFIGURATION
################################################################################
log_section "Vérifications scripts configuration"

CONFIG_SCRIPTS=(
    "$SCRIPT_DIR/config/create_symlinks.sh:create_symlinks.sh"
    "$SCRIPT_DIR/config/git_config.sh:git_config.sh"
    "$SCRIPT_DIR/config/git_remote.sh:git_remote.sh"
    "$SCRIPT_DIR/config/qemu_packages.sh:qemu_packages.sh"
    "$SCRIPT_DIR/config/qemu_network.sh:qemu_network.sh"
    "$SCRIPT_DIR/config/qemu_libvirt.sh:qemu_libvirt.sh"
)

for script_entry in "${CONFIG_SCRIPTS[@]}"; do
    IFS=':' read -r script name <<< "$script_entry"
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            check_pass "Script config: $name (exécutable)"
        else
            check_warn "Script config: $name (non exécutable)"
        fi
    else
        check_warn "Script config manquant (optionnel): $name"
    fi
done

################################################################################
# VÉRIFICATIONS SCRIPTS SYNC
################################################################################
log_section "Vérifications scripts synchronisation"

SYNC_SCRIPTS=(
    "$SCRIPT_DIR/sync/git_auto_sync.sh:git_auto_sync.sh"
    "$SCRIPT_DIR/sync/install_auto_sync.sh:install_auto_sync.sh"
    "$SCRIPT_DIR/sync/restore_from_git.sh:restore_from_git.sh"
)

for script_entry in "${SYNC_SCRIPTS[@]}"; do
    IFS=':' read -r script name <<< "$script_entry"
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            check_pass "Script sync: $name (exécutable)"
        else
            check_warn "Script sync: $name (non exécutable)"
        fi
    else
        check_fail "Script sync manquant: $name"
    fi
done

################################################################################
# VÉRIFICATIONS SCRIPTS UNINSTALL
################################################################################
log_section "Vérifications scripts désinstallation"

UNINSTALL_SCRIPTS=(
    "$SCRIPT_DIR/uninstall/rollback_all.sh:rollback_all.sh"
    "$SCRIPT_DIR/uninstall/rollback_git.sh:rollback_git.sh"
    "$SCRIPT_DIR/uninstall/reset_all.sh:reset_all.sh"
)

for script_entry in "${UNINSTALL_SCRIPTS[@]}"; do
    IFS=':' read -r script name <<< "$script_entry"
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            check_pass "Script uninstall: $name (exécutable)"
        else
            check_warn "Script uninstall: $name (non exécutable)"
        fi
    else
        check_warn "Script uninstall manquant (optionnel): $name"
    fi
done

################################################################################
# VÉRIFICATIONS SCRIPTS MIGRATION
################################################################################
log_section "Vérifications scripts migration"

if [ -f "$SCRIPT_DIR/migrate_shell.sh" ]; then
    if [ -x "$SCRIPT_DIR/migrate_shell.sh" ]; then
        check_pass "Script migration shell (exécutable)"
    else
        check_warn "Script migration shell (non exécutable)"
    fi
else
    check_warn "Script migration shell manquant (optionnel)"
fi

if [ -f "$SCRIPT_DIR/migrate_existing_user.sh" ]; then
    if [ -x "$SCRIPT_DIR/migrate_existing_user.sh" ]; then
        check_pass "Script migration utilisateur (exécutable)"
    else
        check_warn "Script migration utilisateur (non exécutable)"
    fi
else
    check_warn "Script migration utilisateur manquant (optionnel)"
fi

################################################################################
# VÉRIFICATIONS FONCTIONS ZSH - MANAGERS
################################################################################
log_section "Vérifications fonctions ZSH - Gestionnaires (*man.zsh)"

MANAGERS=(
    "$DOTFILES_DIR/zsh/functions/pathman.zsh:pathman.zsh"
    "$DOTFILES_DIR/zsh/functions/netman.zsh:netman.zsh"
    "$DOTFILES_DIR/zsh/functions/aliaman.zsh:aliaman.zsh"
    "$DOTFILES_DIR/zsh/functions/miscman.zsh:miscman.zsh"
    "$DOTFILES_DIR/zsh/functions/searchman.zsh:searchman.zsh"
    "$DOTFILES_DIR/zsh/functions/cyberman.zsh:cyberman.zsh"
)

for manager_entry in "${MANAGERS[@]}"; do
    IFS=':' read -r manager name <<< "$manager_entry"
    if [ -f "$manager" ]; then
        check_pass "Gestionnaire: $name"
    else
        check_fail "Gestionnaire manquant: $name"
    fi
done

################################################################################
# VÉRIFICATIONS FONCTIONS ZSH - DEV
################################################################################
log_section "Vérifications fonctions ZSH - Dev"

DEV_FUNCTIONS=(
    "$DOTFILES_DIR/zsh/functions/dev/go.sh:go.sh"
    "$DOTFILES_DIR/zsh/functions/dev/c.sh:c.sh"
    "$DOTFILES_DIR/zsh/functions/dev/docker.sh:docker.sh"
    "$DOTFILES_DIR/zsh/functions/dev/make.sh:make.sh"
    "$DOTFILES_DIR/zsh/functions/dev/projects/cyna.sh:cyna.sh"
    "$DOTFILES_DIR/zsh/functions/dev/projects/weedlyweb.sh:weedlyweb.sh"
)

for func_entry in "${DEV_FUNCTIONS[@]}"; do
    IFS=':' read -r func name <<< "$func_entry"
    if [ -f "$func" ]; then
        check_pass "Fonction dev: $name"
    else
        check_warn "Fonction dev manquante (optionnel): $name"
    fi
done

################################################################################
# VÉRIFICATIONS FONCTIONS ZSH - MISC
################################################################################
log_section "Vérifications fonctions ZSH - Misc"

MISC_FUNCTIONS=(
    "$DOTFILES_DIR/zsh/functions/misc/clipboard/file.sh:clipboard/file.sh"
    "$DOTFILES_DIR/zsh/functions/misc/clipboard/path.sh:clipboard/path.sh"
    "$DOTFILES_DIR/zsh/functions/misc/clipboard/text.sh:clipboard/text.sh"
    "$DOTFILES_DIR/zsh/functions/misc/security/encrypt_file.sh:security/encrypt_file.sh"
    "$DOTFILES_DIR/zsh/functions/misc/security/password.sh:security/password.sh"
    "$DOTFILES_DIR/zsh/functions/misc/files/archive.sh:files/archive.sh"
    "$DOTFILES_DIR/zsh/functions/misc/system/disk.sh:system/disk.sh"
    "$DOTFILES_DIR/zsh/functions/misc/system/process.sh:system/process.sh"
    "$DOTFILES_DIR/zsh/functions/misc/backup/create_backup.sh:backup/create_backup.sh"
)

for func_entry in "${MISC_FUNCTIONS[@]}"; do
    IFS=':' read -r func name <<< "$func_entry"
    if [ -f "$func" ]; then
        check_pass "Fonction misc: $name"
    else
        check_warn "Fonction misc manquante (optionnel): $name"
    fi
done

################################################################################
# VÉRIFICATIONS FONCTIONS ZSH - CYBER
################################################################################
log_section "Vérifications fonctions ZSH - Cyber"

# Vérifier structure cyber/
CYBER_DIRS=(
    "$DOTFILES_DIR/zsh/functions/cyber/reconnaissance:reconnaissance"
    "$DOTFILES_DIR/zsh/functions/cyber/scanning:scanning"
    "$DOTFILES_DIR/zsh/functions/cyber/vulnerability:vulnerability"
    "$DOTFILES_DIR/zsh/functions/cyber/attacks:attacks"
    "$DOTFILES_DIR/zsh/functions/cyber/analysis:analysis"
    "$DOTFILES_DIR/zsh/functions/cyber/privacy:privacy"
)

for dir_entry in "${CYBER_DIRS[@]}"; do
    IFS=':' read -r dir name <<< "$dir_entry"
    if [ -d "$dir" ]; then
        COUNT=$(find "$dir" -maxdepth 1 -name "*.sh" 2>/dev/null | wc -l)
        check_pass "Dossier cyber/$name ($COUNT fichiers)"
    else
        check_warn "Dossier cyber/$name manquant (optionnel)"
    fi
done

# Vérifier quelques fonctions cyber essentielles
CYBER_KEY_FUNCTIONS=(
    "$DOTFILES_DIR/zsh/functions/cyber/reconnaissance/domain_whois.sh:domain_whois.sh"
    "$DOTFILES_DIR/zsh/functions/cyber/scanning/port_scan.sh:port_scan.sh"
    "$DOTFILES_DIR/zsh/functions/cyber/vulnerability/nmap_vuln_scan.sh:nmap_vuln_scan.sh"
    "$DOTFILES_DIR/zsh/functions/cyber/attacks/arp_spoof.sh:arp_spoof.sh"
)

for func_entry in "${CYBER_KEY_FUNCTIONS[@]}"; do
    IFS=':' read -r func name <<< "$func_entry"
    if [ -f "$func" ]; then
        check_pass "Fonction cyber clé: $name"
    else
        check_warn "Fonction cyber clé manquante (optionnel): $name"
    fi
done

################################################################################
# VÉRIFICATIONS FONCTIONS ZSH - AUTRES
################################################################################
log_section "Vérifications fonctions ZSH - Autres"

if [ -f "$DOTFILES_DIR/zsh/functions/git/git_functions.sh" ]; then
    check_pass "Fonction git: git_functions.sh"
else
    check_warn "Fonction git manquante (optionnel): git_functions.sh"
fi

if [ -f "$DOTFILES_DIR/zsh/functions/utils/ensure_tool.sh" ]; then
    check_pass "Fonction utils: ensure_tool.sh"
else
    check_warn "Fonction utils manquante (optionnel): ensure_tool.sh"
fi

################################################################################
# VÉRIFICATIONS RÉPERTOIRES
################################################################################
log_section "Vérifications répertoires"

REQUIRED_DIRS=(
    "$DOTFILES_DIR/zsh/functions:zsh/functions"
    "$DOTFILES_DIR/zsh/functions/dev:zsh/functions/dev"
    "$DOTFILES_DIR/zsh/functions/misc:zsh/functions/misc"
    "$DOTFILES_DIR/zsh/functions/cyber:zsh/functions/cyber"
    "$SCRIPT_DIR/install:scripts/install"
    "$SCRIPT_DIR/config:scripts/config"
    "$SCRIPT_DIR/sync:scripts/sync"
    "$SCRIPT_DIR/test:scripts/test"
    "$SCRIPT_DIR/lib:scripts/lib"
)

for dir_entry in "${REQUIRED_DIRS[@]}"; do
    IFS=':' read -r dir name <<< "$dir_entry"
    if [ -d "$dir" ]; then
        check_pass "Répertoire: $name"
    else
        check_fail "Répertoire manquant: $name"
    fi
done

################################################################################
# VÉRIFICATIONS VARIABLES D'ENVIRONNEMENT
################################################################################
log_section "Vérifications variables d'environnement"

if [ -f "$DOTFILES_DIR/zsh/env.sh" ]; then
    if grep -q "export PATH" "$DOTFILES_DIR/zsh/env.sh" 2>/dev/null || \
       grep -q "export JAVA_HOME\|export ANDROID_SDK_ROOT\|export GOPATH\|export FLUTTER" "$DOTFILES_DIR/zsh/env.sh" 2>/dev/null; then
        check_pass "Variables d'environnement définies dans env.sh"
    else
        check_warn "env.sh présent mais peu de variables définies"
    fi
else
    check_warn "env.sh manquant (optionnel)"
fi

################################################################################
# VÉRIFICATIONS SYMLINKS
################################################################################
log_section "Vérifications symlinks"

if [ -L "$HOME/.zshrc" ]; then
    LINK_TARGET=$(readlink "$HOME/.zshrc")
    if [[ "$LINK_TARGET" == *"dotfiles"* ]] || [[ "$LINK_TARGET" == *"zshrc"* ]]; then
        check_pass "Symlink .zshrc: $LINK_TARGET"
    else
        check_warn "Symlink .zshrc pointe vers: $LINK_TARGET"
    fi
elif grep -q "dotfiles\|zshrc_custom" "$HOME/.zshrc" 2>/dev/null; then
    check_pass ".zshrc source dotfiles (pas symlink, OK)"
else
    check_warn ".zshrc ne référence pas dotfiles (relancez setup.sh option 23)"
fi

if [ -L "$HOME/.gitconfig" ]; then
    LINK_TARGET=$(readlink "$HOME/.gitconfig")
    if [[ "$LINK_TARGET" == *"dotfiles"* ]]; then
        check_pass "Symlink .gitconfig: $LINK_TARGET"
    else
        check_warn "Symlink .gitconfig pointe vers: $LINK_TARGET"
    fi
else
    check_warn ".gitconfig n'est pas un symlink (optionnel)"
fi

################################################################################
# RAPPORT FINAL
################################################################################
log_section "Rapport final"

TOTAL=$((PASSED + FAILED + WARNINGS))
echo ""
echo "Résultats:"
echo -e "  ${GREEN}✅ Réussis: $PASSED${NC}"
echo -e "  ${RED}❌ Échecs: $FAILED${NC}"
echo -e "  ${YELLOW}⚠️ Avertissements: $WARNINGS${NC}"
echo "  Total: $TOTAL vérifications"
echo ""

# Afficher les détails des échecs si présents
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
    echo -e "${RED}❌ ÉCHECS DÉTECTÉS ($FAILED):${NC}"
    echo -e "${RED}════════════════════════════════════════════════════════════${NC}"
    for item in "${FAILED_ITEMS[@]}"; do
        echo -e "  ${RED}❌${NC} $item"
    done
    echo ""
fi

# Afficher les détails des avertissements si présents
if [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}⚠️ AVERTISSEMENTS DÉTECTÉS ($WARNINGS):${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
    for item in "${WARNED_ITEMS[@]}"; do
        echo -e "  ${YELLOW}⚠️${NC} $item"
    done
    echo ""
fi

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Setup validé avec succès!${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠️ $WARNINGS avertissement(s) (non critiques)${NC}"
        echo ""
        echo "Pour corriger les avertissements:"
        echo "  - Utilisez setup.sh option 50 (Installer tout ce qui manque)"
        echo "  - Ou installez manuellement les composants manquants"
    fi
    exit 0
else
    echo -e "${RED}❌ $FAILED problème(s) critique(s) détecté(s)${NC}"
    echo ""
    echo "Solutions suggérées:"
    echo "  1. Utilisez setup.sh option 50 (Installer tout ce qui manque)"
    echo "  2. Ou installez manuellement les composants manquants via le menu"
    echo "  3. Rechargez votre shell: exec zsh"
    echo "  4. Relancez la validation: setup.sh option 23"
    echo "  5. Restaurez depuis Git: setup.sh option 28"
    echo ""
    # Ne pas faire échouer le script, juste afficher les problèmes
    exit 0
fi
