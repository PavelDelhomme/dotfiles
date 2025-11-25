#!/bin/zsh
# =============================================================================
# HASH CALCULATOR - Calculateur de hash pour cyberman
# =============================================================================
# DESC: Calcule les hash MD5, SHA1, SHA256, SHA512 d'un fichier ou d'une chaîne
# USAGE: hash_calc <file_or_string> [algorithm]
# EXAMPLE: hash_calc file.txt
# EXAMPLE: hash_calc "hello world" sha256
# =============================================================================

hash_calc() {
    local input="$1"
    local algorithm="${2:-all}"
    
    if [ -z "$input" ]; then
        echo "❌ Usage: hash_calc <file_or_string> [algorithm]"
        echo "Algorithms: md5, sha1, sha256, sha512, all (default)"
        return 1
    fi
    
    # Vérifier si c'est un fichier
    if [ -f "$input" ]; then
        echo "📄 Calcul des hash pour le fichier: $input"
        echo ""
        
        case "$algorithm" in
            md5|MD5)
                if command -v md5sum >/dev/null 2>&1; then
                    echo "MD5:    $(md5sum "$input" | cut -d' ' -f1)"
                elif command -v md5 >/dev/null 2>&1; then
                    echo "MD5:    $(md5 -q "$input")"
                else
                    echo "❌ md5sum/md5 non disponible"
                fi
                ;;
            sha1|SHA1)
                if command -v sha1sum >/dev/null 2>&1; then
                    echo "SHA1:   $(sha1sum "$input" | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA1:   $(shasum -a 1 "$input" | cut -d' ' -f1)"
                else
                    echo "❌ sha1sum non disponible"
                fi
                ;;
            sha256|SHA256)
                if command -v sha256sum >/dev/null 2>&1; then
                    echo "SHA256: $(sha256sum "$input" | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA256: $(shasum -a 256 "$input" | cut -d' ' -f1)"
                else
                    echo "❌ sha256sum non disponible"
                fi
                ;;
            sha512|SHA512)
                if command -v sha512sum >/dev/null 2>&1; then
                    echo "SHA512: $(sha512sum "$input" | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA512: $(shasum -a 512 "$input" | cut -d' ' -f1)"
                else
                    echo "❌ sha512sum non disponible"
                fi
                ;;
            all|*)
                if command -v md5sum >/dev/null 2>&1; then
                    echo "MD5:    $(md5sum "$input" | cut -d' ' -f1)"
                elif command -v md5 >/dev/null 2>&1; then
                    echo "MD5:    $(md5 -q "$input")"
                fi
                if command -v sha1sum >/dev/null 2>&1; then
                    echo "SHA1:   $(sha1sum "$input" | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA1:   $(shasum -a 1 "$input" | cut -d' ' -f1)"
                fi
                if command -v sha256sum >/dev/null 2>&1; then
                    echo "SHA256: $(sha256sum "$input" | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA256: $(shasum -a 256 "$input" | cut -d' ' -f1)"
                fi
                if command -v sha512sum >/dev/null 2>&1; then
                    echo "SHA512: $(sha512sum "$input" | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA512: $(shasum -a 512 "$input" | cut -d' ' -f1)"
                fi
                ;;
        esac
    else
        # C'est une chaîne
        echo "📝 Calcul des hash pour la chaîne: $input"
        echo ""
        
        case "$algorithm" in
            md5|MD5)
                if command -v md5sum >/dev/null 2>&1; then
                    echo "MD5:    $(echo -n "$input" | md5sum | cut -d' ' -f1)"
                elif command -v md5 >/dev/null 2>&1; then
                    echo "MD5:    $(echo -n "$input" | md5 | cut -d' ' -f1)"
                else
                    echo "❌ md5sum/md5 non disponible"
                fi
                ;;
            sha1|SHA1)
                if command -v sha1sum >/dev/null 2>&1; then
                    echo "SHA1:   $(echo -n "$input" | sha1sum | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA1:   $(echo -n "$input" | shasum -a 1 | cut -d' ' -f1)"
                else
                    echo "❌ sha1sum non disponible"
                fi
                ;;
            sha256|SHA256)
                if command -v sha256sum >/dev/null 2>&1; then
                    echo "SHA256: $(echo -n "$input" | sha256sum | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA256: $(echo -n "$input" | shasum -a 256 | cut -d' ' -f1)"
                else
                    echo "❌ sha256sum non disponible"
                fi
                ;;
            sha512|SHA512)
                if command -v sha512sum >/dev/null 2>&1; then
                    echo "SHA512: $(echo -n "$input" | sha512sum | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA512: $(echo -n "$input" | shasum -a 512 | cut -d' ' -f1)"
                else
                    echo "❌ sha512sum non disponible"
                fi
                ;;
            all|*)
                if command -v md5sum >/dev/null 2>&1; then
                    echo "MD5:    $(echo -n "$input" | md5sum | cut -d' ' -f1)"
                elif command -v md5 >/dev/null 2>&1; then
                    echo "MD5:    $(echo -n "$input" | md5 | cut -d' ' -f1)"
                fi
                if command -v sha1sum >/dev/null 2>&1; then
                    echo "SHA1:   $(echo -n "$input" | sha1sum | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA1:   $(echo -n "$input" | shasum -a 1 | cut -d' ' -f1)"
                fi
                if command -v sha256sum >/dev/null 2>&1; then
                    echo "SHA256: $(echo -n "$input" | sha256sum | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA256: $(echo -n "$input" | shasum -a 256 | cut -d' ' -f1)"
                fi
                if command -v sha512sum >/dev/null 2>&1; then
                    echo "SHA512: $(echo -n "$input" | sha512sum | cut -d' ' -f1)"
                elif command -v shasum >/dev/null 2>&1; then
                    echo "SHA512: $(echo -n "$input" | shasum -a 512 | cut -d' ' -f1)"
                fi
                ;;
        esac
    fi
    
    return 0
}

