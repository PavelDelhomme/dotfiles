#!/bin/sh
# Resolution des releases pour outils du registre updateman (URLs + versions).
# Usage : . core/lib/tool_release.sh && tool_release_cursor_fetch

tool_release_json_field() {
    _trf_key="$1"
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import sys,json; d=json.load(sys.stdin); v=d.get('$_trf_key',''); print(v if v is not None else '')" 2>/dev/null
        return 0
    fi
    if command -v jq >/dev/null 2>&1; then
        jq -r ".$_trf_key // empty" 2>/dev/null
        return 0
    fi
    sed -n "s/.*\"$_trf_key\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" | head -n 1
}

tool_release_cursor_platform() {
    case "$(uname -m 2>/dev/null)" in
        aarch64|arm64) printf '%s' linux-arm64 ;;
        x86_64|amd64)  printf '%s' linux-x64 ;;
        *)             printf '%s' linux-x64 ;;
    esac
}

tool_release_cursor_api_url() {
    _trc_track="${CURSOR_RELEASE_TRACK:-stable}"
    _trc_platform="$(tool_release_cursor_platform)"
    printf 'https://api2.cursor.sh/updates/api/download/%s/%s/cursor' \
        "$_trc_track" "$_trc_platform"
}

# Remplit TOOL_RELEASE_VERSION, TOOL_RELEASE_URL, TOOL_RELEASE_DEB_URL, TOOL_RELEASE_RPM_URL
tool_release_cursor_fetch() {
    _trc_api="${1:-$(tool_release_cursor_api_url)}"
    _trc_json=""
    if ! _trc_json="$(curl -fsSL --retry 3 --retry-delay 2 "$_trc_api" 2>/dev/null)"; then
        _trc_api="https://www.cursor.com/api/download?platform=$(tool_release_cursor_platform)&releaseTrack=${CURSOR_RELEASE_TRACK:-stable}"
        _trc_json="$(curl -fsSL --retry 3 --retry-delay 2 "$_trc_api" 2>/dev/null)" || return 1
    fi
    TOOL_RELEASE_VERSION="$(printf '%s' "$_trc_json" | tool_release_json_field version)"
    TOOL_RELEASE_URL="$(printf '%s' "$_trc_json" | tool_release_json_field downloadUrl)"
    TOOL_RELEASE_DEB_URL="$(printf '%s' "$_trc_json" | tool_release_json_field debUrl)"
    TOOL_RELEASE_RPM_URL="$(printf '%s' "$_trc_json" | tool_release_json_field rpmUrl)"
    TOOL_RELEASE_API_URL="$_trc_api"
    [ -n "$TOOL_RELEASE_URL" ] || return 1
    return 0
}

tool_release_latest() {
    case "$1" in
        cursor)
            tool_release_cursor_fetch || return 1
            printf '%s' "$TOOL_RELEASE_VERSION"
            ;;
        *)
            return 1
            ;;
    esac
}

tool_release_download_url() {
    case "$1" in
        cursor)
            case "${2:-appimage}" in
                deb) tool_release_cursor_fetch || return 1; printf '%s' "$TOOL_RELEASE_DEB_URL" ;;
                rpm) tool_release_cursor_fetch || return 1; printf '%s' "$TOOL_RELEASE_RPM_URL" ;;
                *)   tool_release_cursor_fetch || return 1; printf '%s' "$TOOL_RELEASE_URL" ;;
            esac
            ;;
        *)
            return 1
            ;;
    esac
}
