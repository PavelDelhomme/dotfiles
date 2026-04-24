# Vision — `installman` comme outil d’installation trans-distro

Document de **cadrage** (épique). Rien ici n’oblige une implémentation immédiate ; le découpage en phases ira dans `TODOS.md` au fil du travail.

## Objectif

Disposer d’un **`installman`** pensé comme un **outil de niveau « gestionnaire de paquets »** pour l’utilisateur : détection de la plateforme, recherche, proposition des **moyens d’installation disponibles** sur *cette* machine, choix (menu / fuzzy), exécution avec **validation explicite** à chaque étape sensible, et intégration bureau lorsque c’est pertinent.

## Non-objectifs implicites (à garder en tête)

- Ne pas remplacer `pacman` / `apt` / `dnf` en contournant leurs règles de sécurité.
- Ne pas promettre l’impossible (ex. installer un **.rpm natif** comme sur Fedora **sur Arch** sans conteneur ou conversion : il faut **expliquer**, proposer **alternative** — Flatpak, AppImage, build AUR, `distrobox`, etc.).

## Backends / familles de distributions (cible)

| Famille | Mécanismes à modéliser (détection + ordre de préférence configurable) |
|---------|------------------------------------------------------------------------|
| **Debian / Ubuntu** | `apt`, paquets `.deb`, dépôts tiers, **PPA** (où applicable) |
| **Red Hat / Fedora-like** | `yum` / **`dnf`**, `.rpm`, dépôts officiels, **EPEL**, éventuellement Rawhide |
| **Arch** | **`pacman`** (core / extra / community), **AUR** via **`yay`** ou **`paru`** (détection de ce qui est installé) |
| **Gentoo** | **Portage**, ebuilds, overlays officiels |
| **Slackware** | `.tgz`, `slackpkg`, dépôts tiers, SlackBuilds |
| **SUSE / openSUSE** | **`zypper`**, dépôts OSS / Non-OSS / Update, **OBS** |
| **Universels** | **Flatpak**, **Snap**, **AppImage**, **Nix** |

## Formats « universels » (priorité utilisateur)

- L’utilisateur veut pouvoir **orienter** le canal (ex. *« je veux diagrams.net en Flatpak par défaut »*).
- Règles souhaitées : **profil par paquet** ou **profil global** (ex. préférer Flatpak > dépôt distro > AUR > AppImage), toujours avec **fallback** si le canal n’existe pas sur la distro courante.

## UX souhaitée

| Besoin | Comportement cible |
|--------|---------------------|
| **Recherche** | `installman search …` / `installman search google chrome` : agrégation des résultats possibles (nom, source, version si connue) |
| **Installation ciblée** | Ex. `installman google-chrome` : menu (fzf / équivalent) listant **AUR**, Flatpak, `.deb` hébergé, etc., selon ce qui est **réellement utilisable** sur la machine |
| **Alias** | Ex. **`in`** → `installman` (à définir dans les dotfiles / adapters shells) |
| **Étapes automatiques** | Enchaînements possibles **mais** avec **validation utilisateur** à chaque étape critique (téléchargement, `sudo`, modification de dépôts, etc.) |
| **Man / doc** | Besoin exprimé : pouvoir installer ou vérifier la doc système (ex. **`man`**) via un flux `installman` — lien avec paquet `man-db` sur Arch, etc. Voir aussi `docs/TROUBLESHOOTING_MAN_GIT.md` pour le cas `git help` |

## Intégration post-installation (bureau)

Pour Flatpak, Snap, AppImage, binaires « Linux génériques » :

- Création ou mise à jour de **fichiers `.desktop`** (raccourci bureau + entrée dans le **menu applications**), en respectant XDG (`~/.local/share/applications`, etc.).
- Adapter au **DE** présent (KDE, GNOME, XFCE, …) dans la mesure du raisonnable (détection + chemins standards).

## Détection & transparence

- **Détecter** : famille distro, présence de `flatpak`, `snap`, `yay`/`paru`, droits `sudo`, etc.
- **Indiquer clairement** : « sur Arch, pas d’installation `.rpm` native ; options : … »
- **Versions** : quand l’API le permet, afficher la version disponible par canal.

## Architecture logicielle (direction)

1. **Couche « capacités »** : quels backends sont disponibles sur *ce* système.
2. **Couche « résolution »** : pour un logiciel demandé, quels canaux existent (base de données interne + plugins + recherche distante si un jour prévu).
3. **Couche « UI »** : menus existants (`installman`), fuzzy (`fzf` si présent), confirmations.
4. **Couche « exécution »** : scripts par famille déjà présents sous `zsh/functions/installman/modules/` (à faire converger avec `core/managers/installman/` sur le long terme — voir `TODOS.md`).

## Phases d’implémentation suggérées

1. **P0 — Hygiène** : documenter et tester l’installation de **`man-db`** / pages man sur Arch (débloque `git help`). *(Hors installman ou mini-module « base-devel / doc ».)*
2. **P1 — Matrice** : tableau machine → backends disponibles (read-only, affichage `installman doctor` ou équivalent).
3. **P2 — Recherche** : `installman search` unifié pour 1–2 backends (ex. `pacman` + `flatpak`).
4. **P3 — Install ciblé** : un paquet pilote (ex. navigateur) avec menu de canaux + confirmations.
5. **P4 — Universels + .desktop** : règles Flatpak/AppImage + génération `.desktop`.
6. **P5 — Extension** : autres familles (dnf, zypper, etc.) par modules.

## Références dans le dépôt

- Rapport multi-shell / entrée : `docs/MULTISHELL_REPORT.md`
- Modules existants : `zsh/functions/installman/modules/`
- Core / entry : `core/managers/installman/`

---

*Dernière mise à jour : document créé pour cadrer la demande utilisateur (épique installman trans-distro).*
