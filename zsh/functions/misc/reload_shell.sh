# DESC: Recharge la configuration du shell
# USAGE: reload_shell
reload_shell() {
	exec "$SHELL" -l
}
