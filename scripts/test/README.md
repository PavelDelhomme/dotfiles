# 🧪 Tests Automatisés des Managers

## 📋 Description

Système de test automatisé pour tester tous les managers dotfiles dans un environnement Docker sécurisé et isolé.

---

## 🚀 Utilisation rapide

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

1. **Existence** : Vérifier que le manager existe dans le shell
2. **Syntaxe core** : Vérifier la syntaxe du fichier core POSIX
3. **Syntaxe adapter** : Vérifier la syntaxe de l'adapter shell
4. **Chargement** : Vérifier que le manager peut être chargé
5. **Réponse** : Vérifier que le manager répond aux commandes

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
- [STATUS.md](../../STATUS.md) : État de la migration des managers

