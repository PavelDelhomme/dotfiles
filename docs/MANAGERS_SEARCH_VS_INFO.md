# `searchman` vs un futur **`infosman`**

## Rôle actuel de **`searchman`**

Le core POSIX (`core/managers/searchman/core/searchman.sh`) est centré sur la **recherche et l’exploration** : historique de commandes, fichiers, flux interactifs avec menus. Ce n’est **pas** un équivalent de « fiche d’information » sur un paquet, une binaire système, ou les canaux d’installation disponibles.

## **`helpman`**

Aide liée aux dotfiles / managers / usage — autre périmètre que « info paquet / info outil système ».

## **`infosman`** (hypothétique)

Pourrait regrouper des **fiches structurées** du type :

- où est installé X, quelle version, quel backend ;
- résumé pour l’utilisateur avant une action `installman` ;
- métadonnées sans lancer un menu de recherche générique.

**Décision à trancher** (voir `TODOS.md`, phase A) :

1. **Étendre** `searchman` avec une sous-commande du style `searchman info <sujet>` (si on veut un seul outil « recherche + info »), ou  
2. **Créer** `infosman` si le périmètre et les dépendances divergent trop de `searchman`.

Tant que la décision n’est pas écrite dans `docs/ARCHITECTURE.md` + une issue / case `TODOS`, éviter de dupliquer de la logique entre les deux.
