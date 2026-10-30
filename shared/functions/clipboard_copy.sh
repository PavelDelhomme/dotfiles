#!/bin/sh
# Copie du texte vers le presse-papiers (X11, Wayland, macOS, WSL).
# Usage : dotfiles_clipboard_copy "texte"
# Retour : 0 si copié, 1 sinon.

dotfiles_clipboard_copy() {
    _clip_text="${1-}"
    if [ -z "$_clip_text" ]; then
        return 1
    fi
    if command -v wl-copy >/dev/null 2>&1; then
        printf '%s' "$_clip_text" | wl-copy
        return $?
    fi
    if command -v xclip >/dev/null 2>&1; then
        printf '%s' "$_clip_text" | xclip -selection clipboard
        return $?
    fi
    if command -v xsel >/dev/null 2>&1; then
        printf '%s' "$_clip_text" | xsel --clipboard --input
        return $?
    fi
    if command -v pbcopy >/dev/null 2>&1; then
        printf '%s' "$_clip_text" | pbcopy
        return $?
    fi
    if command -v clip.exe >/dev/null 2>&1; then
        printf '%s' "$_clip_text" | clip.exe
        return $?
    fi
    return 1
}
