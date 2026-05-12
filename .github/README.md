# GitHub — workflows et CI

- **Workflow actif** : [`workflows/ci-checks.yml`](workflows/ci-checks.yml) — `make test-checks` sur chaque push / PR (syntaxe + URLs).
- **Guide complet** (e-mail `dawidd6/action-send-mail`, secrets OVH, roadmap CI Docker / installation) : [`../docs/guides/GITHUB_ACTIONS.md`](../docs/guides/GITHUB_ACTIONS.md).

Les **secrets** (SMTP, `EMAIL_FROM`, etc.) se configurent dans **Settings → Secrets and variables → Actions** du dépôt GitHub, pas dans ce dépôt.
