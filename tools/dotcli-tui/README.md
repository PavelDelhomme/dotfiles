# dotcli-tui — menu Ink/TypeScript (spike)

Prototype inspiré de [Hermes Agent `ui-tui`](https://github.com/NousResearch/hermes-agent/tree/main/ui-tui) : **React + Ink** pour la sélection de menus `*man`, sans gateway JSON-RPC.

## Prérequis

- Node.js ≥ 20
- npm

## Build

```bash
make build-dotcli-tui   # npm install + bin/dotcli-tui
```

Le lanceur exécute `tsx src/menu.tsx` (comme `hermes --tui --dev`), sans bundle esbuild monolithique.

## Usage

```bash
dotcli-tui doctor
printf 'Quitter|0\nAide|help\n' > /tmp/m.txt
dotcli-tui menu --prompt "TEST" --items-file /tmp/m.txt --simulate-index 1
```

## Activation dans les managers

```bash
export DOTFILES_DOTCLI_TUI_ENABLE=1
exec zsh
```

Priorité dans `manager_ui_select_file` : **dotcli-tui** → dotcli C → fzf/ncmenu → read.

## Doc

Voir [`docs/architecture/TUI_HERMES_RESEARCH.md`](../../docs/architecture/TUI_HERMES_RESEARCH.md).
