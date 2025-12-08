# Module Extract - Extraction d'archives avec progression

## Description

Module pour extraire des archives avec une barre de progression en CLI propre, similaire aux autres managers.

## Fonctionnalités

- ✅ **Barre de progression** : Affichage visuel de la progression (si `pv` installé ou barre simple)
- ✅ **Multi-formats** : Support de tous les formats d'archives courants
- ✅ **Interface CLI propre** : Design cohérent avec les autres managers
- ✅ **Statistiques** : Taille, durée, vitesse
- ✅ **Liste contenu** : Voir le contenu sans extraire
- ✅ **Destination personnalisable** : Extraire où vous voulez

## Formats supportés

- **Tar** : `.tar`, `.tar.gz`, `.tar.bz2`, `.tar.xz`, `.tgz`, `.tbz2`, `.txz`
- **Zip** : `.zip`
- **Rar** : `.rar`
- **7z** : `.7z`
- **Compression simple** : `.gz`, `.bz2`, `.xz`, `.Z`, `.lzma`
- **Paquets** : `.deb`, `.rpm`

## Utilisation

### Via le menu interactif

```bash
multimediaman
# Puis sélectionner l'option 2 (Extraire une archive)
```

### Via la ligne de commande

```bash
# Extraction simple (dans le répertoire courant)
multimediaman extract archive.zip

# Extraction vers un répertoire spécifique
multimediaman extract archive.tar.gz /tmp/extract

# Lister le contenu sans extraire
multimediaman list archive.zip
```

### Alias disponibles

```bash
mm-extract archive.zip          # Alias pour extract
mm-list archive.zip             # Alias pour list
```

## Barre de progression

Le module affiche une barre de progression pour les archives ZIP :
- Compte le nombre total de fichiers
- Affiche la progression en temps réel
- Format : `[████████░░░░░░░░] 50%`

Pour les autres formats (tar, etc.), utilise `pv` si disponible pour la progression, sinon affiche un message simple.

## Exemples

```bash
# Extraction simple
multimediaman extract backup.tar.gz

# Extraction vers un dossier spécifique
multimediaman extract archive.zip ~/Documents/extracted

# Voir le contenu avant d'extraire
multimediaman list archive.zip

# Via alias
mm-extract archive.tar.gz
mm-list archive.rar
```

## Pré-requis

- **unzip** : Pour les archives ZIP (généralement installé)
- **unrar** ou **rar** : Pour les archives RAR
- **7z** : Pour les archives 7z
- **pv** (optionnel) : Pour la progression avancée sur tar/gz/bz2/xz

Installation des outils manquants :
```bash
# Arch/Manjaro
sudo pacman -S unzip unrar p7zip pv

# Debian/Ubuntu
sudo apt install unzip unrar p7zip-full pv
```

## Interface

L'interface suit le même design que les autres managers :
- Header avec bordures
- Couleurs cohérentes (CYAN, GREEN, YELLOW, RED)
- Messages clairs et informatifs
- Statistiques (taille, durée)

