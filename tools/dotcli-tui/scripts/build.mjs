#!/usr/bin/env node
/**
 * Génère bin/dotcli-tui (wrapper bash → tsx src/menu.tsx).
 * Pas de bundle monolithique : même approche que hermes --tui --dev.
 */
import { writeFileSync, chmodSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const binLink = join(root, '../../bin/dotcli-tui');

const wrapper = `#!/usr/bin/env bash
# Lanceur dotcli-tui (Ink/TS via tsx) — généré par make build-dotcli-tui
DOTFILES_DIR="\${DOTFILES_DIR:-$HOME/dotfiles}"
TUI_DIR="$DOTFILES_DIR/tools/dotcli-tui"
if [ ! -f "$TUI_DIR/node_modules/tsx/dist/cli.mjs" ]; then
  echo "dotcli-tui: exécutez make build-dotcli-tui (npm install)" >&2
  exit 1
fi
exec node "$TUI_DIR/node_modules/tsx/dist/cli.mjs" "$TUI_DIR/src/menu.tsx" "$@"
`;

writeFileSync(binLink, wrapper, { mode: 0o755 });
chmodSync(binLink, 0o755);
console.log(`wrapper ${binLink}`);
