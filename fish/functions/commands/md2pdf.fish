# =============================================================================
# MD2PDF - Conversion Markdown vers PDF avec style (Fish)
# =============================================================================
# Description: Convertit un fichier Markdown (.md) en PDF avec un style professionnel
# Author: Paul Delhomme
# Version: 1.0
# =============================================================================

function md2pdf --description "Convertit un fichier Markdown en PDF avec style"
    set -l RED '\033[0;31m'
    set -l GREEN '\033[0;32m'
    set -l YELLOW '\033[1;33m'
    set -l BLUE '\033[0;34m'
    set -l CYAN '\033[0;36m'
    set -l BOLD '\033[1m'
    set -l RESET '\033[0m'
    
    # Variables
    set -l input_file ""
    set -l output_file ""
    set -l style "default"
    set -l open_after false
    set -l show_help false
    
    # Parser les arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case -o --output
                set output_file $argv[(math $i + 1)]
                set i (math $i + 2)
            case -s --style
                set style $argv[(math $i + 1)]
                set i (math $i + 2)
            case --open
                set open_after true
                set i (math $i + 1)
            case -h --help
                set show_help true
                set i (math $i + 1)
            case '-*'
                echo -e "$RED✗ Option inconnue: $argv[$i]$RESET" >&2
                return 1
            case '*'
                if test -z "$input_file"
                    set input_file $argv[$i]
                else
                    echo -e "$RED✗ Trop d'arguments. Utilisez --help pour voir l'aide.$RESET" >&2
                    return 1
                end
                set i (math $i + 1)
        end
    end
    
    # Afficher l'aide
    if test "$show_help" = "true"; or test -z "$input_file"
        echo -e "$CYAN$BOLD╔════════════════════════════════════════════════════════════════╗$RESET"
        echo -e "$CYAN$BOLD║              MD2PDF - Conversion Markdown → PDF                ║$RESET"
        echo -e "$CYAN$BOLD╚════════════════════════════════════════════════════════════════╝$RESET\n"
        echo "Usage: md2pdf <fichier.md> [options]"
        echo "       convert <fichier.md> [options]"
        echo ""
        echo "Options:"
        echo "  -o, --output <fichier.pdf>  Spécifier le nom du fichier PDF de sortie"
        echo "  -s, --style <style>         Choisir le style (default, github, minimal, elegant)"
        echo "  --open                      Ouvrir le PDF après conversion"
        echo "  -h, --help                  Afficher cette aide"
        echo ""
        echo "Exemples:"
        echo "  md2pdf README.md"
        echo "  convert document.md --output mon_document.pdf"
        echo "  md2pdf README.md --style github --open"
        echo ""
        echo "Styles disponibles:"
        echo "  default  - Style par défaut avec mise en page professionnelle"
        echo "  github   - Style inspiré de GitHub"
        echo "  minimal  - Style minimaliste"
        echo "  elegant  - Style élégant avec typographie soignée"
        echo ""
        if test -z "$input_file"
            return 1
        end
        return 0
    end
    
    # Vérifier que le fichier d'entrée existe
    if not test -f "$input_file"
        echo -e "$RED✗ Fichier introuvable: $input_file$RESET" >&2
        return 1
    end
    
    # Vérifier l'extension .md
    if not echo "$input_file" | grep -qE '\.(md|markdown)$'
        echo -e "$YELLOW⚠️  Attention: Le fichier ne se termine pas par .md ou .markdown$RESET" >&2
        read -P "Continuer quand même? (y/N): " -l REPLY
        if not echo "$REPLY" | grep -qE '^[yY]'
            return 1
        end
    end
    
    # Déterminer le nom du fichier de sortie
    if test -z "$output_file"
        set output_file (string replace -r '\.(md|markdown)$' '.pdf' "$input_file")
    end
    
    # Vérifier que pandoc est installé
    if not command -v pandoc >/dev/null 2>&1
        echo -e "$RED✗ 'pandoc' n'est pas installé$RESET" >&2
        echo -e "$YELLOW💡 Installation:$RESET"
        echo ""
        
        # Détecter la distribution
        if command -v pacman >/dev/null 2>&1
            echo -e "  $CYANsudo pacman -S pandoc$RESET"
        else if command -v apt >/dev/null 2>&1
            echo -e "  $CYANsudo apt install pandoc$RESET"
        else if command -v dnf >/dev/null 2>&1
            echo -e "  $CYANsudo dnf install pandoc$RESET"
        else
            echo -e "  $CYANInstallez pandoc pour votre distribution$RESET"
        end
        return 1
    end
    
    # Vérifier que wkhtmltopdf est installé
    if not command -v wkhtmltopdf >/dev/null 2>&1
        echo -e "$RED✗ 'wkhtmltopdf' n'est pas installé$RESET" >&2
        echo -e "$YELLOW💡 Installation:$RESET"
        echo ""
        
        # Détecter la distribution
        if command -v pacman >/dev/null 2>&1
            echo -e "  $CYANsudo pacman -S wkhtmltopdf$RESET"
            if command -v yay >/dev/null 2>&1
                echo -e "  $CYANou: yay -S wkhtmltopdf-static$RESET"
            end
        else if command -v apt >/dev/null 2>&1
            echo -e "  $CYANsudo apt install wkhtmltopdf$RESET"
        else if command -v dnf >/dev/null 2>&1
            echo -e "  $CYANsudo dnf install wkhtmltopdf$RESET"
        else
            echo -e "  $CYANInstallez wkhtmltopdf pour votre distribution$RESET"
        end
        return 1
    end
    
    echo -e "$CYAN$BOLD╔════════════════════════════════════════════════════════════════╗$RESET"
    echo -e "$CYAN$BOLD║              CONVERSION MARKDOWN → PDF                        ║$RESET"
    echo -e "$CYAN$BOLD╚════════════════════════════════════════════════════════════════╝$RESET\n"
    echo -e "$BLUE📄 Fichier d'entrée:$RESET $input_file"
    echo -e "$BLUE📄 Fichier de sortie:$RESET $output_file"
    echo -e "$BLUE🎨 Style:$RESET $style"
    echo ""
    
    # Créer le répertoire de sortie si nécessaire
    set -l output_dir (dirname "$output_file")
    if test "$output_dir" != "."; and not test -d "$output_dir"
        mkdir -p "$output_dir"
        echo -e "$GREEN✓ Répertoire créé: $output_dir$RESET"
    end
    
    # Créer un fichier HTML temporaire
    set -l temp_html (mktemp --suffix=.html)
    
    # Étape 1: Conversion Markdown → HTML avec pandoc
    echo -e "$YELLOW🔄 Étape 1/2: Conversion Markdown → HTML...$RESET"
    if not pandoc "$input_file" -o "$temp_html" --from markdown-smart --standalone --toc --toc-depth=3 --number-sections 2>&1
        echo -e "$RED✗ Erreur lors de la conversion Markdown → HTML$RESET" >&2
        rm -f "$temp_html"
        return 1
    end
    
    # Étape 2: Conversion HTML → PDF avec wkhtmltopdf
    echo -e "$YELLOW🔄 Étape 2/2: Conversion HTML → PDF...$RESET"
    if not wkhtmltopdf --encoding UTF-8 --enable-local-file-access "$temp_html" "$output_file" 2>&1
        echo -e "$RED✗ Erreur lors de la conversion HTML → PDF$RESET" >&2
        rm -f "$temp_html"
        return 1
    end
    
    # Nettoyer le fichier HTML temporaire
    rm -f "$temp_html"
    
    echo ""
    echo -e "$GREEN✅ Conversion réussie!$RESET"
    echo -e "$GREEN📄 PDF créé: $output_file$RESET"
    
    # Afficher la taille du fichier
    if command -v du >/dev/null 2>&1
        set -l file_size (du -h "$output_file" | cut -f1)
        echo -e "$CYAN📊 Taille: $file_size$RESET"
    end
    
    # Ouvrir le PDF si demandé
    if test "$open_after" = "true"
        echo ""
        echo -e "$CYAN🔓 Ouverture du PDF...$RESET"
        if command -v xdg-open >/dev/null 2>&1
            xdg-open "$output_file" 2>/dev/null &
        else if command -v open >/dev/null 2>&1
            open "$output_file" 2>/dev/null &
        else if command -v evince >/dev/null 2>&1
            evince "$output_file" 2>/dev/null &
        else
            echo -e "$YELLOW⚠️  Aucun visualiseur PDF trouvé$RESET"
        end
    end
    
    return 0
end

# Alias (seulement si convert n'est pas déjà défini)
if not functions -q convert
    function convert; md2pdf $argv; end
end

