# 📁 Stockage des Données des Managers

## 📊 Vue d'ensemble

Certains managers créent des dossiers cachés dans `~/.` pour stocker leurs données, tandis que d'autres n'en ont pas besoin. Voici pourquoi :

---

## ✅ Managers avec dossiers cachés

### 🔐 `.cyberman/` - Cyberman

**Pourquoi ?** Stocke des données sensibles et persistantes :
- **Environnements de test** : Cibles, notes, historique, résultats, TODOs
- **Rapports de scans** : Résultats de scans de sécurité
- **Workflows** : Séquences d'actions automatisées
- **Configurations** : Clés API, templates personnalisés
- **Scans** : Résultats de scans (nuclei, sqlmap, xss, etc.)

**Structure :**
```
~/.cyberman/
├── environments/     # Environnements de test (JSON)
├── reports/         # Rapports de scans (JSON)
├── workflows/       # Workflows automatisés (JSON)
├── scans/           # Résultats de scans
│   ├── nuclei/
│   ├── sqlmap/
│   ├── xss/
│   └── fuzzer/
├── templates/       # Templates personnalisés
│   └── nuclei/
├── config/          # Configuration (clés API, etc.)
│   ├── osint.conf
│   └── iot.yaml
└── scripts/         # Scripts personnalisés
```

**Sécurité :** ⚠️ **SENSIBLE** - Contient des données de sécurité, cibles, clés API

---

### 📚 `.cyberlearn/` - Cyberlearn

**Pourquoi ?** Stocke la progression et les labs :
- **Progression** : État d'avancement des formations
- **Labs** : Labs de formation cybersécurité
- **Données d'apprentissage** : Statistiques, scores, etc.

**Structure :**
```
~/.cyberlearn/
├── progress.json    # Progression globale
└── labs/            # Labs de formation
```

**Sécurité :** ⚠️ **PERSONNEL** - Contient votre progression

---

## ❌ Managers SANS dossiers cachés

### 🔧 Pourquoi certains managers n'ont pas de dossiers cachés ?

#### **Aliaman** (Gestionnaire d'alias)
- **Pas besoin** : Les alias sont stockés dans `zsh/aliases.zsh`
- **Pas de données persistantes** : Les alias sont dans le code source

#### **Devman** (Gestionnaire développement)
- **Pas besoin** : Gère des outils, pas de données persistantes
- **Configuration** : Stockée dans les outils eux-mêmes (Flutter, .NET, etc.)

#### **Multimediaman** (Gestionnaire multimédia)
- **Pas besoin** : Gère des outils, pas de données persistantes
- **Fichiers** : Stockés dans les emplacements standards (Videos, Music, etc.)

#### **Netman** (Gestionnaire réseau)
- **Pas besoin** : Gère des configurations réseau temporaires
- **Pas de stockage** : Les configurations sont appliquées directement

#### **SSHman** (Gestionnaire SSH)
- **Configuration** : Stockée dans `~/.ssh/config` (standard)
- **Pas besoin** : Utilise les fichiers SSH standards

#### **Testman** (Gestionnaire de tests)
- **Pas besoin** : Tests temporaires, pas de stockage persistant
- **Résultats** : Peuvent être dans `test_results/` (dans dotfiles)

---

## 🔒 Sécurité des Environnements

### ⚠️ Problème actuel

Les environnements `.cyberman/environments/` contiennent :
- **Cibles sensibles** (IPs, domaines, URLs)
- **Notes de tests** (vulnérabilités, exploits)
- **Historique d'actions** (scans, attaques)
- **Résultats de tests** (données sensibles)

**Risque :** Accessible par n'importe quel utilisateur du système si permissions incorrectes.

---

## ✅ Solution : Sécurité des Environnements

### Permissions recommandées

```bash
# Dossier principal : 700 (rwx------)
chmod 700 ~/.cyberman
chmod 700 ~/.cyberlearn

# Sous-dossiers : 700
chmod 700 ~/.cyberman/environments
chmod 700 ~/.cyberman/reports
chmod 700 ~/.cyberman/workflows
chmod 700 ~/.cyberman/config

# Fichiers : 600 (rw-------)
find ~/.cyberman -type f -exec chmod 600 {} \;
find ~/.cyberlearn -type f -exec chmod 600 {} \;
```

### Vérification du propriétaire

```bash
# S'assurer que l'utilisateur est propriétaire
chown -R $USER:$USER ~/.cyberman
chown -R $USER:$USER ~/.cyberlearn
```

---

## 📝 Recommandations

1. **Création automatique avec permissions sécurisées**
   - Les scripts doivent créer les dossiers avec `700`
   - Les fichiers avec `600`

2. **Vérification au démarrage**
   - Vérifier les permissions au chargement des managers
   - Corriger automatiquement si nécessaire

3. **Documentation**
   - Documenter quels managers créent des dossiers
   - Expliquer pourquoi et ce qu'ils contiennent

---

## 🔍 Détection automatique

Pour vérifier quels managers créent des dossiers :

```bash
# Chercher les créations de dossiers cachés
grep -r "mkdir.*\." zsh/functions/ | grep "~/\."
```

---

## 📊 Tableau récapitulatif

| Manager | Dossier caché | Raison | Sécurité requise |
|---------|---------------|--------|------------------|
| **cyberman** | `~/.cyberman/` | Environnements, rapports, scans | ⚠️ **HAUTE** |
| **cyberlearn** | `~/.cyberlearn/` | Progression, labs | ⚠️ **MOYENNE** |
| **aliaman** | ❌ Aucun | Alias dans code source | ✅ N/A |
| **devman** | ❌ Aucun | Gestion d'outils | ✅ N/A |
| **multimediaman** | ❌ Aucun | Gestion d'outils | ✅ N/A |
| **netman** | ❌ Aucun | Configurations temporaires | ✅ N/A |
| **sshman** | ❌ Aucun | Utilise `~/.ssh/` (standard) | ✅ N/A |
| **testman** | ❌ Aucun | Tests temporaires | ✅ N/A |

---

## 🛡️ Implémentation de la Sécurité

Voir `scripts/security/secure_manager_dirs.sh` pour l'implémentation automatique.

