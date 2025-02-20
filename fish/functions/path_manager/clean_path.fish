function clean_path
    set preserve_paths \
        "/usr/lib/jvm/java-17-openjdk/bin" \
        "$HOME/Android/Sdk/cmdline-tools/latest/bin" \
        "$HOME/Android/Sdk/platform-tools" \
        "$HOME/Android/Sdk/tools" \
        "$HOME/.pub-cache/bin" \
        "/opt/flutter/bin" \
        "$HOME/.emacs.d/bin" \
        "/usr/share/dotnet" \
        "$HOME/.dotnet/tools" \
        "/bin" "/usr/bin" "/usr/local/bin" "/snap/bin" "$HOME/.local/bin" \
        "/usr/local/sbin" "/usr/sbin" "/sbin" "/usr/local/games" "/usr/games"

    set new_path

    for dir in $PATH $preserve_paths
        if test -d "$dir"; and not contains $dir $new_path
            set -a new_path $dir
        end
    end

    set -gx PATH $new_path
    add_logs "CLEAN" "PATH nettoyé des doublons et des répertoires inexistants"
    echo "PATH nettoyé : $PATH"
end

