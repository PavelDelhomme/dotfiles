# Roadmap Plateforme Unifiée

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir `docs/UNIFIED_PLATFORM_ROADMAP.md`).

## Objectif

Construire une base unique, réutilisable et testable pour tous les shells (`zsh`, `bash`, `fish`, `sh`), avec menus/TUI cohérents, installation guidée simple sur nouvelle machine, et migration progressive sans casser l'existant.

## Principes non négociables

- Une seule source de vérité métier: `core/` (POSIX + extensions progressives).
- Shells = couche d'adaptation minimale (`shells/*/adapters/`).
- Menus/TUI: API commune (dotcli), jamais dupliquée 4 fois.
- Fallback systématique non-interactif (CI/Docker/pipes).
- Chaque étape doit être rollbackable.

## Phases

### Phase 1 - Cadre et contrats (en cours)

- Contrat d'architecture (où placer quoi, comment nommer, comment charger).
- Contrat d'interface menu/TUI (inputs, outputs, codes retour, fallback).
- Contrat d'installation/migration (bootstrap, config, audit post-install).

### Phase 2 - Socle commun

- Stabiliser `dotcli` (MVP -> interaction TUI réelle).
- Externaliser rendu visuel (couleurs/icônes/fallback ASCII) dans le socle.
- Publier une API stable pour les managers.
- Contrat initial documenté: `docs/DOTCLI_MENU_CONTRACT.md`.

### Phase 3 - Migration managers

- Migrer prioritairement les managers monolithiques/dupliqués.
- Garder des wrappers legacy minces jusqu'à parité complète.
- Supprimer progressivement les chemins historiques redondants.

### Phase 4 - Installation et onboarding

- Installer dotfiles en mode guidé (interactif) ou automatique (silent).
- Vérifier compat shell + dépendances + menus/TUI + tests.
- Générer un rapport final "machine ready".

### Phase 5 - Finalisation DOTFILES_GOOD

- Converger l'arborescence cible validée vers la racine.
- Effectuer la bascule avec backup + rollback documentés.
- Consolider la doc utilisateur et mainteneur.

## Checklist qualité (à chaque lot)

- `make test`
- `make test-menu-fzf` (tant que fzf/ncmenu coexistent)
- tests manuels de la feature en `zsh`, `bash`, `fish`, `sh`
- test non-TTY (pipe / docker / CI)
- doc + TODO + STATUS à jour
