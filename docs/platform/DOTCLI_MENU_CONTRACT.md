# Contrat `dotcli menu`

> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests (validation manuelle)** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir [`UNIFIED_PLATFORM_ROADMAP.md`](UNIFIED_PLATFORM_ROADMAP.md)).

## Objectif

Fournir une API de menu commune, réutilisable par tous les managers, indépendamment du shell (`zsh`, `bash`, `fish`, `sh`).

## Entrée

- **Items du menu** (deux modes) :
  - **`--items-file PATH`** *(recommandé depuis les managers)* : lit les lignes `label|key` depuis un fichier ; **stdin reste libre** pour le clavier TTY.
  - **`stdin`** (pipe ou redirection) : lignes `label|key` — pratique en CI ; en TTY réel, préférer `--items-file` pour ne pas casser l’interaction clavier.
- Exemple:
  - `Afficher les connexions|2`
  - `Quitter|q`

## Commande

- `dotcli menu --prompt "NETMAN - Menu principal" --items-file /tmp/menu.txt`
- Optionnel : `--query <texte>` (sélectionne la première entrée correspondante en non-TTY)
- Optionnel : `--no-tui` ou variable **`DOTFILES_DOTCLI_MENU_NO_TUI=1`** — mode **ligne** (liste + saisie), sans mode brut terminal (tests prudents en TTY réel).
- Optionnel : `--dry-run` — aperçu sur stderr, clé choisie sur stdout (non destructif).
- Optionnel : `--simulate-index N` (1-based) — choix déterministe sans interaction.

## Sortie

- `stdout`: la **clé sélectionnée** (exactement une ligne, ex: `2` ou `q`)
- `stderr`: réservé aux erreurs/diagnostic (éviter pour le flux nominal)

## Comportement

- **Mode non-TTY** (CI, pipe): sélectionne la première entrée valide.
  - si `--query` est fourni, tente d'abord une correspondance `label`/`key`.
- **Mode TTY** (par défaut, sans `--no-tui`) :
  - **TUI** : liste avec **ligne surlignée** ; **↑/↓** ou **j/k** ; **Entrée** valide ; **q** choisit le **premier** item (sortie rapide) ; **Ctrl+C** restaure le terminal (code **130**).
  - **Longues listes** : `dotcli` affiche un viewport adapté à la hauteur du terminal au lieu de déborder. Navigation : **↑/↓** ligne par ligne, **PgUp/PgDn** ou **h/l** page par page, **g/G** début/fin. La barre indique `Lignes X-Y/N`.
  - Avec **`--no-tui`** : prompt + liste + saisie **une ligne** (numéro, clé, ou sous-chaîne) comme l’ancien comportement.

## Codes retour

- `0`: sélection valide
- `1`: pas d'entrée exploitable ou choix invalide
- `130`: interrompu (SIGINT) en TUI après restauration tty

## Règles d'intégration manager

- Toujours garder un fallback (`dotfiles_ncmenu_select`, `fzf`, ou saisie manuelle).
- Ne jamais bloquer hors TTY.
- Feature flag recommandé pendant la migration (`DOTFILES_DOTCLI_ENABLE=1`).
- Option Ink/TS : `DOTFILES_DOTCLI_TUI_ENABLE=1` + `bin/dotcli-tui` (voir [`TUI_HERMES_RESEARCH.md`](../architecture/TUI_HERMES_RESEARCH.md)).
