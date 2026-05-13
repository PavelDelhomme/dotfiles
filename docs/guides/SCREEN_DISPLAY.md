# Écrans externes — luminosité, preset couleur, Full / Limited range HDMI

> Hub doc : [`../INDEX.md`](../INDEX.md) · Manager associé : [`../man/displayman.md`](../man/displayman.md) · Bug firmware Xiaomi : [`../ERRORS.md`](../ERRORS.md)

Ce guide centralise le **diagnostic** et la **remédiation** des problèmes
courants de luminosité / rendu visuel sur écrans externes, notamment quand
brightness côté DDC est déjà au maximum mais que l'image reste lavée ou
sombre. Cas étudié principal : **Mi Monitor (XMI)** en HDMI sur **NVIDIA
propriétaire + Wayland/KDE Plasma 6**.

Trois étapes, dans l'ordre :

1. **A — Diagnostic DDC** (logiciel, non destructif)
2. **B — OSD physique** (joystick au dos du moniteur)
3. **C — Full Range HDMI** (override pilote NVIDIA — nécessite redémarrage session)

---

## Étape A — Diagnostic DDC (non destructif)

Pré-requis : `ddcutil` installé. Vérifier :

```sh
ddcutil --version
ddcutil detect --brief
```

Si l'écran apparaît avec un I2C bus (`/dev/i2c-X`), on peut interroger ses VCP.

Commande recommandée (utilise `displayman`) :

```sh
displayman detect          # vue d'ensemble
displayman dump 1          # diagnostic complet écran 1
```

Sortie attendue (exemple Mi Monitor) :

```
[VCP 10] Brightness            -> C 100 100
[VCP 12] Contrast              -> C 100 100
[VCP 14] Color preset (lect.)  -> SNC x0b
[VCP 16] Gain ROUGE            -> C 100 100
[VCP 18] Gain VERT             -> C 100 100
[VCP 1A] Gain BLEU             -> C 100 100
[VCP 6C] Black level ROUGE     -> C 50 100
[VCP 6E] Black level VERT      -> C 50 100
[VCP 70] Black level BLEU      -> C 50 100
[VCP D6] Power mode            -> SNC x01
```

Lectures importantes :

| Code | Interprétation                                                              |
|------|------------------------------------------------------------------------------|
| `10` | Brightness. `100/100` = au max. Si déjà à 100, **on ne montera pas plus**.   |
| `12` | Contrast. Idem.                                                              |
| `14` | Color preset. `01` = sRGB · `05` = 6500K · `06` = 7500K · `08` = 9300K · `0b` = User 1. |
| `16/18/1A` | Gains rouge/vert/bleu. À `100` chacun pour un rendu neutre.            |
| `6C/6E/70` | Niveaux de noir RGB. `50` = centré (neutre).                           |

Si `brightness` n'est pas au max → `displayman brightness 1 100`.
Si `preset` est sur `0b` (User 1) → tenter `displayman preset 1 srgb` (souvent
refusé silencieusement par le firmware Mi Monitor, voir Étape B).

### Test d'écriture rapide

Pour confirmer que le canal DDC fonctionne, faire un aller-retour brightness :

```sh
displayman brightness 1 50      # l'écran doit visiblement faiblir
displayman brightness 1 100     # remontée au max
```

Si l'image clignote bien → DDC OK. Si rien ne change → ACL `/dev/i2c-*` à
vérifier ou ajouter `$USER` au groupe `i2c`.

### Cas "DDC OK mais image lavée à 100"

Quand le DDC répond bien mais que l'image reste pâle ou peu lumineuse même à
brightness 100, c'est un des trois cas suivants :

1. **Preset User 1 actif** + biais utilisateur appliqués → Étape B.
2. **HDMI Limited Range (16-235) au lieu de Full (0-255)** côté pilote → Étape C.
3. **Dalle limitée physiquement** (Mi Monitor 1C / A22 / 2C ≈ 250 cd/m²) →
   rien à faire logiciellement, c'est la dalle.

---

## Étape B — OSD physique (joystick)

Quand le firmware DDC refuse `setvcp 14`, seul l'OSD physique permet de
modifier le preset couleur. Procédure générique Mi Monitor :

1. **Joystick** : généralement en bas à droite au DOS de la dalle. Appui
   central pour ouvrir le menu.
2. **Picture → Picture Mode** :
   - Bascule sur **Standard** ou **sRGB**.
   - Éviter `User`, `User 1`, `ECO`, `Reading`, `Game` (luminance bridée).
3. **Picture → Advanced → HDMI Black Level / HDMI Range** :
   - **Normal** = Full RGB (0-255). C'est la valeur souhaitée.
   - **Low** / **Limited** = source du rendu lavé sur PC.
4. Désactiver : `DCR`, `Dynamic Contrast`, `Low Blue Light`, `Eye Saver`,
   `Smart Energy Saver`.
5. **Settings → Reset → Factory Reset** si rien d'autre n'aide.

Vérifier après changement :

```sh
displayman dump 1
# VCP 14 ne doit plus être à 0x0b
```

Raccourci sous forme de mémo :

```sh
displayman osd-guide
```

---

## Étape C — Full Range HDMI sur NVIDIA propriétaire

> ⚠ **Modifie une configuration système. Ne pas appliquer sans avoir
> validé Étape A + Étape B.**

Sur GPU **NVIDIA propriétaire**, la propriété DRM `Broadcast RGB` n'est pas
exposée à Wayland/KDE de la même façon que sur Intel/AMD. Le pilote NVIDIA
lit cependant les fragments `xorg.conf.d` même sous Wayland car le mode
HDMI est encore négocié via le module noyau.

### Fix recommandé

Créer le fichier `/etc/X11/xorg.conf.d/20-nvidia-fullrange.conf` :

```
Section "Device"
    Identifier "Card0"
    Driver     "nvidia"
    Option     "ColorRange"  "Full"
EndSection
```

Puis **redémarrer la session graphique** (logout/login, ou `systemctl restart
display-manager` — au choix). Pas besoin de reboot complet en général.

Vérification visuelle :

- Noirs vraiment noirs (et plus gris-anthracite).
- Blancs plus francs, dégradés plus lisibles aux extrêmes.
- `displayman range` confirme le contexte (GPU détecté, session, nvidia-drm).

### Rollback

Si la modif aggrave les choses (par exemple sur un écran qui attend
réellement du Limited côté EDID) :

```sh
sudo rm /etc/X11/xorg.conf.d/20-nvidia-fullrange.conf
# puis logout/login
```

### Alternatives selon GPU

| GPU                | Méthode                                                                                       |
|--------------------|-----------------------------------------------------------------------------------------------|
| NVIDIA propriétaire (X11) | `nvidia-settings → X Server Display Configuration → Advanced → Color Range: Full`        |
| NVIDIA propriétaire (Wayland) | Fragment `xorg.conf.d` ci-dessus (le module lit la conf au démarrage du DRM).            |
| Intel / AMD (KMS)  | `kscreen-doctor output.<N>.colorimetry rgb_full` (Plasma 6) ou propriété DRM `Broadcast RGB`. |
| Intel / AMD (X11)  | `xrandr --output <NAME> --set "Broadcast RGB" "Full"`.                                        |

### Variante : override EDID

Si l'EDID du moniteur déclare incorrectement ses capacités RGB, on peut
fournir un EDID patché via le paramètre kernel `drm_kms_helper.edid_firmware`.
Procédure plus invasive, non documentée ici par défaut — à demander
explicitement avant d'aller plus loin.

---

## Annexes

### Permissions I2C

Si `ddcutil detect` n'affiche aucun écran alors que les `/dev/i2c-*` existent,
deux causes possibles :

1. Module noyau `i2c-dev` non chargé : `sudo modprobe i2c-dev`.
2. Permissions : ajouter `$USER` au groupe `i2c` puis se déconnecter/reconnecter.
   ```sh
   sudo usermod -aG i2c "$USER"
   ```

Note : sur Arch récent, les `/dev/i2c-*` sont souvent décorés d'ACL `+` qui
donnent déjà accès à l'utilisateur de la session graphique active sans
modifier les groupes.

### Variables `displayman`

- `DISPLAYMAN_DDC_TIMEOUT` (défaut `15`) : timeout par appel ddcutil. Augmenter
  à `30` ou plus sur Mi Monitor (firmware lent).
- `NO_COLOR` : désactive les couleurs ANSI.

### Liens

- Manager : [`../man/displayman.md`](../man/displayman.md)
- Convention CLI / help : [`../TESTS.md`](../TESTS.md) Bloc G
- Bug firmware Xiaomi (preset DDC) : [`../ERRORS.md`](../ERRORS.md)
- `lsblk` colorisé (autre amélioration UI récente) : [`../../shared/functions/lsblk_color.sh`](../../shared/functions/lsblk_color.sh)
