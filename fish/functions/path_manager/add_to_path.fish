set PATH_BACKUP_FILE "$HOME/dotfiles/fish/PATH_SAVE"
set PATH_LOG_FILE "$HOME/dotfiles/fish/path_log.txt"
set DEFAULT "/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl"

function add_to_path
	ensure_path_log
	set dir (string trim -r -c / $argv[1])
	if test -z "$dir"
		echo "❌ Usage: add_to_path <directory>"
		return 1
	end

	if not test -d "$dir"
		echo "🚫 Le répertoire '$dir' n'existe pas. Non ajouté au PATH."
		add_logs "ERROR" "Tentative d'ajout d'un répertoire inexistant : $dir"
		return 1
	end

	if not contains $dir $PATH
		set -gx PATH $dir $PATH
		echo "✅ Ajouté au PATH : $dir"
	else
		echo "ℹ Le répertoir '$dir' est déjà dans le PATH."
	end
end
