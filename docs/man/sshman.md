# SSMAN(1) - Gestionnaire SSH

## NOM

sshman - Gestionnaire interactif complet pour la gestion SSH (connexions, clés, configurations)

## SYNOPSIS

**sshman** [*command*]

## DESCRIPTION

SSMAN est un gestionnaire interactif complet pour la gestion SSH. Il permet de gérer les connexions SSH, les clés SSH, et de configurer automatiquement des connexions avec mot de passe depuis `.env`.

Le gestionnaire offre les fonctionnalités suivantes :
- Configuration automatique SSH avec mot de passe depuis `.env`
- Liste des connexions SSH configurées
- Test de connexions SSH
- Gestion des clés SSH (génération, affichage, copie, suppression)
- Statistiques SSH et vérification des permissions

## OPTIONS

Sans argument, lance le menu interactif principal.

**command** peut être :
- **auto-setup** - Configuration automatique SSH (avec mot de passe .env)
- **list** - Liste des connexions SSH configurées
- **test** - Test de connexion SSH
- **keys** - Gestion des clés SSH
- **stats** - Statistiques SSH

## EXEMPLES

Lancer le gestionnaire interactif :
```
$ sshman
```

Configuration automatique SSH :
```
$ sshman auto-setup
```

Liste des connexions SSH :
```
$ sshman list
```

Test de connexion :
```
$ sshman test
```

Gestion des clés SSH :
```
$ sshman keys
```

Statistiques SSH :
```
$ sshman stats
```

## CONFIGURATION VIA .ENV

Le gestionnaire utilise les variables d'environnement depuis `~/dotfiles/.env` :

```bash
SSH_HOST_NAME="pavel-server"
SSH_HOST="95.111.227.204"
SSH_USER="pavel"
SSH_PORT="22"
SSH_PASSWORD="votre_mot_de_passe"
```

Ces valeurs seront demandées lors de la première configuration si elles ne sont pas définies.

## UTILISATION MANUELLE

La fonction `ssh_auto_setup` peut également être appelée directement :

```bash
ssh_auto_setup [host_name] [host_ip] [user] [port]

# Exemple
ssh_auto_setup pavel-server 95.111.227.204 pavel 22
```

## ALIAS

- **sm** - Alias pour sshman

## FONCTIONNALITÉS

### Configuration automatique

La configuration automatique SSH permet de :
- Générer ou récupérer une clé SSH ED25519
- Configurer `~/.ssh/config` avec l'alias de connexion
- Copier la clé publique sur le serveur avec le mot de passe
- Tester la connexion SSH

### Gestion des clés SSH

- Génération automatique de clés SSH ED25519
- Affichage des clés publiques
- Copie dans le presse-papiers
- Suppression de clés

### Statistiques

Affiche :
- Nombre de hosts configurés
- Nombre de clés privées/publiques
- Vérification des permissions (`~/.ssh` doit être 700, `~/.ssh/config` doit être 600)

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **ssh**(1) - Client SSH
- **ssh_config**(5) - Fichier de configuration SSH
- **configman**(1) - Gestionnaire de configurations (inclus SSH)

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

