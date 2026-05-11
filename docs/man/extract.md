> **Hub doc** : [`../INDEX.md`](../INDEX.md) · **Carte technique** : [`../STRUCTURE.md`](../STRUCTURE.md) · **Tests** : [`../TESTS.md`](../TESTS.md) · **Erreurs** : [`../ERRORS.md`](../ERRORS.md) · **Statut** : [`STATUS.md`](../../STATUS.md) · **Tâches** : [`TODOS.md`](../../TODOS.md)

# EXTRACT(1) - Manuel d'extraction d'archives

> Mise à jour 2026-05 : document revu dans la trajectoire plateforme unifiée (voir `docs/platform/UNIFIED_PLATFORM_ROADMAP.md`).

## NOM

extract - Extrait automatiquement des fichiers d'archive

## SYNOPSIS

**extract** [*fichier_archive*] [**--help**|**-h**|**help**]

## DESCRIPTION

La commande **extract** est une fonction utilitaire qui extrait automatiquement
n'importe quel type d'archive dans le répertoire courant. Elle détecte
automatiquement le format de l'archive en fonction de son extension et utilise
l'outil approprié pour l'extraction.

Cette fonction supporte une large gamme de formats d'archives courants, des
archives tar compressées aux paquets Debian/RPM, en passant par les formats
zip, rar et 7z.

## FORMATS SUPPORTÉS

### Archives tar
- **.tar** - Archive tar non compressée
- **.tar.gz**, **.tgz** - Archive tar compressée avec gzip
- **.tar.bz2**, **.tbz2** - Archive tar compressée avec bzip2
- **.tar.xz**, **.txz** - Archive tar compressée avec xz

### Archives compressées simples
- **.gz** - Fichier compressé avec gzip
- **.bz2** - Fichier compressé avec bzip2
- **.xz** - Fichier compressé avec xz
- **.lzma** - Fichier compressé avec lzma
- **.Z** - Fichier compressé avec compress (Unix)

### Archives multi-fichiers
- **.zip** - Archive ZIP (nécessite unzip)
- **.rar** - Archive RAR (nécessite unrar ou rar)
- **.7z** - Archive 7-Zip (nécessite 7z/p7zip)

### Paquets système
- **.deb** - Paquet Debian (nécessite ar)
- **.rpm** - Paquet Red Hat (nécessite rpm2cpio et cpio)
- **.cpio** - Archive cpio

## OPTIONS

- **--help**, **-h**, **help**
  Affiche l'aide de la commande et quitte.

## ARGUMENTS

*fichier_archive*
  Le chemin vers le fichier d'archive à extraire. Si aucun argument n'est
  fourni, l'aide est affichée.

## EXEMPLES

Extraire une archive ZIP :
```
$ extract mon_archive.zip
📦 Extraction de: mon_archive.zip
🔧 Format détecté: zip
✅ Extraction terminée avec succès
```

Extraire une archive tar.gz :
```
$ extract backup.tar.gz
📦 Extraction de: backup.tar.gz
🔧 Format détecté: tar.gz
✅ Extraction terminée avec succès
```

Extraire un paquet Debian :
```
$ extract package.deb
📦 Extraction de: package.deb
🔧 Format détecté: Debian package
✅ Extraction terminée avec succès
```

Afficher l'aide :
```
$ extract
# ou
$ extract --help
```

## COMPORTEMENT

- L'extraction se fait **dans le répertoire courant** où la commande est exécutée.
- Les fichiers sont extraits avec leurs **permissions d'origine**.
- Si le fichier spécifié n'existe pas, un message d'erreur est affiché avec
  des suggestions pour obtenir de l'aide.
- Si le format n'est pas supporté, la liste des formats supportés est affichée.

## PRÉREQUIS

Certains formats nécessitent des outils supplémentaires :

- **zip** : nécessite `unzip`
- **rar** : nécessite `unrar` ou `rar`
- **7z** : nécessite `7z` (paquet `p7zip` sur Arch Linux)
- **deb** : nécessite `ar` (généralement installé par défaut)
- **rpm** : nécessite `rpm2cpio` et `cpio`

## INSTALLATION DES OUTILS MANQUANTS

### Arch Linux / Manjaro
```bash
sudo pacman -S unzip unrar p7zip
```

### Debian / Ubuntu
```bash
sudo apt install unzip unrar p7zip-full
```

### Fedora
```bash
sudo dnf install unzip unrar p7zip
```

## CODES DE RETOUR

- **0** : Extraction réussie
- **1** : Erreur (fichier introuvable, format non supporté, outil manquant)

## VOIR AUSSI

- **help**(1) - Système d'aide pour les fonctions personnalisées
- **man**(1) - Pages de manuel système
- **tar**(1) - Création et extraction d'archives tar
- **unzip**(1) - Extraction d'archives ZIP
- **unrar**(1) - Extraction d'archives RAR
- **7z**(1) - Extraction d'archives 7-Zip

## AUTEUR

Paul Delhomme - Système de dotfiles personnalisé

## BUGS

Signalez les bugs ou suggestions d'amélioration via le dépôt GitHub du projet.

## LICENCE

Ce script fait partie d'un système de dotfiles personnel et est fourni tel quel.

