# Modules FILEMAN

Ce répertoire contient les modules du gestionnaire de fichiers FILEMAN.

## Structure

```
modules/
├── archive/          # Gestion des archives (création, extraction)
├── backup/           # Gestion des sauvegardes
├── files/            # Opérations sur fichiers (copier, déplacer, supprimer)
├── permissions/      # Gestion des permissions
└── search/           # Recherche de fichiers
```

## Modules disponibles

### archive/
Gestion complète des archives :
- Extraction d'archives (tar, zip, rar, 7z, etc.)
- Création d'archives
- Liste du contenu
- Vérification d'intégrité

### backup/
Gestion des sauvegardes :
- Création de sauvegardes
- Liste des sauvegardes
- Restauration de sauvegardes
- Suppression de sauvegardes

### files/
Opérations sur fichiers :
- Copier un fichier/répertoire
- Déplacer un fichier/répertoire
- Supprimer un fichier/répertoire
- Renommer un fichier/répertoire
- Créer un répertoire
- Afficher les informations d'un fichier

### permissions/
Gestion des permissions :
- Changer les permissions
- Afficher les permissions
- Appliquer des permissions par défaut
- Rechercher des fichiers avec permissions spécifiques

### search/
Recherche de fichiers :
- Recherche par nom
- Recherche par contenu
- Recherche par taille
- Recherche par date de modification

