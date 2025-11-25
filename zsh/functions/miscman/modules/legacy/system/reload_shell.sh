# DESC: Recharge complètement la configuration du shell en relançant une nouvelle session. Utile après modification de .zshrc ou autres fichiers de config.
# USAGE: reload_shell
# EXAMPLE: reload_shell
reload_shell() {
	exec "$SHELL" -l
}
