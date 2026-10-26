# Profil machine de base (BASE_PROFILE)

Listes déclaratives utilisées par `scripts/install/system/base_profile.sh`
et `packages_base.sh` / `package_managers.sh`.

## Fichiers

| Fichier | Rôle |
|---------|------|
| `universal.bins` | Binaires minimum sur **toute** distro |
| `gui.bins` | Outils GUI (skip si `DOTFILES_HEADLESS=1`) |
| `pkgmap.conf` | Mapping clé → paquet (arch / debian / fedora / gentoo) |
| `arch.extra` | Extra Arch (base-devel, AUR helper…) |
| `debian.extra` | Extra Debian/Ubuntu |
| `fedora.extra` | Extra Fedora |
| `gentoo.extra` | Extra Gentoo (emerge atoms) |

## Variables

| Variable | Défaut | Effet |
|----------|--------|-------|
| `DOTFILES_BASE_PROFILE` | `desktop` | `desktop` = universal+gui ; `headless` = sans gui.bins |
| `DOTFILES_HEADLESS` | `0` | `1` force headless |
| `DOTFILES_AUR_HELPER` | `yay` | `yay` \| `paru` \| `both` \| `none` (Arch) |
| `DOTFILES_WANT_SNAP` | `1` | Installer snapd si possible |
| `DOTFILES_WANT_FLATPAK` | `1` | Installer flatpak + Flathub |
| `DOTFILES_SET_DEFAULT_SHELL` | `0` | `1` → `chsh -s` vers zsh (ou `DOTFILES_DEFAULT_SHELL`) |
| `DOTFILES_DEFAULT_SHELL` | `zsh` | `zsh` \| `fish` \| `bash` |
| `DOTFILES_AUTO_BASE` | `0` | Bootstrap : installer le profil sans menu |

## Usage

```sh
make base                  # alias → base_profile.sh install
bash scripts/install/system/base_profile.sh doctor
bash scripts/install/system/base_profile.sh plan
DOTFILES_HEADLESS=1 bash scripts/install/system/base_profile.sh install
DOTFILES_AUR_HELPER=paru bash scripts/install/system/base_profile.sh install
```
