# Recherche TUI — inspiration Hermes Agent

> **Date** : 2026-06-15  
> **Repo étudié** : [NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)  
> **Lien dotfiles** : P3 / P3b (`TODOS.md`) — moteur TUI mutualisé pour les `*man`

## Clarification MPJS / TJS

Dans Hermes Agent, il n’y a **pas** de stack nommée « MPJS » ou « TJS ». Ce que tu visais correspond très probablement à :

| Terme entendu | Réalité dans Hermes |
|---------------|---------------------|
| **TJS** | **TypeScript** (+ JavaScript) — dossier `ui-tui/`, build `tsc` / `esbuild` |
| **MPJS** | Confusion fréquente avec **npm** / **Node.js**, ou avec **Ink** (React pour terminal) |
| Moteur TUI | **Ink** (`ink` + fork local `@hermes/ink`) + **React 19** |

Hermes documente explicitement : *« React + Ink terminal UI. TypeScript owns the screen. Python owns sessions. »*  
Voir `ui-tui/README.md` dans le repo.

## Architecture Hermes (résumé)

```text
hermes --tui
    │
    ├─ Node.js ≥ 20 lance ui-tui/dist/entry.js (ou tsx en --dev)
    │     └─ React + Ink : transcript, composer, overlays, pickers
    │
    └─ sous-processus Python : python -m tui_gateway.entry
          └─ JSON-RPC newline-delimited sur stdin/stdout
          └─ sessions, tools, modèle, slash commands, approvals
```

**Séparation des rôles** (pattern clé à retenir) :

1. **Présentation** (TS/Ink) — rendu, clavier, souris, overlays, streaming visuel
2. **Orchestration** (Python `tui_gateway`) — logique métier, état, RPC
3. **Contrat** — JSON-RPC + événements (`message.delta`, `tool.start`, `approval.request`, …)

Le CLI Python (`hermes_cli/main.py`) ne fait que lancer le bundle Node et retomber sur le CLI classique si Node/TTY manquent.

## Stack technique Hermes `ui-tui/`

| Couche | Techno |
|--------|--------|
| UI | Ink 6, React 19, `@hermes/ink` (fork local) |
| État | nanostores + `@nanostores/react` |
| Build | esbuild → `dist/entry.js`, vitest pour tests |
| Transport | `GatewayClient` — spawn Python, JSON-RPC stdio |
| Gateway | `tui_gateway/` — `entry.py`, `server.py`, `slash_worker.py` |

Fichiers d’entrée utiles :

- `ui-tui/src/entry.tsx` — gate TTY, démarre App
- `ui-tui/src/gatewayClient.ts` — pont Node ↔ Python
- `ui-tui/src/app.tsx` — arbre Ink principal
- `ui-tui/packages/hermes-ink/` — fork Ink (rendu alternate screen, sélection souris, etc.)

## Ce qui est intéressant pour les dotfiles

| Idée Hermes | Application dotfiles |
|-------------|----------------------|
| TUI riche en sous-processus | `dotcli-tui` (Node/Ink) appelé depuis `manager_ui_select_file` |
| Fallback si pas TTY / pas Node | Garder `dotcli` C, `fzf`, `ncmenu`, `read` |
| Contrat I/O stable | Réutiliser [`DOTCLI_MENU_CONTRACT.md`](../platform/DOTCLI_MENU_CONTRACT.md) (`label\|key` → clé stdout) |
| Feature flag | `DOTFILES_DOTCLI_TUI_ENABLE=1` (opt-in, comme `DOTFILES_DOTCLI_ENABLE`) |
| Pas de double logique métier | Les `*man` restent en shell ; le TUI ne fait que **sélectionner** |
| Build optionnel | `make build-dotcli-tui` ; CI OK sans Node si non compilé |

## Ce qu’on ne copie **pas** (hors scope)

- Gateway JSON-RPC complet (sessions agent, tools, streaming LLM)
- Python `tui_gateway` — nos managers sont déjà POSIX shell
- Overlays chat, markdown, approvals sudo — hors besoin menu `*man`
- Dépendance Node obligatoire au bootstrap — reste **optionnelle**

## État actuel dotfiles (rappel)

```text
manager_ui_select_file
  → dotcli (C) si DOTFILES_DOTCLI_ENABLE=1
  → dotfiles_ncmenu_select (fzf → ncmenu Go)
  → return 127 → read manuel du manager
```

Cible intermédiaire (spike 2026-06-15) :

```text
manager_ui_select_file
  → dotcli-tui (Ink/TS) si DOTFILES_DOTCLI_TUI_ENABLE=1 + binaire présent
  → dotcli (C) si DOTFILES_DOTCLI_ENABLE=1
  → fzf / ncmenu
  → read
```

## Prototype livré : `tools/dotcli-tui/`

Spike minimal **menu seulement** — même contrat que `dotcli menu` :

```bash
make build-dotcli-tui    # npm install + bundle → bin/dotcli-tui
make test-dotcli-tui     # smoke non interactif
DOTFILES_DOTCLI_TUI_ENABLE=1 exec zsh
updateman status         # ou tout *man avec menu
```

Commandes :

```bash
dotcli-tui menu --prompt "Titre" --items-file /tmp/menu.txt
dotcli-tui doctor
```

## Prochaines étapes (backlog)

| Étape | Description |
|-------|-------------|
| P3c-1 | Valider visuellement Ink vs dotcli C sur petit/grand terminal |
| P3c-2 | Pagination longue liste (viewport comme dotcli C) |
| P3c-3 | Mode `--no-tui` ligne + tests CI identiques à F.7 |
| P3c-4 | Documenter prérequis Node 20+ dans `docs/guides/INSTALL.md` (optionnel) |
| P3c-5 | Évaluer si un mini-gateway shell↔Ink vaut le coup pour status live (hors menu) |

## Références

- [Hermes TUI user guide](https://hermes-agent.nousresearch.com/docs/user-guide/tui)
- [ui-tui/README.md](https://github.com/NousResearch/hermes-agent/blob/main/ui-tui/README.md)
- [Architecture dev](https://hermes-agent.nousresearch.com/docs/developer-guide/architecture)
- [PR #4692 — Ink refactor](https://github.com/NousResearch/hermes-agent/pull/4692)
- Dotfiles : [`DOTCLI_MENU_CONTRACT.md`](../platform/DOTCLI_MENU_CONTRACT.md), [`UI_MENU_RESTRUCTURE.md`](UI_MENU_RESTRUCTURE.md)
