#!/bin/sh
# Extrait de shared/env.sh (début) — sauvegarde du PATH initial, sans effet de bord.

if [ -z "${PATH_ORIGINAL:-}" ]; then
	export PATH_ORIGINAL="$PATH"
fi
