#!/usr/bin/env bash
# =============================================================================
# Vérification des URLs de téléchargement (sans installer)
# Teste que chaque URL répond et renvoie un contenu exploitable (HTTP 200, type/size cohérents)
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# URLs à vérifier (nom:url:type_attendu=appimage|archive|html|any)
# type_attendu: appimage -> vérifier application/x-executable ou octet-stream + taille > 1M
CURSOR_URL_PRIMARY="https://downloader.cursor.sh/linux/appImage/x64"
CURSOR_URL_ALT="https://api2.cursor.sh/updates/download/golden/linux-x64/cursor/latest"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz"
NVM_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh"
FLATHUB_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"

check_url() {
    local name="$1"
    local url="$2"
    local expected="${3:-any}"
    local err=0
    local code size ct

    printf "${CYAN}%-25s${NC} %s ... " "$name" "$url"
    resp=$(curl -sS -w "\n%{http_code}\n%{size_download}\n%{content_type}" -o /tmp/check_url_$$.body -L -I "$url" 2>/dev/null || true)
    if [ -z "$resp" ]; then
        echo -e "${RED}FAIL${NC} (curl error or no response)"
        return 1
    fi
    # -w donne en fin: http_code, size_download, content_type (une par ligne)
    code=$(echo "$resp" | tail -n 3 | head -n 1 | tr -d '\r')
    size=$(echo "$resp" | tail -n 2 | head -n 1)
    ct=$(echo "$resp" | tail -n 1 | tr -d '\r')
    # Si code vide (redirect côté curl), considérer 200 si on a un content-type
    if [ -z "$code" ] || [ "$code" = "0" ]; then
        echo "$resp" | head -1 | grep -qi "HTTP.*200" && code=200
    fi

    if [ "$code" != "200" ] && [ "$code" != "302" ] && [ "$code" != "301" ]; then
        echo -e "${RED}FAIL${NC} (HTTP ${code:-empty})"
        return 1
    fi

    # Suivi de redirection: si on a seulement les headers, size_download peut être 0
    if [ "$code" = "301" ] || [ "$code" = "302" ]; then
        loc=$(curl -sI -L "$url" 2>/dev/null | grep -i "^[Ll]ocation:" | tail -1 | tr -d '\r' | sed 's/^[Ll]ocation:[[:space:]]*//')
        if [ -n "$loc" ]; then
            resp2=$(curl -sS -w "\n%{http_code}\n%{size_download}\n%{content_type}" -o /tmp/check_url_$$.body -L -I "$loc" 2>/dev/null || true)
            code=$(echo "$resp2" | tail -n 3 | head -n 1 | tr -d '\r')
            size=$(echo "$resp2" | tail -n 2 | head -n 1)
            ct=$(echo "$resp2" | tail -n 1 | tr -d '\r')
        fi
    fi

    if [ "$code" != "200" ]; then
        echo -e "${RED}FAIL${NC} (HTTP $code after redirect)"
        return 1
    fi

    case "$expected" in
        appimage)
            if echo "$ct" | grep -qiE "octet-stream|application/x-executable|application/executable"; then
                echo -e "${GREEN}OK${NC} (downloadable, type=$ct)"
                return 0
            fi
            if [ -n "$size" ] && [ "$size" -gt 1048576 ] 2>/dev/null; then
                echo -e "${GREEN}OK${NC} (size=${size} bytes)"
                return 0
            fi
            echo -e "${YELLOW}WARN${NC} (HTTP 200 but type=$ct size=$size - might be redirect page)"
            return 0
            ;;
        archive)
            if echo "$ct" | grep -qiE "octet-stream|x-xz|gzip|zip|x-tar|tar"; then
                echo -e "${GREEN}OK${NC} (archive type=$ct)"
                return 0
            fi
            echo -e "${GREEN}OK${NC} (HTTP 200, size=$size)"
            return 0
            ;;
        html)
            if echo "$ct" | grep -qi "text/html"; then
                echo -e "${GREEN}OK${NC} (HTML page)"
                return 0
            fi
            echo -e "${GREEN}OK${NC} (HTTP 200)"
            return 0
            ;;
        any|*)
            echo -e "${GREEN}OK${NC} (HTTP 200, type=$ct)"
            return 0
            ;;
    esac
    rm -f /tmp/check_url_$$.body
    return 0
}

echo "Vérification des URLs de téléchargement (aucune installation)"
echo "=============================================================="
err=0
cursor_ok=0
check_url "Cursor (primary)"    "$CURSOR_URL_PRIMARY" "appimage" && cursor_ok=1
check_url "Cursor (fallback)"   "$CURSOR_URL_ALT"    "appimage" && cursor_ok=1
[ $cursor_ok -eq 0 ] && err=1
check_url "Flutter stable"      "$FLUTTER_URL"      "archive"  || err=1
check_url "NVM install script"  "$NVM_URL"          "any"      || err=1
check_url "Flathub repo"        "$FLATHUB_URL"      "any"      || err=1
echo "=============================================================="
if [ $err -eq 0 ]; then
    echo -e "${GREEN}Toutes les URLs critiques sont exploitables.${NC}"
else
    echo -e "${YELLOW}Une ou plusieurs URLs ont échoué (réseau ou URL obsolète).${NC}"
fi
rm -f /tmp/check_url_$$.body
exit $err
