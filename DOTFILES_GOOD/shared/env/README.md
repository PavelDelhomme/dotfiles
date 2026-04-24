# `shared/env/` — variables d’environnement (POSIX)

## Ordre de chargement

Les fichiers `*.sh` sont sourcés par `../lib/bootstrap_posix.sh` dans l’**ordre lexicographique** (`00_`, `01_`, …).

## Résilience (« foirer » sans tout bloquer)

- Un fichier **`*.sh`** qui **échoue** au sourcing : le bootstrap **continue** avec les suivants et affiche un **avertissement** sur stderr.
- Pour **désactiver** un extrait sans le supprimer : le renommer avec une extension **autre que** `.sh` (ex. **`10_foo.sh.off`**) pour qu’il ne soit plus pris par le glob `*.sh`.
- En cas de doute après un essai : `make test-dotfiles-good`, corriger ou renommer le fichier concerné, passer à la suite.

## Fichiers présents (bac à sable)

| Fichier | Origine / rôle |
|---------|----------------|
| `00_paths.sh` | Marqueur de chemins (`DOTFILES_GOOD_ENV_LOADED`) après bootstrap. |
| `05_path_original.sh` | Extrait `shared/env.sh` : `PATH_ORIGINAL` si absent. |
| `10_toolchain_paths.sh` | `CHROME_EXECUTABLE`, `EMACSDIR`, `DOTNET_PATH`. |
| `11_pub_cache_export.sh` | `PUB_CACHE` seul (pas de `mkdir` ici). |
| `12_android_exports.sh` | `ANDROID_HOME`, `ANDROID_SDK_ROOT` (pas de `mkdir` / PATH ici). |
| `13_flutter_ndk_exports.sh` | `ADDED_FLUTTER_PATH`, `NDK_HOME` (dépend de `ANDROID_HOME` défini en 12). |
| `14_android_tool_paths_export.sh` | `CMDLINE_TOOLS`, `PLATFORM_TOOLS`, `ANDROID_TOOLS` (exports ; pas de `mkdir`). |

## Migration depuis la prod

- Aujourd’hui, la vérité opérationnelle est encore **`../../shared/env.sh`** (sourcé par `../../shared/config.sh`).
- Migrer **par petits fichiers** ici ; le gros morceau restant côté prod est **`mkdir`**, **`add_to_path` / `clean_path`**, concat **`PATH`**, **`echo`** de confirmation — à traiter après le **jalon B** (`TODOS.md`).
- Ne pas sourcer automatiquement `../../shared/env.sh` depuis ce dossier tant que les effets de bord (messages, dépendances `add_to_path`) ne sont pas audités pour le bac à sable.
