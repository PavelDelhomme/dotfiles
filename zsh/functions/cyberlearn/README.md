# CYBERLEARN - Système d'Apprentissage Cybersécurité

Plateforme complète d'apprentissage de la cybersécurité directement dans votre terminal, similaire à TryHackMe mais intégrée à vos dotfiles.

## 🎯 Fonctionnalités

- **📖 Modules de Cours Structurés** : 10 modules couvrant tous les aspects de la cybersécurité
- **🧪 Labs Pratiques** : Environnements Docker pour pratiquer en conditions réelles
- **📊 Suivi de Progression** : Suivez votre avancement avec badges et statistiques
- **🎯 Exercices Interactifs** : Exercices pratiques avec validation automatique
- **🏆 Badges & Certificats** : Obtenez des badges en complétant les modules

## 🚀 Utilisation

### Menu Interactif

```bash
cyberlearn
```

### Commandes Directes

```bash
# Démarrer un module
cyberlearn start-module basics
cyberlearn start-module network
cyberlearn start-module web

# Gérer les labs
cyberlearn lab start web-basics
cyberlearn lab stop web-basics
cyberlearn lab list
cyberlearn lab status

# Voir la progression
cyberlearn progress
```

### Alias Disponibles

```bash
cl                    # Alias pour cyberlearn
cyberlearn-module     # Alias pour start-module
cyberlearn-lab        # Alias pour lab
```

## 📚 Modules Disponibles

1. **🎯 Basics** - Bases de la Cybersécurité
   - Introduction à la cybersécurité
   - Types de menaces
   - Principes de sécurité (CIA)
   - Vulnérabilités et exploits
   - Bonnes pratiques

2. **🌐 Network** - Sécurité Réseau
   - Protocoles réseau
   - Scanning et énumération
   - Attaques réseau
   - Défense réseau

3. **🕸️ Web** - Sécurité Web
   - OWASP Top 10
   - XSS, SQL Injection
   - Authentification et session
   - Sécurité des APIs

4. **🔐 Crypto** - Cryptographie
   - Chiffrement symétrique/asymétrique
   - Hash et signatures
   - Certificats SSL/TLS
   - Cryptographie pratique

5. **🐧 Linux** - Sécurité Linux
   - Permissions et ACL
   - Audit et logging
   - Hardening Linux
   - Pentest Linux

6. **🪟 Windows** - Sécurité Windows
   - Active Directory
   - GPO et sécurité
   - Windows Defender
   - Pentest Windows

7. **📱 Mobile** - Sécurité Mobile
   - Android Security
   - iOS Security
   - App Security
   - Mobile Pentest

8. **🔍 Forensics** - Forensique Numérique
   - Acquisition de preuves
   - Analyse de fichiers
   - Analyse réseau
   - Timeline analysis

9. **🛡️ Pentest** - Tests de Pénétration
   - Méthodologie
   - Reconnaissance
   - Exploitation
   - Post-exploitation

10. **🚨 Incident** - Incident Response
    - Détection d'incidents
    - Analyse et containment
    - Eradication
    - Recovery

## 🧪 Labs Disponibles

1. **🕸️ web-basics** - Lab Sécurité Web de Base
   - Application web vulnérable
   - Pratique XSS, SQLi
   - Difficulté: ⭐⭐

2. **🌐 network-scan** - Lab Scan Réseau
   - Environnement réseau isolé
   - Pratique nmap, wireshark
   - Difficulté: ⭐⭐

3. **🔐 crypto-basics** - Lab Cryptographie
   - Exercices de chiffrement
   - Pratique GPG, OpenSSL
   - Difficulté: ⭐⭐⭐

4. **🐧 linux-pentest** - Lab Pentest Linux
   - Machine Linux vulnérable
   - Pratique exploitation
   - Difficulté: ⭐⭐⭐⭐

5. **🔍 forensics-basic** - Lab Forensique
   - Images disque à analyser
   - Pratique forensique
   - Difficulté: ⭐⭐⭐

## 📊 Progression

Votre progression est sauvegardée dans `~/.cyberlearn/progress.json` :

```json
{
  "started_at": "2024-01-15T10:30:00Z",
  "modules": {
    "basics": {
      "status": "completed",
      "completed_at": "2024-01-15T12:00:00Z"
    }
  },
  "labs": {},
  "badges": ["basics-completed"],
  "stats": {
    "modules_completed": 1,
    "labs_completed": 0
  }
}
```

## 🏆 Badges

Obtenez des badges en complétant les modules et labs :

- 🎯 `basics-completed` - Module Basics complété
- 🌐 `network-completed` - Module Network complété
- 🕸️ `web-completed` - Module Web complété
- 🧪 `lab-master` - 5 labs complétés
- 🏆 `cyber-expert` - Tous les modules complétés

## 🐳 Pré-requis

### Docker (pour les labs)

```bash
# Installer Docker
installman docker

# Vérifier que Docker fonctionne
docker info
```

### Outils Recommandés

```bash
# Outils de base
installman network-tools  # nmap, wireshark, etc.

# Outils de cybersécurité (via cyberman)
cyberman  # Menu pour installer les outils
```

### jq (pour les statistiques)

```bash
# Arch/Manjaro
sudo pacman -S jq

# Debian/Ubuntu
sudo apt install jq

# Fedora
sudo dnf install jq
```

## 📁 Structure

```
cyberlearn/
├── modules/           # Modules de cours
│   ├── basics/
│   ├── network/
│   └── ...
├── labs/              # Configurations Docker pour labs
├── utils/             # Utilitaires
│   ├── progress.sh    # Gestion de progression
│   ├── labs.sh        # Gestion des labs
│   └── validator.sh   # Validation des exercices
└── README.md
```

## 🔧 Développement

### Ajouter un Nouveau Module

1. Créer le répertoire : `modules/nom-module/`
2. Créer `module.zsh` avec la fonction `run_module()`
3. Ajouter les leçons et exercices

### Ajouter un Nouveau Lab

1. Créer le Dockerfile dans `labs/nom-lab/`
2. Ajouter la fonction `start_nom_lab()` dans `utils/labs.sh`
3. Documenter le lab dans le README

## 💡 Exemples

### Compléter le Module Basics

```bash
cyberlearn start-module basics
# Suivre les leçons et exercices
# Le module sera marqué comme complété automatiquement
```

### Démarrer un Lab Web

```bash
cyberlearn lab start web-basics
# Le lab démarre sur http://localhost:8080
# Pratiquez les exercices
cyberlearn lab stop web-basics
```

### Voir sa Progression

```bash
cyberlearn progress
# Affiche les statistiques détaillées
```

## 🎓 Ressources Complémentaires

- **cyberman** : Outils de cybersécurité pratiques
- **TryHackMe** : Plateforme en ligne (complémentaire)
- **HackTheBox** : Labs avancés (complémentaire)
- **OWASP** : Documentation sécurité web

## 📝 Notes

- La progression est sauvegardée localement dans `~/.cyberlearn/`
- Les labs Docker sont isolés et sûrs
- Tous les exercices sont pratiques et interactifs
- Le système s'intègre avec `cyberman` pour les outils

## 🚧 Roadmap

- [ ] Compléter tous les modules (actuellement: basics)
- [ ] Ajouter plus de labs Docker
- [ ] Système de challenges quotidiens
- [ ] Mode compétition/multi-joueurs
- [ ] Export de certificats PDF
- [ ] Intégration avec TryHackMe API
- [ ] Versions Bash et Fish

---

**Auteur**: Paul Delhomme  
**Version**: 1.0  
**Licence**: MIT

