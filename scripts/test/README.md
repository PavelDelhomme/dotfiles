# 🧪 Tests Automatisés des Managers

## 📋 Description

Système de test automatisé pour tester tous les managers dotfiles dans un environnement Docker sécurisé et isolé.

---

## 🛡️ Comment tester sans impacter ta machine

| Objectif | Où | Commande | Impact hôte |
|----------|-----|----------|--------------|
| **Vérifier le projet** (syntaxe core, adapters, scripts, URLs) | Local **ou** Docker | `make test-checks` | Aucun (lecture seule) |
| **Tester les managers** (pathman, gitman, installman, etc.) | **Docker** | `make test` | Aucun (conteneur isolé) |
| **Tester à la main** (installman list, pathman show, etc.) | **Docker** | `make docker-in` | Aucun (volume en lecture seule) |
| **Validation complète** (PATH, services, structure, symlinks) | Local (ou Docker) | `make validate` | Aucun (vérifications uniquement) |
| **Suite complète** (checks + managers Docker + multi-shell + sync) | Local | `bash scripts/test/test_all_complete.sh` | Managers en Docker, reste local |

- **Docker** : tes dotfiles sont montés en **lecture seule** dans le conteneur. Tu peux lancer `make test` et `make docker-in` sans modifier ton système.
- **test-checks** : vérifie la syntaxe des cores POSIX, des adapters ZSH, des scripts install, et les URLs de téléchargement (Cursor, Chrome, Flutter…). Utilisable partout.
- **testman / testzshman** : si tu les utilises, tu peux les lancer **dans le conteneur** après `make docker-in` pour tester tes modules ZSH sans toucher à l’hôte.

---

## 🚀 Utilisation rapide

### Entrer dans l'environnement Docker (recommandé)

Pour tester les dotfiles (pathman TUI, installman, etc.) **sans toucher à ton PC** :

```bash
make docker-in
```

- Construit l'image si elle n'existe pas.
- Monte tes dotfiles en lecture seule (`PWD` → `/root/dotfiles`).
- Ouvre un **zsh** avec la config chargée (pathman, installman, etc.).

Choisir un autre shell :

```bash
make docker-in SHELL=bash
make docker-in SHELL=fish
make docker-in SHELL=sh
```

**Pas besoin de rebuild** pour les changements de dotfiles : le repo est monté en volume, les modifs sont prises en compte à chaque `make docker-in`. Rebuild uniquement si tu modifies le **Dockerfile** (nouveaux paquets, etc.) :

```bash
make docker-rebuild
make docker-in
```

Dans le conteneur, pathman écrit ses logs dans `~/.config/dotfiles/pathman/` (répertoire inscriptible). Le menu fzf est disponible si `fzf` est installé (inclus dans l'image) : `dfmenu pathman` ou `dotfiles-menu --file share/menus/pathman.menu`.

### Vérification multi-shell (installman)

Vérifie que `installman` fonctionne depuis zsh, bash et sh :

```bash
bash scripts/test/verify_multishell.sh
```

### Test bootstrap dans Docker

Bootstrap + vérification installman + multi-shell dans le conteneur (à lancer depuis l’hôte, avec les dotfiles montés) :

```bash
docker run --rm -v ~/dotfiles:/root/dotfiles -w /root/dotfiles dotfiles-test:latest bash scripts/test/docker/run_dotfiles_bootstrap.sh
```

Ou depuis le répertoire dotfiles : `bash scripts/test/docker/run_dotfiles_bootstrap.sh` (s’exécute dans l’environnement courant).

### Test des managers migrés (RECOMMANDÉ - Test progressif)

**Teste uniquement les managers déjà migrés vers la structure hybride** :

```bash
cd ~/dotfiles
bash scripts/test/test_migrated_managers.sh
```

**Managers testés** : pathman, manman, searchman, aliaman, installman, configman, gitman, fileman, helpman, cyberman, devman, virtman, miscman (13 managers)

### Test complet de tous les managers

**Tous les tests s'exécutent dans Docker (isolé et sécurisé)** :

```bash
cd ~/dotfiles
bash scripts/test/test_all_managers.sh
```

Le script :
1. ✅ Vérifie que Docker est disponible
2. ✅ Construit l'image Docker (si nécessaire)
3. ✅ Lance tous les tests dans un conteneur isolé
4. ✅ Génère des rapports détaillés
5. ✅ Nettoie automatiquement les conteneurs

### Test personnalisé (managers spécifiques)

```bash
# Tester seulement pathman et manman
TEST_MANAGERS="pathman manman" bash scripts/test/test_all_managers.sh
```

### Test d'un manager spécifique

```bash
# Dans Docker
docker run --rm -it \
    -v ~/dotfiles:/root/dotfiles:ro \
    dotfiles-test:latest \
    /bin/sh -c "source /root/dotfiles/scripts/test/utils/manager_tester.sh && test_manager pathman zsh"
```

---

## 📁 Structure

```
scripts/test/
├── test_all_managers.sh          # Script principal de test
├── docker/
│   └── Dockerfile.test            # Image Docker pour tests
├── utils/
│   └── manager_tester.sh         # Utilitaire pour tester un manager
└── README.md                      # Cette documentation
```

---

## 🔧 Configuration

### Variables d'environnement

- `DOTFILES_DIR` : Chemin vers les dotfiles (défaut: `$HOME/dotfiles`)
- `TEST_RESULTS_DIR` : Répertoire pour les résultats (défaut: `$DOTFILES_DIR/test_results`)
- `DOCKER_IMAGE` : Nom de l'image Docker (défaut: `dotfiles-test:latest`)

---

## 📊 Tests effectués

Pour chaque manager, les tests suivants sont effectués :

1. **Existence** : Vérifier que le manager existe dans le shell cible (après chargement de l'adapter)
2. **Syntaxe core** : Vérifier la syntaxe du fichier core POSIX
3. **Syntaxe adapter** : Vérifier la syntaxe de l'adapter shell
4. **Chargement** : Vérifier que le manager peut être chargé
5. **Réponse** : Vérifier que le manager répond aux commandes
6. **Tests fonctionnels (smoke)** :
   - **gitman** : `gitman time-spent` (dans le dépôt dotfiles ; ignoré si pas de .git, ex. en Docker sans volume)
   - **pathman** : `pathman show` (vérifie que la commande affiche le PATH)
   - D’autres commandes non interactives peuvent être ajoutées par manager dans `manager_tester.sh`

---

## 📝 Rapport

Le rapport de test est généré dans :
- `$TEST_RESULTS_DIR/all_managers_test_report.txt`

---

## 🐳 Docker

### ⚠️ IMPORTANT : Tous les tests s'exécutent dans Docker

**Avantages** :
- ✅ **Isolé** : Aucune modification de votre système hôte
- ✅ **Sécurisé** : Environnement complètement isolé
- ✅ **Reproductible** : Même environnement à chaque fois
- ✅ **Nettoyage facile** : Suppression des conteneurs sans impact

### Construire l'image manuellement

```bash
docker build -f scripts/test/docker/Dockerfile.test -t dotfiles-test:latest .
```

### Lancer le test bootstrap (rapide)

```bash
docker compose -f scripts/test/docker/docker-compose.yml run --rm dotfiles-test \
  bash -c "bash /root/dotfiles/scripts/test/docker/run_dotfiles_bootstrap.sh"
```

(Remplace la commande par défaut qui lance `run_tests.sh`.)

### Lancer un conteneur interactif (pour debug)

```bash
docker run --rm -it \
    -v ~/dotfiles:/root/dotfiles:ro \
    -v ~/dotfiles/test_results:/root/test_results:rw \
    dotfiles-test:latest \
    /bin/zsh
```

### Nettoyer

```bash
# Nettoyer les conteneurs et volumes de test
docker compose -f scripts/test/docker/docker-compose.yml down -v

# Supprimer l'image
docker rmi dotfiles-test:latest
```

---

## 🔍 Dépannage

### Docker n'est pas installé

```bash
installman docker
```

### Erreur de permission Docker

```bash
sudo usermod -aG docker $USER
# Puis déconnectez-vous et reconnectez-vous
```

### L'image ne se construit pas

Vérifiez que vous êtes dans le répertoire dotfiles :
```bash
cd ~/dotfiles
```

---

## 📚 Documentation

- [progress_bar.sh](../../core/utils/PROGRESS_BAR_README.md) : Documentation de la barre de progression
- [STATUS.md](../../STATUS.md) : Vue d’ensemble (objectifs, tests)
- [TODOS.md](../../TODOS.md) : Roadmap et actions

