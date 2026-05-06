# Fiche de suivi — tests manuels (dotfiles)

> **Index** : [`STRUCTURE.md`](STRUCTURE.md) · **CI / smoke** : `make test`, `make test-help` · **Bac à sable** : `scripts/test/SANDBOX.md` · **Statut** : [`../STATUS.md`](../STATUS.md)

Ce document est la **checklist vivante** pour tout ce que la CI ne couvre pas (comportement métier, UX, menus, sorties exactes). À remplir **toi-même** : coche `OK` / `KO` / `N/A`, note l’écart dans **Notes** (manque doc, bug, amélioration souhaitée).

## Légende des colonnes

| Colonne | Signification |
|---------|----------------|
| **Commande / action** | Ce que tu exécutes (hôte ou conteneur). |
| **Contexte** | Shell, distro, TTY ou non, variables d’env. |
| **Résultat attendu** | Comportement ou extrait de sortie attendu. |
| **OK/KO** | Ton verdict. |
| **Notes** | Écarts, ticket, idée d’amélioration. |

**Symboles** : `OK` · `KO` · `N/A` (non applicable) · `PARTIEL`

---

## 0. Stratégie de couverture

1. **Machine neutre** : idéalement VM ou `make docker-in` sur une distro **sans** ton historique perso (voir § Docker).
2. **Répéter par shell** : `zsh`, `bash`, `fish`, et si pertinent `sh` — même commande, même tableau (dupliquer les lignes ou indiquer « tous shells »).
3. **Managers** : pour chaque manager de `scripts/test/config/migrated_managers.list`, au minimum **`$manager help`** (ou équivalent documenté). Le détail des sous-commandes auto-testées est dans `scripts/test/subcommands/<manager>.list` : tu peux **étendre** ce fichier manuellement ligne par ligne ici.
4. **Après migration** : ajouter une sous-section par feature migrée et **ne pas retirer** les anciennes lignes (marquer `N/A` si obsolète).

---

## 1. Installation depuis une base « neutre » (Linux)

| Commande / action | Contexte | Résultat attendu | OK/KO | Notes |
|-------------------|----------|------------------|-------|-------|
| Clone du dépôt | VM neuve, git installé | Arborescence complète, `make help` lisible | | |
| `make install` ou bootstrap documenté (`README.md`) | selon doc | Pas d’erreur bloquante ; fin avec consignes « recharger le shell » | | |
| Symlinks / `DOTFILES_DIR` | première session | Shell charge les adapters ; `echo $DOTFILES_DIR` cohérent | | |
| Post-install PATH | nouvelle session | Outils documentés accessibles ou message explicite si optionnel | | |

---

## 2. Cibles Make fréquentes (hôte)

| Commande / action | Contexte | Résultat attendu | OK/KO | Notes |
|-------------------|----------|------------------|-------|-------|
| `make help` | — | Liste des cibles sans erreur | | |
| `make test-help` | — | Aide variables / flux tests | | |
| `make test-dotcli` | `cc` disponible | Compilation + smoke `doctor` / `menu` / `render` | | |
| `make test-dotfiles-good` | — | Smoke bac à sable `DOTFILES_GOOD` | | |
| `make test` | Docker OK | CI managers + phase sous-commandes verte (ou écarts documentés dans `docs/ERRORS.md`) | | |
| `make tests` | TTY optionnel | Menu interactif tests | | |
| `make docker-build` | Docker | Image build OK | | |
| `make docker-in` | TTY | Choix distro/shell ; shell dans conteneur ; dotfiles montés RO | | |

---

## 3. `dotcli` (menu sélection active + modes prudents)

Préalable : `make build-dotcli` → binaire `bin/dotcli` (gitignored).

| Commande / action | Contexte | Résultat attendu | OK/KO | Notes |
|-------------------|----------|------------------|-------|-------|
| `bin/dotcli doctor` | — | Lignes `stdin_tty`, `stdout_tty`, `term` | | |
| `printf 'A|a\nB|b\n' \| bin/dotcli menu --prompt p` | **non-TTY** (pipe) | stdout = `a` (1re entrée) | | |
| idem + `--query B` | non-TTY | stdout = `b` | | |
| idem + `--simulate-index 2` | non-TTY | stdout = `b` | | |
| idem + `--dry-run` | non-TTY | stderr : aperçu ; stdout : clé surlignée (1ère) | | |
| `DOTFILES_DOTCLI_MENU_NO_TUI=1` + menu via manager | TTY | Pas de mode brut ; saisie ligne (voir `docs/platform/DOTCLI_MENU_CONTRACT.md`) | | |
| `DOTFILES_DOTCLI_ENABLE=1` + `netman` / `aliaman` / `cyberlearn` | TTY | Menus pilotés par dotcli ; fallback si binaire absent | | |
| Menu TUI (flèches / j k) | TTY réel | Ligne surlignée ; Entrée valide ; terminal restauré après Ctrl+C | | |

---

## 4. Docker — bac à sable live

| Commande / action | Contexte | Résultat attendu | OK/KO | Notes |
|-------------------|----------|------------------|-------|-------|
| `make docker-in` puis `source …/zshrc_custom` (ou bash/fish) | conteneur | Managers chargés sans erreur fatale | | |
| `pathman help` | zsh/bash/fish dans conteneur | Aide ou menu cohérent | | |
| `make test` depuis hôte | — | Rapports sous `TEST_RESULTS_DIR` inscriptible (voir `docs/ERRORS.md` si RO) | | |

---

## 5. Variables d’environnement à croiser (matrice légère)

| Variable | Test rapide | Résultat attendu | OK/KO | Notes |
|----------|-------------|------------------|-------|-------|
| `DOTFILES_DOTCLI_ENABLE=1` | menu manager | dotcli utilisé si binaire présent | | |
| `DOTFILES_DOTCLI_MENU_NO_TUI=1` | idem | mode ligne | | |
| `DOTFILES_TEST_MANAGERS=pathman,gitman` | `make test` | Sous-ensemble seulement | | |
| `DOCKER_DISTRO=debian` | `make docker-in` | Image debian | | |

---

## 6. Par shell — chargement et non-régression

| Commande / action | Contexte | Résultat attendu | OK/KO | Notes |
|-------------------|----------|------------------|-------|-------|
| Nouvelle session `zsh` | login interactif | Prompt + fonctions managers | | |
| Nouvelle session `bash` | idem | idem | | |
| Nouvelle session `fish` | idem | idem | | |
| Script `#!/bin/sh` minimal sourçant uniquement ce qui est documenté | POSIX | Pas d’erreur si usage supporté | | |

---

## 7. Managers — smoke manuel (liste migrée Docker)

Référence liste : `scripts/test/config/migrated_managers.list`.  
Pour chaque ligne, exécuter au minimum :

| Manager | Commande | Contexte | Résultat attendu | OK/KO | Notes |
|---------|----------|----------|------------------|-------|-------|
| pathman | `pathman help` | zsh / bash / fish | Aide ou usage clair | | |
| manman | `manman help` | idem | idem | | |
| searchman | `searchman help` | idem | idem | | |
| aliaman | `aliaman help` | idem | idem | | |
| installman | `installman help` | idem | idem | | |
| configman | `configman help` | idem | idem | | |
| gitman | `gitman help` | idem | idem | | |
| fileman | `fileman help` | idem | idem | | |
| helpman | `helpman help` | idem | idem | | |
| cyberman | `cyberman help` | idem | idem | | |
| devman | `devman help` | idem | idem | | |
| virtman | `virtman help` | idem | idem | | |
| miscman | `miscman help` | idem | idem | | |
| doctorman | `doctorman help` | idem | idem | | |
| netman | `netman help` | idem | idem | | |
| sshman | `sshman help` | idem | idem | | |
| processman | `processman help` | idem | idem | | |
| routeman | `routeman help` | idem | idem | | |
| testman | `testman help` | idem | idem | | |
| testzshman | `testzshman help` | idem | idem | | |
| moduleman | `moduleman help` | idem | idem | | |
| multimediaman | `multimediaman help` | idem | idem | | |
| cyberlearn | `cyberlearn help` | idem | idem | | |

**Extension** : copier/coller des lignes depuis `scripts/test/subcommands/<manager>.list` (hors `@skip`) et ajouter colonnes **Résultat attendu** au cas par cas.

---

## 8. Domaines transverses

### 8.1 PATH et outils

| Commande / action | Résultat attendu | OK/KO | Notes |
|-------------------|------------------|-------|-------|
| `pathman` (sous-commandes courantes doc) | PATH cohérent après modification | | |
| `installman` recherche / install (bac à sable) | Comportement documenté ; pas de casse hôte si `--dry-run` / VM | | |

### 8.2 Design / UX (couleurs, icônes)

| Contexte | Résultat attendu | OK/KO | Notes |
|----------|------------------|-------|-------|
| TTY avec couleurs | Lisible | | |
| `TERM=dumb` ou pipe | Pas de séquences illisibles ou crash | | |

### 8.3 Git / man

| Action | Résultat attendu | OK/KO | Notes |
|--------|------------------|-------|-------|
| `git help commit` | Doc accessible ou message `man` manquant (voir `docs/guides/TROUBLESHOOTING_MAN_GIT.md`) | | |

---

## 9. Synthèse « ce qui manque »

À remplir après une passe :

- **Fonctions non testées** (liste) :
- **Régressions** (lien `docs/ERRORS.md`) :
- **Améliorations souhaitées** (même si OK) :

---

## 10. Rappel — alignement avec `TODOS.md`

Tant qu’une tâche **finalisée** figure dans **`TODOS.md`** en « attente de validation **par toi** », la règle du dépôt est : **validation explicite + commit / push** avant de traiter la suite comme acquise. Voir **`TODOS.md`** (section règle de passage).
