> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

# CYBERMAN - Documentation des Workflows

> Mise à jour 2026-05 : document conservé, à recaler progressivement lors de la modularisation complète des managers sous `core/managers/*`.

## 📋 Qu'est-ce qu'un Workflow ?

Un **workflow** (flux de travail) dans `cyberman` est une **séquence automatisée d'actions** de tests de sécurité que vous pouvez créer, sauvegarder et exécuter à plusieurs reprises.

### Caractéristiques principales :

- ✅ **Séquences réutilisables** : Créez une fois, exécutez plusieurs fois
- ✅ **Actions automatisées** : Exécutez plusieurs tests en une seule commande
- ✅ **Indépendants des environnements** : Les workflows sont stockés séparément et peuvent être utilisés avec n'importe quel environnement
- ✅ **Rapports automatiques** : Chaque exécution génère un rapport détaillé

## 🔄 Relation entre Workflows et Environnements

### Workflows ≠ Environnements

Les workflows et les environnements sont **deux concepts distincts** :

| Concept | Stockage | Contenu | Usage |
|---------|----------|---------|-------|
| **Environnement** | `~/.cyberman/environments/` | Cibles, notes, historique, résultats, TODOs | Contexte de test (cibles, documentation) |
| **Workflow** | `~/.cyberman/workflows/` | Séquences d'actions (scans, tests) | Actions automatisées à exécuter |

### Comment ils fonctionnent ensemble :

1. **Créer un environnement** : Définissez vos cibles et contexte de test
   ```bash
   cyberman
   # Option 1 > Gestion & Configuration > Environnements > Création & Gestion
   ```

2. **Créer un workflow** : Définissez la séquence d'actions à exécuter
   ```bash
   cyberman
   # Option 1 > Gestion & Configuration > Workflows
   ```

3. **Exécuter un workflow avec un environnement** :
   - Le workflow utilise les **cibles** de l'environnement actif
   - Les **résultats** sont automatiquement sauvegardés dans l'environnement
   - Un **rapport** est généré pour chaque exécution

## 📝 Structure d'un Workflow

Un workflow est un fichier JSON contenant :

```json
{
  "name": "full_pentest",
  "description": "Test de pénétration complet",
  "created": "2024-01-15T10:30:00Z",
  "steps": [
    {
      "type": "recon",
      "function": "domain_whois",
      "args": "",
      "timestamp": 1705312200
    },
    {
      "type": "scan",
      "function": "port_scan",
      "args": "-sV -sC",
      "timestamp": 1705312201
    },
    {
      "type": "vuln",
      "function": "nmap_vuln_scan",
      "args": "--script vuln",
      "timestamp": 1705312202
    }
  ]
}
```

### Types d'étapes disponibles :

- `recon` : Reconnaissance et information gathering
- `scan` : Scanning et énumération
- `vuln` : Vulnerability assessment
- `attack` : Attaques réseau
- `analysis` : Analyse et monitoring

## 🚀 Utilisation Pratique

### Exemple complet :

1. **Créer un environnement** :
   ```bash
   cyberman
   # 1. Gestion & Configuration
   #    1. Environnements
   #       1. Création & Gestion
   #          1. Créer un nouvel environnement
   # Nom: pentest_example_com
   # Cibles: example.com 192.168.1.1
   ```

2. **Créer un workflow** :
   ```bash
   cyberman
   # 1. Gestion & Configuration
   #    3. Workflows
   #       1. Créer un nouveau workflow
   # Nom: basic_recon
   # Ajouter des étapes:
   #   - Type: recon, Fonction: domain_whois
   #   - Type: scan, Fonction: port_scan
   #   - Type: vuln, Fonction: nmap_vuln_scan
   ```

3. **Exécuter le workflow** :
   ```bash
   cyberman
   # 1. Gestion & Configuration
   #    3. Workflows
   #       3. Exécuter un workflow
   # Workflow: basic_recon
   # Environnement: pentest_example_com (optionnel, utilise l'actif si non spécifié)
   ```

4. **Consulter les résultats** :
   ```bash
   cyberman
   # 1. Gestion & Configuration
   #    1. Environnements
   #       2. Informations & Documentation
   #          5. Voir tous les résultats de tests
   ```

## 💡 Bonnes Pratiques

### Organisation des Workflows

- **Nommage clair** : Utilisez des noms descriptifs (`web_app_scan`, `network_pentest`)
- **Workflows modulaires** : Créez des workflows spécialisés plutôt qu'un seul workflow énorme
- **Documentation** : Ajoutez des descriptions claires pour chaque workflow

### Organisation des Environnements

- **Un environnement par projet/client** : Séparer les contextes de test
- **Notes détaillées** : Documentez vos découvertes dans les notes
- **TODOs** : Utilisez les TODOs pour suivre les actions à effectuer
- **Historique** : Consultez l'historique pour voir toutes les actions effectuées

### Workflow vs Actions Manuelles

- **Workflows** : Pour des séquences répétitives et automatisées
- **Actions manuelles** : Pour des tests ponctuels ou exploratoires

## 🔍 Commandes Rapides

```bash
# Accès direct aux menus
cyberman manage          # Menu de gestion complet
cyberman env            # Menu des environnements
cyberman workflow        # Menu des workflows

# Depuis le menu principal
cyberman
# Option 1 : Gestion & Configuration
```

## 📊 Rapports

Chaque exécution de workflow génère automatiquement un rapport dans `~/.cyberman/reports/` contenant :

- ✅ Workflow exécuté
- ✅ Environnement utilisé
- ✅ Cibles testées
- ✅ Résultats de chaque étape
- ✅ Timestamps
- ✅ Statuts (success/warning/error)

Les rapports peuvent être :
- Consultés via le menu "Gestion des rapports"
- Exportés en format texte
- Sauvegardés dans l'environnement pour référence future

## ❓ FAQ

**Q : Les workflows sont-ils sauvegardés dans les environnements ?**

R : Non, les workflows sont stockés **séparément** dans `~/.cyberman/workflows/`. Ils peuvent être utilisés avec n'importe quel environnement.

**Q : Puis-je exécuter un workflow sans environnement ?**

R : Oui, mais vous devez avoir des cibles configurées. Le workflow utilisera les cibles actives.

**Q : Les résultats sont-ils sauvegardés dans l'environnement ?**

R : Oui, si un environnement est actif lors de l'exécution, les résultats sont automatiquement ajoutés à l'environnement.

**Q : Puis-je modifier un workflow après l'avoir créé ?**

R : Oui, vous pouvez ajouter des étapes à un workflow existant via le menu de gestion des workflows.

**Q : Comment partager un workflow avec d'autres ?**

R : Les workflows sont des fichiers JSON dans `~/.cyberman/workflows/`. Vous pouvez les copier ou les exporter/importer.

