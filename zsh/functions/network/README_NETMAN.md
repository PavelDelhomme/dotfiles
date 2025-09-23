# NETMAN - Network Manager pour ZSH

## Description
NETMAN est un gestionnaire réseau complet et interactif pour ZSH, offrant une interface unifiée pour gérer les ports, les connexions et les informations réseau.

## Installation
Le script a été automatiquement installé dans votre configuration ZSH.

## Utilisation

### Commande principale
```bash
netman    # ou nm pour le raccourci
```

### Commandes rapides
```bash
netman ports              # Accès direct à la gestion des ports
netman kill <port>        # Kill rapide d'un port
netman scan <host> [port] # Scan rapide d'un host
netman stats              # Statistiques réseau directes
```

### Alias disponibles
- `nm` : Raccourci pour `netman`
- `ports` : Accès direct aux ports
- `kill-port` : Kill rapide d'un port

## Fonctionnalités

### 1. Gestion des ports (Option 1)
- Interface interactive avec sélection multiple
- Visualisation en temps réel des ports en écoute
- Kill de processus sélectionnés
- Informations détaillées sur les ports

### 2. Connexions actives (Option 2)
- Affichage des connexions ESTABLISHED
- Connexions TIME_WAIT et CLOSE_WAIT
- Statistiques par protocole

### 3. Informations IP (Option 3)
- IP publique avec géolocalisation
- IPs locales par interface
- Adresses IPv6

### 4. Configuration DNS (Option 4)
- Serveurs DNS configurés
- Test de résolution
- Cache DNS local

### 5. Table de routage (Option 5)
- Routes IPv4 et IPv6
- Passerelle par défaut
- Métriques des interfaces

### 6. Interfaces réseau (Option 6)
- État et configuration
- Adresses MAC
- Statistiques de trafic

### 7. Scanner de ports (Option 7)
- Scan de ports uniques ou plages
- Support hosts locaux et distants
- Détection de services

### 8. Kill rapide (Option 8)
- Termination rapide par numéro de port
- Confirmation avant action

### 9. Statistiques réseau (Option 9)
- Statistiques globales
- Top connexions par IP
- Bande passante en temps réel

### 10. Export (Option 0)
- Export complet de la configuration
- Sauvegarde horodatée

## Interface interactive

### Dans le menu de gestion des ports :
- **[1-9]** : Sélectionner/désélectionner un port
- **[k]** : Kill les processus sélectionnés
- **[i]** : Informations détaillées
- **[a]** : Sélectionner tout
- **[n]** : Désélectionner tout
- **[r]** : Rafraîchir
- **[q]** : Quitter

## Permissions
Certaines fonctionnalités nécessitent `sudo` pour fonctionner correctement :
- Visualisation complète des ports
- Kill de processus système
- Accès aux statistiques détaillées

## Troubleshooting

### Si NETMAN ne se charge pas :
```bash
source ~/.zshrc
```

### Pour vérifier l'installation :
```bash
type netman
```

### Logs et debug :
Les anciennes fonctions ont été sauvegardées dans :
`~/dotfiles/zsh/functions/network/backup_[timestamp]/`

## Personnalisation
Vous pouvez modifier les couleurs et le comportement en éditant :
`~/dotfiles/zsh/functions/network/netman.zsh`

## Auteur
Paul Delhomme

## Version
1.0 - Version initiale avec toutes les fonctionnalités réseau unifiées
