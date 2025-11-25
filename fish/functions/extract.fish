# =============================================================================
# EXTRACT - Extraction automatique d'archives pour Fish
# =============================================================================
# DESC: Extrait automatiquement des fichiers d'archive dans le répertoire courant
#       Supporte: tar, tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2, xz, deb, rpm, etc.
# USAGE: extract [<file_path>] [--help|-h|help]
# EXAMPLE: extract archive.zip
# EXAMPLE: extract archive.tar.gz
# EXAMPLE: extract  # Affiche l'aide si aucun argument

function extract --description "Extrait automatiquement des archives"
    # Afficher l'aide si demandé ou si aucun argument
    if test (count $argv) -eq 0; or test "$argv[1]" = "--help"; or test "$argv[1]" = "-h"; or test "$argv[1]" = "help"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 EXTRACT - Extraction automatique d'archives"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📝 Description:"
        echo "   Extrait automatiquement n'importe quel type d'archive dans le répertoire"
        echo "   courant. La fonction détecte automatiquement le format et utilise l'outil"
        echo "   approprié pour l'extraction."
        echo ""
        echo "💻 Usage:"
        echo "   extract <fichier_archive>"
        echo "   extract                    # Affiche cette aide"
        echo "   extract --help              # Affiche cette aide"
        echo "   extract -h                 # Affiche cette aide"
        echo ""
        echo "📚 Formats supportés:"
        echo "   • .tar, .tar.gz, .tar.bz2, .tar.xz, .tgz, .tbz2"
        echo "   • .zip"
        echo "   • .rar"
        echo "   • .7z"
        echo "   • .gz, .bz2, .xz"
        echo "   • .deb (paquets Debian)"
        echo "   • .rpm (paquets Red Hat)"
        echo "   • .cpio"
        echo "   • .lzma"
        echo "   • .Z (compress Unix)"
        echo ""
        echo "📚 Exemples:"
        echo "   extract mon_archive.zip"
        echo "   extract backup.tar.gz"
        echo "   extract fichier.rar"
        echo "   extract package.deb"
        echo ""
        echo "💡 Astuces:"
        echo "   • L'extraction se fait dans le répertoire courant"
        echo "   • Les fichiers sont extraits avec leurs permissions d'origine"
        echo "   • Utilisez 'help extract' pour plus d'informations"
        echo "   • Utilisez 'man extract' pour la documentation complète"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        return 0
    end
    
    set file "$argv[1]"
    
    # Vérifier si le fichier existe
    if not test -f "$file"
        echo "❌ Erreur: Fichier '$file' introuvable."
        echo ""
        echo "💡 Utilisez 'extract' sans argument pour voir l'aide"
        echo "💡 Utilisez 'extract --help' pour plus d'informations"
        return 1
    end
    
    # Vérifier si c'est bien un fichier (pas un répertoire)
    if not test -r "$file"
        echo "❌ Erreur: Impossible de lire le fichier '$file'"
        return 1
    end
    
    set filename (basename "$file")
    set dirname (dirname "$file")
    
    # Se placer dans le répertoire du fichier si nécessaire
    if test "$dirname" != "."; and test "$dirname" != (pwd)
        cd "$dirname" 2>/dev/null; or begin
            echo "❌ Erreur: Impossible d'accéder au répertoire '$dirname'"
            return 1
        end
        set file (basename "$file")
    end
    
    echo "📦 Extraction de: $filename"
    echo ""
    
    # Détection et extraction selon l'extension
    switch "$file"
        case "*.tar.bz2" "*.tbz2"
            echo "🔧 Format détecté: tar.bz2"
            tar xvjf "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.tar.gz" "*.tgz"
            echo "🔧 Format détecté: tar.gz"
            tar xvzf "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.tar.xz" "*.txz"
            echo "🔧 Format détecté: tar.xz"
            tar xvJf "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.tar"
            echo "🔧 Format détecté: tar"
            tar xvf "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.zip"
            echo "🔧 Format détecté: zip"
            if command -v unzip >/dev/null 2>&1
                unzip "$file"; and echo "✅ Extraction terminée avec succès"
            else
                echo "❌ Erreur: 'unzip' n'est pas installé"
                echo "💡 Installez-le avec: sudo pacman -S unzip (Arch) ou sudo apt install unzip (Debian)"
                return 1
            end
        case "*.rar"
            echo "🔧 Format détecté: rar"
            if command -v unrar >/dev/null 2>&1
                unrar x "$file"; and echo "✅ Extraction terminée avec succès"
            else if command -v rar >/dev/null 2>&1
                rar x "$file"; and echo "✅ Extraction terminée avec succès"
            else
                echo "❌ Erreur: 'unrar' ou 'rar' n'est pas installé"
                echo "💡 Installez-le avec: sudo pacman -S unrar (Arch) ou sudo apt install unrar (Debian)"
                return 1
            end
        case "*.7z"
            echo "🔧 Format détecté: 7z"
            if command -v 7z >/dev/null 2>&1
                7z x "$file"; and echo "✅ Extraction terminée avec succès"
            else
                echo "❌ Erreur: '7z' n'est pas installé"
                echo "💡 Installez-le avec: sudo pacman -S p7zip (Arch) ou sudo apt install p7zip-full (Debian)"
                return 1
            end
        case "*.gz"
            echo "🔧 Format détecté: gzip"
            gunzip "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.bz2"
            echo "🔧 Format détecté: bzip2"
            bunzip2 "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.xz"
            echo "🔧 Format détecté: xz"
            unxz "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.lzma"
            echo "🔧 Format détecté: lzma"
            unlzma "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.Z"
            echo "🔧 Format détecté: compress"
            uncompress "$file"; and echo "✅ Extraction terminée avec succès"
        case "*.deb"
            echo "🔧 Format détecté: Debian package"
            if command -v ar >/dev/null 2>&1
                mkdir -p (string replace -r '\.deb$' '' "$file")
                cd (string replace -r '\.deb$' '' "$file") 2>/dev/null; or return 1
                ar x "../$file"; and echo "✅ Extraction terminée avec succès"
                cd .. 2>/dev/null
            else
                echo "❌ Erreur: 'ar' n'est pas installé"
                return 1
            end
        case "*.rpm"
            echo "🔧 Format détecté: RPM package"
            if command -v rpm2cpio >/dev/null 2>&1
                rpm2cpio "$file" | cpio -idmv; and echo "✅ Extraction terminée avec succès"
            else
                echo "❌ Erreur: 'rpm2cpio' n'est pas installé"
                return 1
            end
        case "*.cpio"
            echo "🔧 Format détecté: cpio"
            cpio -idmv < "$file"; and echo "✅ Extraction terminée avec succès"
        case '*'
            echo "❌ Format de fichier non pris en charge: '$file'"
            echo ""
            echo "📚 Formats supportés:"
            echo "   tar, tar.gz, tar.bz2, tar.xz, zip, rar, 7z, gz, bz2, xz, deb, rpm, cpio, lzma, Z"
            echo ""
            echo "💡 Utilisez 'extract --help' pour plus d'informations"
            return 1
    end
end

