# shellman(1) — bascule shells (session / user / system)

## Nom

**shellman** — choisir et configurer le shell (zsh, bash, fish, sh, …).

## Synopsis

```text
shellman [help | -h | --help | aide]
shellman status | list | doctor
shellman use <shell> [--session | --once | --user | --system]
```

## Scopes

| Scope | Effet |
|-------|--------|
| `--session` / `--once` | Ce terminal seulement (`exec` le shell) |
| `--user` | Shell de login via `chsh` (nouvelle connexion) |
| `--system` | Défaut comptes futurs (`/etc/default/useradd`, root) |

## Exemples

```bash
shellman status
shellman use fish --session    # test sans toucher chsh
shellman use zsh --user        # permanent pour ton user
```

## Voir aussi

`configman apply shell` · `manman` · [`docs/architecture/ROOT_LAYOUT.md`](../architecture/ROOT_LAYOUT.md)
