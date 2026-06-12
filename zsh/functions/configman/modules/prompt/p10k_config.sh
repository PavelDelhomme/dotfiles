#!/bin/bash

################################################################################
# Configuration Powerlevel10k - Gestion du prompt avec support Git
# Configure et installe la configuration Powerlevel10k depuis dotfiles
################################################################################

# ⚠️ IMPORTANT: Ce script ne doit être exécuté QUE via 'configman p10k'
# Vérifier si le script est sourcé (pas exécuté)
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return 0 2>/dev/null || exit 0
fi

set +e  # Désactivé pour éviter fermeture terminal si sourcé

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
P10K_DOTFILES="$DOTFILES_DIR/.p10k.zsh"
P10K_HOME="$HOME/.p10k.zsh"

log_info() { echo -e "\033[0;32m[✓]\033[0m $1"; }
log_warn() { echo -e "\033[1;33m[⚠]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[✗]\033[0m $1"; }
log_section() { echo -e "\n\033[0;36m═══════════════════════════════════\033[0m\n\033[0;36m$1\033[0m\n\033[0;36m═══════════════════════════════════\033[0m"; }

detect_prompt_engine() {
    if [[ -f /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme ]]; then
        echo "powerlevel10k-system"
    elif [[ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
        echo "powerlevel10k-oh-my-zsh"
    elif [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
        echo "manjaro-zsh-prompt"
    else
        echo "missing"
    fi
}

font_status() {
    if ! command -v fc-match >/dev/null 2>&1; then
        echo "unknown"
        return
    fi
    if fc-match 'MesloLGS NF' 2>/dev/null | grep -qi 'Meslo'; then
        echo "ok"
    else
        echo "missing"
    fi
}

ensure_prompt_prerequisites() {
    local engine
    engine="$(detect_prompt_engine)"
    log_info "Moteur prompt détecté: $engine"
    log_info "Police MesloLGS NF: $(font_status)"

    if [[ "$engine" == "missing" ]]; then
        log_warn "Powerlevel10k n'est pas installé sur ce système."
        if [[ -f "$DOTFILES_DIR/scripts/config/setup_p10k.sh" ]]; then
            printf "Installer Powerlevel10k maintenant ? [y/N] "
            read -r install_choice
            case "$install_choice" in
                y|Y|yes|YES|o|O|oui|OUI)
                    bash "$DOTFILES_DIR/scripts/config/setup_p10k.sh" || return 1
                    ;;
                *)
                    log_error "Installation annulée. Le prompt dotfiles ne pourra pas être appliqué."
                    return 1
                    ;;
            esac
        else
            log_error "Script setup_p10k.sh introuvable"
            return 1
        fi
    fi

    if [[ "$(font_status)" == "missing" ]] && [[ -f "$DOTFILES_DIR/scripts/config/install_nerd_fonts.sh" ]]; then
        log_warn "Police Nerd Font non détectée. Les icônes peuvent s'afficher mal."
        printf "Installer les Nerd Fonts maintenant ? [y/N] "
        read -r font_choice
        case "$font_choice" in
            y|Y|yes|YES|o|O|oui|OUI)
                bash "$DOTFILES_DIR/scripts/config/install_nerd_fonts.sh" || true
                ;;
        esac
    fi
    return 0
}

if [[ "${1:-}" == "root" ]]; then
    shift
    if [[ -f "$DOTFILES_DIR/scripts/config/setup_root_prompt.sh" ]]; then
        bash "$DOTFILES_DIR/scripts/config/setup_root_prompt.sh" "$@"
        exit $?
    fi
    log_error "Script root prompt introuvable: $DOTFILES_DIR/scripts/config/setup_root_prompt.sh"
    exit 1
fi

if [[ "${1:-}" == "apply" || "${1:-}" == "--apply" || "${1:-}" == "--dry-run" || "${1:-}" == "--install-missing" ]]; then
    if [[ -f "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" ]]; then
        bash "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" shell "$@"
        exit $?
    fi
    log_error "Script apply dotfiles introuvable"
    exit 1
fi

log_section "Configuration Powerlevel10k"

ensure_prompt_prerequisites || exit 1

echo ""
echo "Options disponibles:"
      echo "1. Configurer Powerlevel10k (p10k configure)"
      echo "2. Copier la configuration depuis dotfiles vers ~/.p10k.zsh"
      echo "3. Créer un symlink de ~/.p10k.zsh vers dotfiles (RECOMMANDÉ)"
      echo "4. Sauvegarder la configuration actuelle dans dotfiles"
      echo "5. Vérifier la configuration Powerlevel10k"
      echo "6. Réappliquer le prompt dotfiles actuel (shell + .p10k.zsh)"
      echo "0. Retour"
      echo ""
      printf "Choix [0-6]: "
read -r choice

case "$choice" in
    1)
        log_info "Lancement de la configuration Powerlevel10k..."
        if command -v p10k >/dev/null 2>&1; then
            p10k configure
        else
            # Si p10k n'est pas disponible, utiliser la méthode manuelle
            log_warn "Commande 'p10k' non disponible, utilisation de la méthode manuelle"
            if [[ -f /usr/share/zsh/p10k.zsh ]]; then
                log_info "Copie de la configuration système..."
                cp /usr/share/zsh/p10k.zsh "$P10K_HOME"
                log_info "✓ Configuration copiée vers $P10K_HOME"
                log_info "Vous pouvez maintenant la personnaliser avec: p10k configure"
            else
                log_error "Aucune configuration Powerlevel10k trouvée"
                return 1 2>/dev/null || exit 1
            fi
        fi
        
        # Après configuration, proposer de copier vers dotfiles
        if [[ -f "$P10K_HOME" ]]; then
            echo ""
            printf "Copier la configuration vers dotfiles? (o/n) [o]: "
            read -r copy_to_dotfiles
            if [[ "$copy_to_dotfiles" =~ ^[oO]$ ]] || [[ -z "$copy_to_dotfiles" ]]; then
                cp "$P10K_HOME" "$P10K_DOTFILES"
                log_info "✓ Configuration copiée vers $P10K_DOTFILES"
                log_info "La configuration sera automatiquement chargée au prochain démarrage"
            fi
        fi
        ;;
    2)
        if [[ -f "$P10K_DOTFILES" ]]; then
            log_info "Copie de la configuration depuis dotfiles..."
            cp "$P10K_DOTFILES" "$P10K_HOME"
            log_info "✓ Configuration copiée vers $P10K_HOME"
            log_info "Rechargez votre shell pour appliquer les changements: exec zsh"
        else
            log_error "Configuration introuvable dans dotfiles: $P10K_DOTFILES"
            log_warn "Utilisez l'option 1 pour créer une configuration"
        fi
        ;;
    3)
        if [[ -f "$P10K_HOME" ]] && [[ ! -L "$P10K_HOME" ]]; then
            # Si le fichier existe et n'est pas un symlink, le copier vers dotfiles d'abord
            log_info "Copie de la configuration actuelle vers dotfiles..."
            cp "$P10K_HOME" "$P10K_DOTFILES"
            log_info "✓ Configuration sauvegardée dans dotfiles"
        fi
        
        if [[ -f "$P10K_DOTFILES" ]]; then
            log_info "Création du symlink..."
            # Créer un backup si nécessaire
            if [[ -f "$P10K_HOME" ]] && [[ ! -L "$P10K_HOME" ]]; then
                mv "$P10K_HOME" "$P10K_HOME.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            ln -sf "$P10K_DOTFILES" "$P10K_HOME"
            log_info "✓ Symlink créé: $P10K_HOME -> $P10K_DOTFILES"
            log_info "La configuration sera automatiquement synchronisée"
        else
            log_error "Configuration introuvable dans dotfiles: $P10K_DOTFILES"
            log_warn "Utilisez l'option 1 pour créer une configuration"
        fi
        ;;
    4)
        # Sauvegarder la configuration actuelle dans dotfiles
        if [[ -f "$P10K_HOME" ]] && [[ ! -L "$P10K_HOME" ]]; then
            log_info "Sauvegarde de la configuration actuelle dans dotfiles..."
            cp "$P10K_HOME" "$P10K_DOTFILES"
            log_info "✓ Configuration sauvegardée dans dotfiles: $P10K_DOTFILES"
            log_info "💡 Utilisez l'option 3 pour créer un symlink et synchroniser automatiquement"
        elif [[ -L "$P10K_HOME" ]]; then
            log_info "La configuration est déjà un symlink vers: $(readlink "$P10K_HOME")"
            log_info "La configuration est déjà synchronisée avec dotfiles"
        else
            log_warn "Aucune configuration Powerlevel10k trouvée dans $P10K_HOME"
            log_info "Configurez d'abord Powerlevel10k avec l'option 1"
        fi
        ;;
    5)
        log_info "Vérification de la configuration Powerlevel10k..."
        echo ""
        log_info "Moteur prompt: $(detect_prompt_engine)"
        log_info "Police MesloLGS NF: $(font_status)"
        if [[ -f "$P10K_HOME" ]]; then
            if [[ -L "$P10K_HOME" ]]; then
                log_info "✓ Configuration trouvée (symlink): $P10K_HOME"
                log_info "  → Pointe vers: $(readlink "$P10K_HOME")"
            else
                log_info "✓ Configuration trouvée (fichier): $P10K_HOME"
            fi
        else
            log_warn "❌ Aucune configuration trouvée dans $P10K_HOME"
        fi
        
        if [[ -f "$P10K_DOTFILES" ]]; then
            log_info "✓ Configuration trouvée dans dotfiles: $P10K_DOTFILES"
        else
            log_warn "❌ Aucune configuration trouvée dans dotfiles"
        fi
        
        echo ""
        if command -v p10k >/dev/null 2>&1; then
            log_info "✓ Commande 'p10k' disponible"
        else
            log_warn "⚠ Commande 'p10k' non disponible"
        fi
        
        if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
            log_info "✓ Prompt Manjaro disponible"
        else
            log_warn "⚠ Prompt Manjaro non disponible"
        fi
        ;;
    6)
        if [[ -f "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" ]]; then
            bash "$DOTFILES_DIR/scripts/bootstrap/apply_dotfiles.sh" shell --apply
        else
            log_error "Script apply dotfiles introuvable"
            return 1 2>/dev/null || exit 1
        fi
        ;;
    0)
        return 0
        ;;
    *)
        log_error "Choix invalide"
        return 1 2>/dev/null || exit 1
        ;;
esac

log_section "Configuration terminée!"

