# Contrat `dotcli menu`

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir `docs/UNIFIED_PLATFORM_ROADMAP.md`).

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

## Sortie

- `stdout`: la **clé sélectionnée** (exactement une ligne, ex: `2` ou `q`)
- `stderr`: réservé aux erreurs/diagnostic (éviter pour le flux nominal)

## Comportement

- **Mode non-TTY** (CI, pipe): sélectionne la première entrée valide.
  - si `--query` est fourni, tente d'abord une correspondance `label`/`key`.
- **Mode TTY**:
  - affiche le prompt + la liste numérotée,
  - accepte un numéro (`1..N`) ou une clé directe (`q`, `2`, etc.),
  - accepte une recherche simple (texte libre -> première entrée correspondante),
  - `Entrée` = première entrée.

## Codes retour

- `0`: sélection valide
- `1`: pas d'entrée exploitable ou choix invalide

## Règles d'intégration manager

- Toujours garder un fallback (`dotfiles_ncmenu_select`, `fzf`, ou saisie manuelle).
- Ne jamais bloquer hors TTY.
- Feature flag recommandé pendant la migration (`DOTFILES_DOTCLI_ENABLE=1`).
