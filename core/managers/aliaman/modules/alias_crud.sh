#!/bin/sh
# CRUD / export / stats interactifs pour aliaman (charge dans le corps de aliaman()).

# DESC: Ajoute un nouvel alias de manière interactive
# USAGE: add_new_alias
add_new_alias() {
    show_header
    printf "${YELLOW}➕ Ajouter un nouvel alias${RESET}\n"
    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

    printf "Nom de l'alias: "
    read alias_name
    if [ -z "$alias_name" ]; then
        printf "${RED}❌ Nom d'alias requis${RESET}\n"
        sleep 2
        show_aliases_list
        return
    fi

    if grep -q "^alias $alias_name=" "$ALIASES_FILE" 2>/dev/null; then
        printf "${RED}❌ L'alias '$alias_name' existe déjà${RESET}\n"
        printf "Remplacer? [y/N]: "
        read overwrite
        case "$overwrite" in
            [yY])
                sed -i "/^alias $alias_name=/d" "$ALIASES_FILE" 2>/dev/null || \
                sed "/^alias $alias_name=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
                mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"
                ;;
            *)
                show_aliases_list
                return
                ;;
        esac
    fi

    printf "Commande de l'alias: "
    read alias_command
    if [ -z "$alias_command" ]; then
        printf "${RED}❌ Commande requise${RESET}\n"
        sleep 2
        show_aliases_list
        return
    fi

    printf "Description (optionnelle): "
    read description

    if [ -n "$description" ]; then
        echo "# DESC: $description" >> "$ALIASES_FILE"
    fi

    if [ "$SHELL_TYPE" = "fish" ]; then
        echo "alias $alias_name='$alias_command'" >> "$ALIASES_FILE"
    else
        echo "alias $alias_name=\"$alias_command\"" >> "$ALIASES_FILE"
    fi

    if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
        eval "alias $alias_name=\"$alias_command\"" 2>/dev/null || true
    fi

    printf "${GREEN}✅ Alias '$alias_name' ajouté avec succès${RESET}\n"
    sleep 2
    show_aliases_list
}

# DESC: Modifie un alias de manière interactive
# USAGE: edit_alias_interactive
edit_alias_interactive() {
    show_header
    printf "${YELLOW}✏️ Édition d'alias${RESET}\n"
    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

    printf "Nom de l'alias à éditer: "
    read alias_to_edit
    if [ -z "$alias_to_edit" ]; then
        printf "${RED}❌ Nom d'alias requis${RESET}\n"
        sleep 2
        show_aliases_list
        return
    fi

    current_line=$(grep "^alias $alias_to_edit=" "$ALIASES_FILE" 2>/dev/null)
    if [ -z "$current_line" ]; then
        printf "${RED}❌ Alias '$alias_to_edit' non trouvé${RESET}\n"
        sleep 2
        show_aliases_list
        return
    fi

    current_command=$(echo "$current_line" | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/')
    printf "Commande actuelle: $current_command\n"
    printf "Nouvelle commande: "
    read new_command

    if [ -n "$new_command" ]; then
        backup_aliases

        sed -i "/^alias $alias_to_edit=/d" "$ALIASES_FILE" 2>/dev/null || \
        sed "/^alias $alias_to_edit=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
        mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"

        if [ "$SHELL_TYPE" = "fish" ]; then
            echo "alias $alias_to_edit='$new_command'" >> "$ALIASES_FILE"
        else
            echo "alias $alias_to_edit=\"$new_command\"" >> "$ALIASES_FILE"
        fi

        if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
            eval "alias $alias_to_edit=\"$new_command\"" 2>/dev/null || true
        fi

        printf "${GREEN}✅ Alias '$alias_to_edit' modifié${RESET}\n"
    fi

    sleep 2
    show_aliases_list
}

# DESC: Supprime un alias avec confirmation
# USAGE: delete_alias_interactive
delete_alias_interactive() {
    show_header
    printf "${YELLOW}🗑️ Suppression d'alias${RESET}\n"
    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

    printf "Nom de l'alias à supprimer: "
    read alias_to_remove
    if [ -z "$alias_to_remove" ]; then
        printf "${RED}❌ Nom d'alias requis${RESET}\n"
        sleep 2
        show_aliases_list
        return
    fi

    if grep -q "^alias $alias_to_remove=" "$ALIASES_FILE" 2>/dev/null; then
        printf "Confirmer la suppression? [y/N]: "
        read confirm
        case "$confirm" in
            [yY])
                backup_aliases

                sed -i "/^alias $alias_to_remove=/d" "$ALIASES_FILE" 2>/dev/null || \
                sed "/^alias $alias_to_remove=/d" "$ALIASES_FILE" > "$ALIASES_FILE.tmp" && \
                mv "$ALIASES_FILE.tmp" "$ALIASES_FILE"

                if [ "$SHELL_TYPE" = "zsh" ] || [ "$SHELL_TYPE" = "bash" ]; then
                    unalias "$alias_to_remove" 2>/dev/null || true
                fi

                printf "${GREEN}✅ Alias '$alias_to_remove' supprimé${RESET}\n"
                ;;
            *)
                printf "${BLUE}ℹ️ Suppression annulée${RESET}\n"
                ;;
        esac
    else
        printf "${RED}❌ Alias '$alias_to_remove' non trouvé${RESET}\n"
    fi

    sleep 2
    show_aliases_list
}

# DESC: Exporte les alias dans un fichier
# USAGE: export_aliases
export_aliases() {
    show_header
    printf "${YELLOW}💾 Export des alias${RESET}\n"
    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

    timestamp=$(date +%Y%m%d_%H%M%S)
    export_file="$HOME/aliases_export_$timestamp.sh"

    {
        echo "#!/bin/sh"
        echo "# Export des alias - $(date)"
        echo "# Généré par ALIAMAN - Alias Manager"
        echo
        cat "$ALIASES_FILE"
    } > "$export_file"

    printf "${GREEN}✅ Alias exportés vers: $export_file${RESET}\n"
    echo
    echo "Pour importer ces alias sur un autre système:"
    echo "  source $export_file"
    echo
    pause_if_tty
}

# DESC: Affiche des statistiques sur les alias
# USAGE: show_statistics
show_statistics() {
    show_header
    printf "${YELLOW}📊 Statistiques des alias${RESET}\n"
    printf "${BLUE}══════════════════════════════════════════════════════════════════${RESET}\n"

    total_aliases=$(parse_aliases | wc -l | tr -d ' ')
    echo "Nombre total d'alias: $total_aliases"

    printf "\n${CYAN}Top 5 des commandes les plus aliasées:${RESET}\n"
    parse_aliases | sed 's/^alias [^=]*="\?\([^"]*\)"\?$/\1/' | \
    awk '{print $1}' | sort | uniq -c | sort -rn | head -5 | \
    awk '{printf "  %2d × %s\n", $1, $2}'

    printf "\n${CYAN}Répartition par type:${RESET}\n"
    git_count=$(parse_aliases | grep -c "git" || echo "0")
    docker_count=$(parse_aliases | grep -c "docker" || echo "0")
    cd_count=$(parse_aliases | grep -c "cd " || echo "0")
    sudo_count=$(parse_aliases | grep -c "sudo" || echo "0")

    echo "  Git: $git_count alias"
    echo "  Docker: $docker_count alias"
    echo "  Navigation (cd): $cd_count alias"
    echo "  Système (sudo): $sudo_count alias"

    echo
    pause_if_tty
}
