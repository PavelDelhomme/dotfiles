# Contrat `dotcli menu`

> **Réf. doc** : [`DOCUMENTATION_REFERENCE.md`](DOCUMENTATION_REFERENCE.md) · [`TESTS.md`](TESTS.md) (validation manuelle)

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir [`UNIFIED_PLATFORM_ROADMAP.md`](UNIFIED_PLATFORM_ROADMAP.md)).

## Objectif

Fournir une API de menu commune, réutilisable par tous les managers, indépendamment du shell (`zsh`, `bash`, `fish`, `sh`).

## Entrée

- `stdin` reçoit des lignes au format:
  - `label|key`
- Exemple:
  - `Afficher les connexions|2`
  - `Quitter|q`

## Commande

- `dotcli menu --prompt "NETMAN - Menu principal"`
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
  - **TUI** : liste avec **ligne surlignée** ; **↑/↓** ou **j/k** ; chiffres **1–9** pour déplacer le surlignage ; **Entrée** valide ; **q** choisit le **premier** item (sortie rapide) ; **Ctrl+C** restaure le terminal (code **130**).
  - Avec **`--no-tui`** : prompt + liste + saisie **une ligne** (numéro, clé, ou sous-chaîne) comme l’ancien comportement.

## Codes retour

- `0`: sélection valide
- `1`: pas d'entrée exploitable ou choix invalide
- `130`: interrompu (SIGINT) en TUI après restauration tty

## Règles d'intégration manager

- Toujours garder un fallback (`dotfiles_ncmenu_select`, `fzf`, ou saisie manuelle).
- Ne jamais bloquer hors TTY.
- Feature flag recommandé pendant la migration (`DOTFILES_DOTCLI_ENABLE=1`).
