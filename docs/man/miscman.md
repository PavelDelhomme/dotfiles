# MISCMAN(1) - Gestionnaire d'outils divers

## NOM

miscman - Gestionnaire interactif complet pour les outils divers et utilitaires système

## SYNOPSIS

**miscman** [*command*]

## DESCRIPTION

MISCMAN est un gestionnaire interactif complet pour les outils divers et utilitaires
système. Il inclut des fonctionnalités pour la génération de mots de passe, les
informations système, les sauvegardes, l'extraction d'archives, le chiffrement et
le nettoyage.

Le gestionnaire offre les fonctionnalités suivantes :
- Génération de mots de passe sécurisés
- Informations système complètes
- Copie avancée avec barre de progression
- Sauvegardes automatisées
- Extraction d'archives multiformats
- Chiffrement/déchiffrement GPG
- Gestion du presse-papier
- Nettoyage système intelligent

## OPTIONS

Sans argument, lance le menu interactif principal.

**command** peut être :
- **genpass** [*length*] - Générer un mot de passe
- **sysinfo** - Afficher les informations système
- **cleanup** - Nettoyer le système

## EXEMPLES

Lancer le gestionnaire interactif :
```
$ miscman
```

Générer un mot de passe de 20 caractères :
```
$ miscman genpass 20
```

Afficher les informations système :
```
$ miscman sysinfo
```

Nettoyer le système :
```
$ miscman cleanup
```

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **extract**(1) - Extraction d'archives
- **gen_password**(1) - Génération de mots de passe

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

