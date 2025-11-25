# Makefile pour dotfiles - PavelDelhomme
# Version: 2.0.0
#
# Usage:
#   make install          - Installation complète (bootstrap)
#   make setup            - Lancer le menu interactif
#   make validate         - Valider le setup
#   make rollback         - Rollback complet
#   make reset            - Réinitialisation complète
#   make help             - Afficher l'aide
#   make generate-man     - Générer les pages man pour toutes les fonctions

.PHONY: help install setup validate rollback reset clean symlinks migrate generate-man
.DEFAULT_GOAL := help

DOTFILES_DIR := $(HOME)/dotfiles
SCRIPT_DIR := $(DOTFILES_DIR)/scripts

# Couleurs pour les messages
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m

help: ## Afficher cette aide
	@echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Dotfiles - Makefile Commands$(NC)"
	@echo "$(BLUE)════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(GREEN)Installation:$(NC)"
	@echo "  make install          - Installation complète depuis zéro (bootstrap)"
	@echo "  make setup             - Lancer le menu interactif setup.sh"
	@echo "  make symlinks          - Créer les symlinks pour centraliser la config"
	@echo "  make migrate           - Migrer configuration existante vers dotfiles"
	@echo ""
	@echo "$(GREEN)Validation:$(NC)"
	@echo "  make validate          - Valider le setup complet"
	@echo ""
	@echo "$(GREEN)Maintenance:$(NC)"
	@echo "  make rollback          - Rollback complet (désinstaller tout)"
	@echo "  make reset             - Réinitialisation complète (remise à zéro)"
	@echo "  make clean             - Nettoyer les fichiers temporaires"
	@echo "  make generate-man      - Générer les pages man pour toutes les fonctions"
	@echo ""
	@echo "$(GREEN)Documentation:$(NC)"
	@echo "  make generate-man      - Générer les pages man pour toutes les fonctions"
	@echo ""
	@echo "$(GREEN)Configuration:$(NC)"
	@echo "  make git-config        - Configurer Git (nom, email)"
	@echo "  make git-remote        - Configurer remote Git (SSH/HTTPS)"
	@echo "  make auto-sync         - Configurer auto-sync Git (systemd timer)"
	@echo ""
	@echo "$(GREEN)Corrections automatiques:$(NC)"
	@echo "  make fix               - Afficher les fixes disponibles"
	@echo "  make fix FIX=exec          - Rendre tous les scripts exécutables"
	@echo "  make fix FIX=timer-auto-sync - Configurer timer auto-sync"
	@echo "  make fix FIX=symlink-gitconfig - Créer symlink .gitconfig"
	@echo "  make fix FIX=ssh-agent     - Configurer et démarrer SSH agent"
	@echo "  make fix FIX=all           - Appliquer tous les fixes détectés"
	@echo "  make fix FIX=detect        - Détecter les problèmes"
	@echo ""
	@echo "$(GREEN)Installations spécifiques:$(NC)"
	@echo "  make install APP=docker   - Installer Docker & Docker Compose"
	@echo "  make install APP=go       - Installer Go (Golang)"
	@echo "  make install APP=cursor   - Installer Cursor IDE"
	@echo "  make install APP=brave    - Installer Brave Browser"
	@echo "  make install APP=yay      - Installer yay (AUR helper - Arch Linux)"
	@echo "  make install APP=nvm      - Installer NVM (Node Version Manager)"
	@echo ""
	@echo "$(YELLOW)Note: Les commandes install-* sont dépréciées, utilisez make install APP=...$(NC)"
	@echo ""
	@echo "$(GREEN)Menus interactifs:$(NC)"
	@echo "  make menu            - Menu principal (tous les menus)"
	@echo "  make install-menu    - Menu d'installation (applications, outils)"
	@echo "  make config-menu     - Menu de configuration (Git, shell, symlinks)"
	@echo "  make shell-menu      - Menu de gestion des shells (zsh/fish/bash)"
	@echo "  make vm-menu         - Menu interactif de gestion des VM"
	@echo "  make fix-menu        - Menu de corrections automatiques"
	@echo "  make validate-menu   - Afficher la validation du setup"
	@echo ""
	@echo "$(GREEN)Outils:$(NC)"
	@echo "  make detect-shell     - Détecter le shell actuel et disponibles"
	@echo "  make convert-zsh-to-sh - Convertir fonctions Zsh en Sh compatible"
	@echo ""
	@echo "$(GREEN)Gestion des VM (tests):$(NC)"
	@echo "  make vm-list          - Lister toutes les VM"
	@echo "  make vm-create        - Créer une VM (VM=name MEMORY=2048 VCPUS=2 DISK=20 ISO=path)"
	@echo "  make vm-start         - Démarrer une VM (VM=name)"
	@echo "  make vm-stop          - Arrêter une VM (VM=name)"
	@echo "  make vm-info          - Infos d'une VM (VM=name)"
	@echo "  make vm-snapshot      - Créer snapshot (VM=name NAME=snap DESC=\"desc\")"
	@echo "  make vm-snapshots     - Lister snapshots (VM=name)"
	@echo "  make vm-rollback      - Restaurer snapshot (VM=name SNAPSHOT=name)"
	@echo "  make vm-test          - Tester dotfiles dans VM (VM=name)"
	@echo "  make vm-delete        - Supprimer une VM (VM=name)"
	@echo ""
	@echo "$(YELLOW)Pour plus d'options, utilisez: make setup$(NC)"
	@echo ""

install-all: ## Installation complète depuis zéro (bootstrap)
	@echo "$(BLUE)🚀 Installation complète des dotfiles...$(NC)"
	@if [ -f "$(DOTFILES_DIR)/bootstrap.sh" ]; then \
		bash "$(DOTFILES_DIR)/bootstrap.sh"; \
	else \
		echo "$(YELLOW)⚠️  bootstrap.sh non trouvé, clonage depuis GitHub...$(NC)"; \
		curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash; \
	fi

# Alias pour compatibilité
install: install-all ## Alias pour install-all (ou make install APP=... pour installer une app)

setup: ## Lancer le menu interactif setup.sh
	@echo "$(BLUE)📋 Menu interactif setup.sh...$(NC)"
	@bash "$(SCRIPT_DIR)/setup.sh"

validate: ## Valider le setup complet
	@echo "$(BLUE)✅ Validation du setup...$(NC)"
	@bash "$(SCRIPT_DIR)/test/validate_setup.sh"

rollback: ## Rollback complet (désinstaller tout)
	@echo "$(YELLOW)⚠️  ROLLBACK - Désinstallation complète$(NC)"
	@printf "Continuer? (tapez 'OUI' en majuscules): "
	@read confirm && \
	if [ "$$confirm" = "OUI" ]; then \
		bash "$(SCRIPT_DIR)/uninstall/rollback_all.sh"; \
	else \
		echo "$(YELLOW)Rollback annulé$(NC)"; \
	fi

reset: ## Réinitialisation complète (remise à zéro)
	@echo "$(YELLOW)⚠️  RÉINITIALISATION - Remise à zéro complète$(NC)"
	@printf "Continuer? (tapez 'OUI' en majuscules): "
	@read confirm && \
	if [ "$$confirm" = "OUI" ]; then \
		bash "$(SCRIPT_DIR)/uninstall/reset_all.sh"; \
	else \
		echo "$(YELLOW)Réinitialisation annulée$(NC)"; \
	fi

clean: ## Nettoyer les fichiers temporaires
	@echo "$(BLUE)🧹 Nettoyage des fichiers temporaires...$(NC)"
	@rm -f "$(DOTFILES_DIR)/logs/auto_sync.log" 2>/dev/null || true
	@rm -f /tmp/dotfiles_auto_sync.lock 2>/dev/null || true
	@rm -f /tmp/auto_backup_dotfiles.pid 2>/dev/null || true
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"

symlinks: ## Créer les symlinks pour centraliser la config
	@echo "$(BLUE)🔗 Création des symlinks...$(NC)"
	@bash "$(SCRIPT_DIR)/config/create_symlinks.sh"

migrate: ## Migrer configuration existante vers dotfiles
	@echo "$(BLUE)🔄 Migration de la configuration existante...$(NC)"
	@bash "$(SCRIPT_DIR)/migrate_existing_user.sh"

# Configuration Git
git-config: ## Configurer Git (nom, email)
	@bash "$(SCRIPT_DIR)/config/git_config.sh"

git-remote: ## Configurer remote Git (SSH/HTTPS)
	@bash "$(SCRIPT_DIR)/config/git_remote.sh"

auto-sync: ## Configurer auto-sync Git (systemd timer)
	@bash "$(SCRIPT_DIR)/sync/install_auto_sync.sh"

restore: ## Restaurer depuis Git (annuler modifications locales)
	@bash "$(SCRIPT_DIR)/sync/restore_from_git.sh"

# Fix Manager - Corrections automatiques
# Supporte: make fix FIX=<nom> ou make fix=<nom>
ifdef FIX
fix: ## Afficher les fixes disponibles ou appliquer un fix (usage: make fix FIX=<nom>)
	@bash "$(SCRIPT_DIR)/fix/fix_manager.sh" "$(FIX)"
else
fix: ## Afficher les fixes disponibles ou appliquer un fix (usage: make fix FIX=<nom>)
	@bash "$(SCRIPT_DIR)/fix/fix_manager.sh"
endif

# Alias pour compatibilité (déprécié, utiliser make install APP=...)
install-docker: ## [DÉPRÉCIÉ] Installer Docker (utiliser: make install APP=docker)
	@echo "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=docker$(NC)"
	@bash "$(SCRIPT_DIR)/install/dev/install_docker.sh"

install-go: ## [DÉPRÉCIÉ] Installer Go (utiliser: make install APP=go)
	@echo "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=go$(NC)"
	@bash "$(SCRIPT_DIR)/install/dev/install_go.sh"

install-cursor: ## [DÉPRÉCIÉ] Installer Cursor (utiliser: make install APP=cursor)
	@echo "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=cursor$(NC)"
	@bash "$(SCRIPT_DIR)/install/apps/install_cursor.sh"

install-brave: ## [DÉPRÉCIÉ] Installer Brave (utiliser: make install APP=brave)
	@echo "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=brave$(NC)"
	@bash "$(SCRIPT_DIR)/install/apps/install_brave.sh"

install-yay: ## [DÉPRÉCIÉ] Installer yay (utiliser: make install APP=yay)
	@echo "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=yay$(NC)"
	@bash "$(SCRIPT_DIR)/install/tools/install_yay.sh"

install-nvm: ## [DÉPRÉCIÉ] Installer NVM (utiliser: make install APP=nvm)
	@echo "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=nvm$(NC)"
	@bash "$(SCRIPT_DIR)/install/tools/install_nvm.sh"

# Gestion des VM
vm-list: ## Lister toutes les VM
	@bash "$(SCRIPT_DIR)/vm/vm_manager.sh" && bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && list_vms --all"

vm-create: ## Créer une VM de test (usage: make vm-create VM=test-dotfiles MEMORY=2048 VCPUS=2 DISK=20 ISO=/path/to.iso)
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && create_vm '$(VM)' '$(MEMORY)' '$(VCPUS)' '$(DISK)' '$(ISO)'"

vm-start: ## Démarrer une VM (usage: make vm-start VM=test-dotfiles)
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && start_vm '$(VM)'"

vm-stop: ## Arrêter une VM (usage: make vm-stop VM=test-dotfiles)
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && stop_vm '$(VM)'"

vm-info: ## Afficher infos d'une VM (usage: make vm-info VM=test-dotfiles)
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && show_vm_info '$(VM)'"

vm-snapshot: ## Créer un snapshot (usage: make vm-snapshot VM=test-dotfiles NAME=clean DESC="Installation propre")
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && create_snapshot '$(VM)' '$(NAME)' '$(DESC)'"

vm-snapshots: ## Lister les snapshots (usage: make vm-snapshots VM=test-dotfiles)
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && list_snapshots '$(VM)'"

vm-rollback: ## Restaurer un snapshot (usage: make vm-rollback VM=test-dotfiles SNAPSHOT=clean)
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && restore_snapshot '$(VM)' '$(SNAPSHOT)'"

vm-test: ## Tester dotfiles dans une VM (usage: make vm-test VM=test-dotfiles)
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && test_dotfiles_in_vm '$(VM)'"

vm-delete: ## Supprimer une VM (usage: make vm-delete VM=test-dotfiles)
	@bash -c "source $(SCRIPT_DIR)/vm/vm_manager.sh && delete_vm '$(VM)'"

vm-menu: ## Menu interactif de gestion des VM
	@bash "$(SCRIPT_DIR)/vm/vm_manager.sh"

# Alias pour compatibilité
all: install ## Alias pour install
setup-menu: setup ## Alias pour setup
check: validate ## Alias pour validate

# Menus interactifs
menu: ## Menu principal (tous les menus)
	@bash "$(SCRIPT_DIR)/menu/main_menu.sh"

install-menu: ## Menu d'installation (applications, outils)
	@bash "$(SCRIPT_DIR)/menu/install_menu.sh"

config-menu: ## Menu de configuration (Git, shell, symlinks)
	@bash "$(SCRIPT_DIR)/menu/config_menu.sh"

shell-menu: ## Menu de gestion des shells (zsh/fish/bash)
	@bash "$(SCRIPT_DIR)/config/shell_manager.sh" "menu"

fix-menu: ## Menu de corrections automatiques
	@bash "$(SCRIPT_DIR)/fix/fix_manager.sh"

validate-menu: ## Menu de validation (affiche le résultat de validate)
	@bash "$(SCRIPT_DIR)/test/validate_setup.sh"

# Outils de conversion
convert-zsh-to-sh: ## Convertir les fonctions Zsh en Sh compatible
	@bash "$(SCRIPT_DIR)/tools/convert_zsh_to_sh.sh"

# Détection du shell actuel
detect-shell: ## Détecter et afficher le shell actuel
	@echo "$(BLUE)Shell actuel:$(NC)"
	@echo "  Shell: $$SHELL"
	@echo "  Nom: $$(basename "$$SHELL")"
	@echo "  Version: $$($$SHELL --version 2>/dev/null | head -n1 || echo "non disponible")"
	@echo ""
	@echo "$(BLUE)Shells disponibles:$(NC)"
	@for shell in zsh bash fish sh; do \
		if command -v $$shell >/dev/null 2>&1; then \
			echo "  ✓ $$shell: $$(which $$shell)"; \
		else \
			echo "  ✗ $$shell: non installé"; \
		fi \
	done

generate-man: ## Générer les pages man pour toutes les fonctions
	@bash $(SCRIPT_DIR)/tools/generate_man_pages.sh
