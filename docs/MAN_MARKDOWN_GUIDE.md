# 📚 Guide : Affichage des pages man en Markdown

## 🔍 Problème

La commande `man` système ne supporte pas nativement le format Markdown (`.md`). Les pages man système utilisent le format groff/troff.

## ✅ Solutions disponibles

### Option 1 : bat (Recommandé) ⭐

**Avantages** :
- Coloration syntaxique native pour Markdown
- Support complet du format Markdown
- Rapide et léger
- Installation simple

**Installation** :
```bash
# Arch Linux
yay -S bat
# ou
sudo pacman -S bat

# Debian/Ubuntu
sudo apt-get install bat

# Fedora
sudo dnf install bat
```

**Utilisation** : La fonction `man()` l'utilisera automatiquement s'il est installé.

---

### Option 2 : pandoc + groff (Format man système)

**Avantages** :
- Convertit Markdown en format man système
- Utilise `groff` comme le man système
- Expérience identique aux pages man système

**Installation** :
```bash
# Arch Linux
sudo pacman -S pandoc groff

# Debian/Ubuntu
sudo apt-get install pandoc groff

# Fedora
sudo dnf install pandoc groff
```

**Utilisation** : Conversion automatique lors de l'affichage.

---

### Option 3 : glow

**Avantages** :
- Visualiseur Markdown interactif
- Interface élégante
- Support complet Markdown

**Installation** :
```bash
# Arch Linux (AUR)
yay -S glow

# Autres distributions
# Voir: https://github.com/charmbracelet/glow
```

---

### Option 4 : mdcat

**Avantages** :
- Visualiseur Markdown en terminal
- Coloration automatique
- Support des tableaux et listes

**Installation** :
```bash
# Arch Linux (AUR)
yay -S mdcat

# Autres distributions
cargo install mdcat
```

---

### Option 5 : pygmentize (Coloration pour less)

**Avantages** :
- Coloration syntaxique pour less
- Compatible avec less
- Léger

**Installation** :
```bash
# Arch Linux
sudo pacman -S python-pygments

# Debian/Ubuntu
sudo apt-get install python3-pygments

# Fedora
sudo dnf install python3-pygments
```

---

## 🚀 Installation automatique

Un script d'installation est disponible :

```bash
bash ~/dotfiles/scripts/tools/install_markdown_viewers.sh
```

Ce script :
- Détecte votre distribution
- Propose les outils disponibles
- Installe automatiquement les outils choisis

---

## 🔧 Ordre de priorité dans `man()`

La fonction `man()` essaie les outils dans cet ordre :

1. **pandoc + groff** - Conversion en format man système
2. **bat** - Coloration Markdown native
3. **mdcat** - Visualiseur Markdown
4. **glow** - Visualiseur interactif
5. **pygmentize + less** - Coloration avec less
6. **less** - Visualiseur de base
7. **cat** - Dernier recours (pas de coloration)

---

## 📝 Exemple d'utilisation

```bash
# Afficher la page man d'une fonction (Markdown)
man extract

# Si l'outil est installé, affichage avec coloration
# Sinon, affichage basique avec less/cat
```

---

## 🛠️ Conversion manuelle (si nécessaire)

Si vous voulez convertir un fichier `.md` en format man système :

```bash
# Avec pandoc
pandoc extract.md -s -f markdown -t man -o extract.1

# Afficher avec man système
man ./extract.1
```

---

## 💡 Recommandation

**Pour la meilleure expérience** :
1. Installez **bat** (le plus simple et efficace)
2. Ou **pandoc + groff** (expérience identique au man système)

**Installation rapide** :
```bash
# Arch Linux
yay -S bat

# Puis tester
man extract
```

---

## 🔍 Vérifier les outils installés

```bash
command -v bat && echo "✅ bat installé"
command -v pandoc && echo "✅ pandoc installé"
command -v glow && echo "✅ glow installé"
command -v mdcat && echo "✅ mdcat installé"
command -v pygmentize && echo "✅ pygmentize installé"
```

---

**Dernière mise à jour** : $(date)

