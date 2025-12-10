# Module OSINT avec IA - Cyberman

Ce module intègre les meilleurs outils OSINT (Open Source Intelligence) avec intelligence artificielle pour cyberman.

## Outils intégrés

### Outils OSINT avec IA

1. **Taranis AI** - OSINT avancé avec NLP et IA
   - Reconnaissance d'entités nommées (NER)
   - Génération automatique de résumés
   - Détection de termes cybersécurité
   - Analyse de sentiment

2. **Robin** - Investigation dark web avec IA
   - Support GPT-4.1
   - Recherche automatique sur moteurs dark web
   - Génération de résumés d'investigation

3. **GoSearch** - Recherche d'empreintes numériques
   - Découverte d'empreintes liées à des usernames
   - Intégration Cybercrime Database
   - Plus rapide que Sherlock

4. **DarkGPT** - Assistant OSINT basé sur GPT-4
   - Requêtes sur bases de données compromises
   - Intégration DeHashed API

5. **OSINT with LLM** - Reconnaissance automatisée avec LLM locaux
   - Utilise Ollama pour exécution locale
   - Reconnaissance multi-types automatisée

### Outils OSINT traditionnels

6. **SpiderFoot** - Collecte OSINT automatisée
   - 200+ modules de collecte
   - Interface web
   - Intégration VirusTotal, Shodan

7. **Recon-ng** - Framework de reconnaissance web
   - Modules modulaires
   - Automatisation de collecte

8. **Sherlock** - Recherche username sur réseaux sociaux
   - 300+ plateformes supportées

9. **TheHarvester** - Collecte d'informations
   - Emails, sous-domaines, IPs
   - Multiples sources

## Installation

Les outils sont installés automatiquement via `ensure_tool` ou via le menu d'installation OSINT dans cyberman.

## Utilisation

Accédez au menu OSINT via :
```
cyberman
→ Option: OSINT Tools
```

## Configuration

Certains outils nécessitent des clés API (optionnelles) :
- DeHashed API (pour DarkGPT)
- Shodan API (pour SpiderFoot)
- VirusTotal API (pour SpiderFoot)

Les clés peuvent être configurées dans `~/.cyberman/config/osint.conf`

