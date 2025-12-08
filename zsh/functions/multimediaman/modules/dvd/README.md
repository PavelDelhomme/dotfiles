# Module DVD - Ripping et Encodage

## Description

Module pour ripper et encoder des DVD en MP4 avec un pipeline automatique.

## Pré-requis

1. **HandBrakeCLI** : Installé via `installman handbrake`
2. **dvdbackup** : Installé automatiquement avec HandBrake ou manuellement :
   ```bash
   sudo pacman -S dvdbackup  # Arch/Manjaro
   sudo apt install dvdbackup  # Debian/Ubuntu
   ```
3. **libdvdcss** : Pour les DVD chiffrés (Arch/Manjaro uniquement, via AUR)

## Utilisation

### Via le menu interactif

```bash
multimediaman
# Puis sélectionner l'option 1 (Ripping DVD)
```

### Via la ligne de commande

```bash
# Ripping avec nom par défaut
multimediaman rip-dvd

# Ripping avec nom personnalisé
multimediaman rip-dvd "Mon_Film"

# Ripping avec périphérique personnalisé
multimediaman rip-dvd "Mon_Film" "/dev/sr1"

# Ripping avec qualité personnalisée (RF 18 = quasi lossless)
multimediaman rip-dvd "Mon_Film" "/dev/sr0" "18"
```

### Alias disponibles

```bash
mm              # Alias pour multimediaman
mm-rip          # Alias pour multimediaman rip-dvd
```

## Pipeline automatique

Le script effectue automatiquement :

1. **Copie du DVD brut** : Utilise `dvdbackup` pour copier la structure complète du DVD
2. **Encodage MP4** : Utilise `HandBrakeCLI` pour encoder en MP4 H.264 avec :
   - Qualité RF 20 par défaut (18-20 = très bonne qualité)
   - Format MP4 (compatible web)
   - Toutes les pistes audio (VF, VO, etc.)
   - Tous les sous-titres
   - Chapitres conservés
   - Optimisation "fast start" pour streaming web

## Paramètres de qualité

- **RF 18** : Qualité quasi lossless (fichier plus volumineux)
- **RF 20** : Très bonne qualité (par défaut, bon compromis)
- **RF 22-23** : Bonne qualité (fichier plus petit)

## Fichier de sortie

Le fichier final est créé dans : `~/DVD_RIPS/[nom_du_film].mp4`

## Options avancées

Pour forcer seulement les pistes audio FR+EN, vous pouvez modifier le script `rip_dvd.sh` et utiliser :
- `--audio-lang-list fr,eng` au lieu de `--all-audio`

Pour sortir en MKV au lieu de MP4 :
- Remplacer `-f av_mp4` par `-f av_mkv`

## Exemple complet

```bash
# 1. Installer HandBrake
installman handbrake

# 2. Insérer le DVD

# 3. Ripper le DVD
multimediaman rip-dvd "Le_Seigneur_Des_Anneaux"

# 4. Le fichier sera dans ~/DVD_RIPS/Le_Seigneur_Des_Anneaux.mp4
```

