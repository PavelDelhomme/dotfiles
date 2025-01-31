clean_path() {
    local old_IFS="$IFS"
    IFS=':'
    local path_array=($PATH)
    IFS="$old_IFS"
    local new_path=""
    local dir

    # Liste des chemins à préserver
    local preserve_paths=(
        "/usr/lib/jvm/java-17-openjdk/bin"
        "$HOME/Android/Sdk/cmdline-tools/bin"
        "$HOME/Android/Sdk/platform-tools"
        "$HOME/Android/Sdk/tools"
        "$HOME/.pub-cache/bin"
        "/opt/flutter/bin"
        "$HOME/.emacs.d/bin"
        "/usr/share/dotnet"
        "$HOME/.dotnet/tools"
        "/bin" "/usr/bin" "/usr/local/bin" "/snap/bin" "$HOME/.local/bin"
        "/usr/local/sbin" "/usr/sbin" "/sbin" "/usr/local/games" "/usr/games"
    )

    for dir in "${path_array[@]}" "${preserve_paths[@]}"; do
        if [[ -d "$dir" && ":$new_path:" != *":$dir:"* ]]; then
            new_path="$new_path:$dir"
        fi
    done

    export PATH="${new_path#:}"
    add_logs "CLEAN" "PATH nettoyé des doublons et des répertoires inexistants"
    echo "PATH nettoyé : $PATH"
}


