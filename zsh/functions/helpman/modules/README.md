# Modules Helpman

Ce répertoire contient les modules du gestionnaire d'aide.

## Modules disponibles

- `help_system.sh` : Système d'aide principal (extraction de documentation, pages man, etc.)

## Structure

```
helpman/
├── core/
│   └── helpman.zsh          # Script principal
├── modules/
│   └── help_system.sh       # Module système d'aide
├── utils/
│   ├── list_functions.py    # Utilitaire liste fonctions
│   └── markdown_viewer.py   # Utilitaire visualisation Markdown
├── config/
│   └── helpman.conf         # Configuration
└── install/
    └── (scripts d'installation si nécessaire)
```

