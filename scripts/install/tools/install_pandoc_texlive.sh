#!/bin/bash
# =============================================================================
# Installation de Pandoc et LaTeX pour la conversion Markdown → PDF
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh" || { echo "Erreur: Impossible de charger la bibliothèque commune"; exit 1; }

log_section "Installation Pandoc et LaTeX pour conversion MD → PDF"

# Détecter la distribution
if command -v pacman &>/dev/null; then
    DISTRO="arch"
elif command -v apt &>/dev/null; then
    DISTRO="debian"
elif command -v dnf &>/dev/null; then
    DISTRO="fedora"
else
    log_error "Distribution non supportée"
    exit 1
fi

echo ""
echo "📦 Installation des dépendances pour md2pdf..."
echo ""

# Vérifier si pandoc est déjà installé
if command -v pandoc &>/dev/null; then
    local pandoc_version=$(pandoc --version | head -1 | awk '{print $2}')
    log_success "Pandoc déjà installé (version $pandoc_version)"
else
    log_info "Installation de Pandoc..."
    case "$DISTRO" in
        arch)
            if command -v yay &>/dev/null; then
                yay -S --noconfirm pandoc || sudo pacman -S --noconfirm pandoc
            else
                sudo pacman -S --noconfirm pandoc
            fi
            ;;
        debian)
            sudo apt update
            sudo apt install -y pandoc
            ;;
        fedora)
            sudo dnf install -y pandoc
            ;;
    esac
    log_success "Pandoc installé"
fi

echo ""

# Vérifier si un moteur LaTeX est installé
if command -v pdflatex &>/dev/null || command -v xelatex &>/dev/null || command -v lualatex &>/dev/null; then
    log_success "Moteur LaTeX déjà installé"
    if command -v pdflatex &>/dev/null; then
        local latex_version=$(pdflatex --version | head -1)
        log_info "  → $latex_version"
    fi
else
    log_info "Installation d'un moteur LaTeX..."
    case "$DISTRO" in
        arch)
            if command -v yay &>/dev/null; then
                yay -S --noconfirm texlive-core texlive-bin texlive-latexextra || \
                sudo pacman -S --noconfirm texlive-core texlive-bin texlive-latexextra
            else
                sudo pacman -S --noconfirm texlive-core texlive-bin texlive-latexextra
            fi
            ;;
        debian)
            sudo apt install -y texlive-latex-base texlive-latex-extra texlive-latex-recommended
            ;;
        fedora)
            sudo dnf install -y texlive-scheme-basic texlive-collection-latexextra
            ;;
    esac
    log_success "Moteur LaTeX installé"
fi

echo ""
log_success "✅ Installation terminée!"
echo ""
echo "💡 Vous pouvez maintenant utiliser:"
echo "   md2pdf fichier.md"
echo "   convert fichier.md"
echo ""

