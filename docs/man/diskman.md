# diskman(1) — gestion disque et nettoyage prudent

## Nom

**diskman** — diagnostic d’espace disque, recherche de gros fichiers, inodes et nettoyage contrôlé.

## Synopsis

```text
diskman [help | -h | --help]
diskman overview
diskman usage [PATH] [DEPTH]
diskman biggest [PATH] [N]
diskman inodes [PATH]
diskman clean [--dry-run|--apply] [--yes] [target]
diskman report [OUT]
```

## Description

`diskman` regroupe les commandes de diagnostic disque utilisées au quotidien :

- `df -hT`, `lsblk`, `findmnt` pour l’état global ;
- `du` / `find` pour identifier les dossiers et fichiers lourds ;
- `df -i` et comptage d’entrées pour les problèmes d’inodes ;
- un nettoyage **dry-run par défaut**, avec exécution uniquement si `--apply` est demandé.

Le but est de pouvoir répondre vite à : « qu’est-ce qui prend de la place ? » sans lancer directement des commandes destructrices.

## Commandes

| Commande | Effet |
|----------|-------|
| `diskman overview` | Vue d’ensemble : `df`, `lsblk`, caches connus, Docker si disponible. |
| `diskman usage [PATH] [DEPTH]` | Dossiers lourds, triés du plus gros au plus petit. |
| `diskman biggest [PATH] [N]` | Top N des plus gros fichiers dans le même filesystem (`-xdev`). |
| `diskman inodes [PATH]` | Utilisation des inodes + dossiers avec beaucoup d’entrées. |
| `diskman mounts` | Table de montage (`findmnt` si disponible). |
| `diskman health` | Résumé SMART si `smartctl` est installé. |
| `diskman clean --dry-run all` | Montre ce qui serait nettoyé, sans rien supprimer. |
| `diskman clean --apply journal` | Nettoie réellement la cible demandée après confirmation TTY. |
| `diskman report ~/disk-report.txt` | Produit un rapport texte complet. |

## Targets de nettoyage

| Target | Action en `--apply` |
|--------|---------------------|
| `pacman` | Cache pacman via `paccache` si disponible, sinon `pacman -Sc`. |
| `apt` | `apt-get clean` + `apt-get autoremove -y`. |
| `journal` | `journalctl --vacuum-time=14d`. |
| `user-cache` | Entrées anciennes de `~/.cache` (`mtime +14`). |
| `trash` | Vide la corbeille utilisateur. |
| `tmp` | Supprime les entrées `/tmp` de plus de 7 jours. |
| `docker` | `docker system prune -af`. |
| `all` | Enchaîne toutes les cibles compatibles avec le système. |

## Sécurité

- Le mode par défaut de `clean` est **`--dry-run`**.
- En non-TTY, `--apply` refuse de s’exécuter sans **`--yes`**.
- Les commandes qui nécessitent root utilisent `sudo`.
- `docker` peut libérer beaucoup d’espace mais supprime images/conteneurs non utilisés : lire le dry-run avant.

## Exemples

```bash
diskman overview
diskman usage ~ 2
diskman biggest /var/log 30
diskman clean --dry-run all
diskman clean --apply journal
diskman report ~/disk-report.txt
```

## Fichiers

- Core : `core/managers/diskman/core/diskman.sh`
- Adaptateurs : `shells/{zsh,bash,fish}/adapters/diskman.*`
- Tests : `scripts/test/subcommands/diskman.list`

## Voir aussi

`df(1)`, `du(1)`, `find(1)`, `lsblk(8)`, `journalctl(1)`, `docker-system-prune(1)`, `docs/guides/MANAGERS.md`.
