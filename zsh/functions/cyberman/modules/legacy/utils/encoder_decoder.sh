#!/bin/zsh
# =============================================================================
# ENCODER/DECODER - Encodeur/Décodeur pour cyberman
# =============================================================================
# DESC: Encode/décode Base64, URL, Hex
# USAGE: encode_decode <type> <action> <input>
# EXAMPLE: encode_decode base64 encode "hello"
# EXAMPLE: encode_decode url decode "hello%20world"
# =============================================================================

encode_decode() {
    local type="$1"
    local action="$2"
    local input="$3"
    
    if [ -z "$type" ] || [ -z "$action" ] || [ -z "$input" ]; then
        echo "❌ Usage: encode_decode <type> <action> <input>"
        echo "Types: base64, url, hex"
        echo "Actions: encode, decode"
        return 1
    fi
    
    case "$type" in
        base64|b64)
            if [ "$action" = "encode" ]; then
                if command -v base64 >/dev/null 2>&1; then
                    echo "$input" | base64
                else
                    echo "❌ base64 non disponible"
                    return 1
                fi
            elif [ "$action" = "decode" ]; then
                if command -v base64 >/dev/null 2>&1; then
                    echo "$input" | base64 -d
                else
                    echo "❌ base64 non disponible"
                    return 1
                fi
            else
                echo "❌ Action invalide: $action (utilisez encode ou decode)"
                return 1
            fi
            ;;
        url)
            if [ "$action" = "encode" ]; then
                # URL encoding simple
                echo "$input" | sed 's/ /%20/g; s/!/%21/g; s/"/%22/g; s/#/%23/g; s/\$/%24/g; s/%/%25/g; s/&/%26/g; s/'\''/%27/g; s/(/%28/g; s/)/%29/g; s/*/%2A/g; s/+/%2B/g; s/,/%2C/g; s/-/%2D/g; s/\./%2E/g; s/\//%2F/g; s/:/%3A/g; s/;/%3B/g; s/</%3C/g; s/=/%3D/g; s/>/%3E/g; s/?/%3F/g; s/@/%40/g'
            elif [ "$action" = "decode" ]; then
                # URL decoding simple
                echo "$input" | sed 's/%20/ /g; s/%21/!/g; s/%22/"/g; s/%23/#/g; s/%24/\$/g; s/%25/%/g; s/%26/\&/g; s/%27/'\''/g; s/%28/(/g; s/%29/)/g; s/%2A/*/g; s/%2B/+/g; s/%2C/,/g; s/%2D/-/g; s/%2E/./g; s/%2F/\//g; s/%3A/:/g; s/%3B/;/g; s/%3C/</g; s/%3D/=/g; s/%3E/>/g; s/%3F/?/g; s/%40/@/g'
            else
                echo "❌ Action invalide: $action (utilisez encode ou decode)"
                return 1
            fi
            ;;
        hex)
            if [ "$action" = "encode" ]; then
                echo -n "$input" | xxd -p | tr -d '\n'
            elif [ "$action" = "decode" ]; then
                echo "$input" | xxd -r -p
            else
                echo "❌ Action invalide: $action (utilisez encode ou decode)"
                return 1
            fi
            ;;
        *)
            echo "❌ Type invalide: $type (utilisez base64, url, ou hex)"
            return 1
            ;;
    esac
    
    return 0
}

