function list_aliases
    grep -E '^alias ' "$ALIASES_FILE" | sed 's/^alias/👉 Alias:/'
end

