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

.PHONY: help install setup validate rollback reset clean symlinks migrate generate-man test test-all test-syntax test-managers test-manager test-scripts test-libs test-zshrc test-alias docker-build docker-run docker-test docker-stop docker-clean docker-test-auto docker-build-test
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
	@echo "$(GREEN)Tests:$(NC)"
	@echo "  make test              - Lancer tous les tests"
	@echo "  make test-all          - Test complet dans environnement isolé"
	@echo "  make test-syntax       - Tester la syntaxe de tous les scripts"
	@echo "  make test-managers     - Tester tous les managers"
	@echo "  make test-manager MANAGER=aliaman - Tester un manager spécifique"
	@echo "  make test-scripts      - Tester les scripts de configuration"
	@echo "  make test-libs         - Tester les bibliothèques communes"
	@echo "  make test-zshrc        - Tester zshrc_custom"
	@echo "  make test-alias        - Tester les alias"
	@echo ""
	@echo "$(GREEN)Docker (Tests conteneurisés):$(NC)"
	@echo "  make docker-build      - Construire l'image Docker"
	@echo "  make docker-run        - Lancer un conteneur interactif"
	@echo "  make docker-compose-up - Lancer avec docker-compose"
	@echo "  make docker-test       - Tester les dotfiles dans Docker"
	@echo "  make docker-shell      - Ouvrir un shell dans le conteneur"
	@echo "  make docker-stop       - Arrêter le conteneur"
	@echo "  make docker-clean      - Nettoyer images et volumes Docker"
	@echo "  make docker-test-auto  - Tester installation automatique complète (isolé)"
	@echo "  make docker-build-test - Construire l'image Docker de test automatique"
	@echo ""
	@echo "$(GREEN)Maintenance:$(NC)"
	@echo "  make rollback          - Rollback complet (désinstaller tout)"
	@echo "  make reset             - Réinitialisation complète (remise à zéro)"
	@echo "  make clean             - Nettoyer les fichiers temporaires"
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
	@echo "  make generate-man     - Générer les pages man pour toutes les fonctions"
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
	@echo "$(GREEN)✓ Nettoyage des logs terminé$(NC)"
	@echo ""
	@echo "$(BLUE)🧹 Nettoyage des fichiers de build (Gradle, etc.)...$(NC)"
	@if [ -d "frontend/android" ]; then \
		echo "$(YELLOW)  Nettoyage de frontend/android...$(NC)"; \
		cd frontend/android && \
		rm -rf .gradle build 2>/dev/null || true && \
		echo "$(GREEN)  ✓ frontend/android/.gradle et build supprimés$(NC)" && \
		cd ../..; \
	else \
		echo "$(YELLOW)  ⚠️  frontend/android non trouvé, ignoré$(NC)"; \
	fi
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
	@bash "$(SCRIPT_DIR)/tools/generate_man_pages.sh"

################################################################################
# Tests
################################################################################

test: test-all ## Lancer tous les tests (alias pour test-all)

test-all: ## Test complet dans environnement isolé
	@echo "$(BLUE)🧪 Test complet des dotfiles...$(NC)"
	@if [ -f "$(SCRIPT_DIR)/test/test_dotfiles.sh" ]; then \
		bash "$(SCRIPT_DIR)/test/test_dotfiles.sh"; \
	else \
		echo "$(YELLOW)⚠️  Script de test non trouvé$(NC)"; \
		echo "$(YELLOW)   Création du script de test...$(NC)"; \
		make test-syntax test-managers test-scripts test-libs test-zshrc test-alias; \
	fi

test-syntax: ## Tester la syntaxe de tous les scripts
	@echo "$(BLUE)🔍 Test de syntaxe des scripts...$(NC)"
	@echo ""
	@echo "$(GREEN)Test syntaxe Zsh (managers):$(NC)"
	@for manager in pathman netman aliaman miscman searchman cyberman devman gitman helpman configman installman fileman virtman manman moduleman; do \
		if [ -f "$(DOTFILES_DIR)/zsh/functions/$$manager.zsh" ]; then \
			if zsh -n "$(DOTFILES_DIR)/zsh/functions/$$manager.zsh" 2>/dev/null; then \
				echo "  ✓ $$manager.zsh"; \
			else \
				echo "  ✗ $$manager.zsh"; \
			fi; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)Test syntaxe Bash (scripts config):$(NC)"
	@find "$(DOTFILES_DIR)/zsh/functions/configman/modules" -name "*.sh" 2>/dev/null | while read script; do \
		if bash -n "$$script" 2>/dev/null; then \
			echo "  ✓ $$(basename $$script)"; \
		else \
			echo "  ✗ $$(basename $$script)"; \
		fi; \
	done
	@find "$(DOTFILES_DIR)/zsh/functions/virtman/modules" -name "*.sh" 2>/dev/null | while read script; do \
		if bash -n "$$script" 2>/dev/null; then \
			echo "  ✓ $$(basename $$script)"; \
		else \
			echo "  ✗ $$(basename $$script)"; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)Test syntaxe bibliothèques:$(NC)"
	@if [ -f "$(SCRIPT_DIR)/lib/common.sh" ]; then \
		if bash -n "$(SCRIPT_DIR)/lib/common.sh" 2>/dev/null; then \
			echo "  ✓ common.sh"; \
		else \
			echo "  ✗ common.sh"; \
		fi; \
	fi

test-managers: ## Tester tous les managers
	@echo "$(BLUE)🔍 Test des managers...$(NC)"
	@for manager in pathman netman aliaman miscman searchman cyberman devman gitman helpman configman installman fileman virtman manman moduleman; do \
		if [ -f "$(DOTFILES_DIR)/zsh/functions/$$manager.zsh" ]; then \
			echo "  ✓ $$manager existe"; \
		else \
			echo "  ✗ $$manager manquant"; \
		fi; \
	done
	@echo ""
	@echo "$(GREEN)Structures modulaires:$(NC)"
	@for manager in cyberman fileman virtman configman; do \
		if [ -d "$(DOTFILES_DIR)/zsh/functions/$$manager/core" ] && \
		   [ -d "$(DOTFILES_DIR)/zsh/functions/$$manager/modules" ] && \
		   [ -d "$(DOTFILES_DIR)/zsh/functions/$$manager/config" ]; then \
			echo "  ✓ $$manager (structure complète)"; \
		else \
			echo "  ✗ $$manager (structure incomplète)"; \
		fi; \
	done

test-manager: ## Tester un manager spécifique (usage: make test-manager MANAGER=aliaman)
	@if [ -z "$(MANAGER)" ]; then \
		echo "$(YELLOW)⚠️  Usage: make test-manager MANAGER=<nom>$(NC)"; \
		echo "$(YELLOW)   Exemples: make test-manager MANAGER=aliaman$(NC)"; \
		echo "$(YELLOW)            make test-manager MANAGER=cyberman$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)🔍 Test du manager: $(MANAGER)$(NC)"
	@if [ -f "$(DOTFILES_DIR)/zsh/functions/$(MANAGER).zsh" ]; then \
		echo "$(GREEN)✓ Fichier trouvé$(NC)"; \
		if zsh -n "$(DOTFILES_DIR)/zsh/functions/$(MANAGER).zsh" 2>/dev/null; then \
			echo "$(GREEN)✓ Syntaxe valide$(NC)"; \
		else \
			echo "$(RED)✗ Erreur de syntaxe$(NC)"; \
			zsh -n "$(DOTFILES_DIR)/zsh/functions/$(MANAGER).zsh" 2>&1 || true; \
		fi; \
	else \
		echo "$(RED)✗ Fichier non trouvé$(NC)"; \
	fi

test-scripts: ## Tester les scripts de configuration
	@echo "$(BLUE)🔍 Test des scripts de configuration...$(NC)"
	@echo "$(GREEN)Scripts configman:$(NC)"
	@find "$(DOTFILES_DIR)/zsh/functions/configman/modules" -name "*.sh" 2>/dev/null | while read script; do \
		if bash -n "$$script" 2>/dev/null; then \
			echo "  ✓ $$(basename $$script)"; \
		else \
			echo "  ✗ $$(basename $$script)"; \
		fi; \
	done
	@echo "$(GREEN)Scripts virtman:$(NC)"
	@find "$(DOTFILES_DIR)/zsh/functions/virtman/modules" -name "*.sh" 2>/dev/null | while read script; do \
		if bash -n "$$script" 2>/dev/null; then \
			echo "  ✓ $$(basename $$script)"; \
		else \
			echo "  ✗ $$(basename $$script)"; \
		fi; \
	done

test-libs: ## Tester les bibliothèques communes
	@echo "$(BLUE)🔍 Test des bibliothèques communes...$(NC)"
	@if [ -f "$(SCRIPT_DIR)/lib/common.sh" ]; then \
		echo "$(GREEN)✓ common.sh existe$(NC)"; \
		if bash -n "$(SCRIPT_DIR)/lib/common.sh" 2>/dev/null; then \
			echo "$(GREEN)✓ Syntaxe valide$(NC)"; \
		else \
			echo "$(RED)✗ Erreur de syntaxe$(NC)"; \
		fi; \
	else \
		echo "$(RED)✗ common.sh non trouvé$(NC)"; \
	fi
	@if [ -f "$(SCRIPT_DIR)/lib/actions_logger.sh" ]; then \
		echo "$(GREEN)✓ actions_logger.sh existe$(NC)"; \
	fi
	@if [ -f "$(SCRIPT_DIR)/lib/install_logger.sh" ]; then \
		echo "$(GREEN)✓ install_logger.sh existe$(NC)"; \
	fi

test-zshrc: ## Tester zshrc_custom
	@echo "$(BLUE)🔍 Test de zshrc_custom...$(NC)"
	@if [ -f "$(DOTFILES_DIR)/zsh/zshrc_custom" ]; then \
		echo "$(GREEN)✓ zshrc_custom existe$(NC)"; \
		if zsh -n "$(DOTFILES_DIR)/zsh/zshrc_custom" 2>/dev/null; then \
			echo "$(GREEN)✓ Syntaxe valide$(NC)"; \
		else \
			echo "$(RED)✗ Erreur de syntaxe$(NC)"; \
			zsh -n "$(DOTFILES_DIR)/zsh/zshrc_custom" 2>&1 | head -5 || true; \
		fi; \
		if grep -q "module_status" "$(DOTFILES_DIR)/zsh/zshrc_custom" 2>/dev/null; then \
			echo "$(GREEN)✓ Variable 'status' corrigée (module_status)$(NC)"; \
		else \
			if grep -E "local status=|status=" "$(DOTFILES_DIR)/zsh/zshrc_custom" 2>/dev/null | grep -v "module_status" | grep -v "#"; then \
				echo "$(YELLOW)⚠️  Variable 'status' potentiellement en conflit$(NC)"; \
			else \
				echo "$(GREEN)✓ Pas de conflit de variable 'status'$(NC)"; \
			fi; \
		fi; \
	else \
		echo "$(RED)✗ zshrc_custom non trouvé$(NC)"; \
	fi

test-alias: ## Tester les alias
	@echo "$(BLUE)🔍 Test des alias...$(NC)"
	@if [ -f "$(DOTFILES_DIR)/zsh/aliases.zsh" ]; then \
		echo "$(GREEN)✓ aliases.zsh existe$(NC)"; \
		if zsh -n "$(DOTFILES_DIR)/zsh/aliases.zsh" 2>/dev/null; then \
			echo "$(GREEN)✓ Syntaxe valide$(NC)"; \
		else \
			echo "$(RED)✗ Erreur de syntaxe$(NC)"; \
		fi; \
		if grep -q "alias_status" "$(DOTFILES_DIR)/zsh/functions/aliaman.zsh" 2>/dev/null; then \
			echo "$(GREEN)✓ aliaman: variable 'status' corrigée (alias_status)$(NC)"; \
		else \
			if grep -E "local status=|status=" "$(DOTFILES_DIR)/zsh/functions/aliaman.zsh" 2>/dev/null | grep -v "alias_status" | grep -v "#"; then \
				echo "$(YELLOW)⚠️  aliaman: Variable 'status' potentiellement en conflit$(NC)"; \
			else \
				echo "$(GREEN)✓ aliaman: Pas de conflit de variable 'status'$(NC)"; \
			fi; \
		fi; \
	else \
		echo "$(YELLOW)⚠️  aliases.zsh non trouvé (optionnel)$(NC)"; \
	fi

################################################################################
# DOCKER - Tests dans environnement conteneurisé
################################################################################

# Préfixe pour isoler les conteneurs dotfiles des autres
DOTFILES_DOCKER_PREFIX = dotfiles-test
DOTFILES_CONTAINER = $(DOTFILES_DOCKER_PREFIX)-container
DOTFILES_IMAGE = $(DOTFILES_DOCKER_PREFIX)-image:latest

docker-build: ## Construire l'image Docker pour tester les dotfiles
	@echo "$(BLUE)🔨 Construction de l'image Docker (isolée avec préfixe)...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		docker build -t $(DOTFILES_IMAGE) . && \
		echo "$(GREEN)✓ Image Docker construite avec succès (isolée: $(DOTFILES_IMAGE))$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

docker-run: ## Lancer un conteneur Docker interactif pour tester les dotfiles
	@echo "$(BLUE)🚀 Lancement du conteneur Docker (isolé avec préfixe)...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		docker run -it --rm \
			--name $(DOTFILES_CONTAINER) \
			-v "$(PWD):/root/dotfiles:ro" \
			-v dotfiles-test-config:/root/.config \
			-v dotfiles-test-ssh:/root/.ssh \
			-e HOME=/root \
			-e DOTFILES_DIR=/root/dotfiles \
			-e TERM=xterm-256color \
			$(DOTFILES_IMAGE); \
	else \
		echo "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

docker-compose-up: ## Lancer avec docker-compose (isolé avec préfixe)
	@echo "$(BLUE)🚀 Lancement avec docker-compose (isolé avec préfixe)...$(NC)"
	@if command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1; then \
		docker compose -p $(DOTFILES_DOCKER_PREFIX) up -d && \
		docker compose -p $(DOTFILES_DOCKER_PREFIX) exec dotfiles-test /bin/zsh; \
	else \
		echo "$(YELLOW)⚠️  docker-compose n'est pas installé$(NC)"; \
		exit 1; \
	fi

docker-test: docker-build ## Tester les dotfiles dans Docker (build + run, isolé)
	@echo "$(BLUE)🧪 Test des dotfiles dans Docker (isolé avec préfixe)...$(NC)"
	@docker run --rm \
		--name $(DOTFILES_CONTAINER) \
		-v "$(PWD):/root/dotfiles:ro" \
		$(DOTFILES_IMAGE) \
		/bin/zsh -c "source /root/dotfiles/zsh/zshrc_custom && echo '✓ Dotfiles chargés avec succès' && zsh -c 'type installman >/dev/null && echo \"✓ installman disponible\" || echo \"✗ installman non disponible\"'"

docker-stop: ## Arrêter UNIQUEMENT les conteneurs Docker dotfiles-test
	@echo "$(BLUE)🛑 Arrêt UNIQUEMENT des conteneurs Docker dotfiles-test...$(NC)"
	@docker ps --filter "name=$(DOTFILES_DOCKER_PREFIX)" --format "{{.Names}}" | xargs -r docker stop 2>/dev/null || echo "$(YELLOW)⚠️  Aucun conteneur dotfiles-test en cours$(NC)"
	@docker compose -p $(DOTFILES_DOCKER_PREFIX) down 2>/dev/null || true

docker-clean: ## Nettoyer UNIQUEMENT les images et volumes Docker dotfiles-test
	@echo "$(BLUE)🧹 Nettoyage UNIQUEMENT des conteneurs/images/volumes dotfiles-test...$(NC)"
	@echo "$(YELLOW)⚠️  Vos autres conteneurs Docker ne seront PAS touchés$(NC)"
	@docker ps -a --filter "name=$(DOTFILES_DOCKER_PREFIX)" --format "{{.Names}}" | xargs -r docker stop 2>/dev/null || true
	@docker ps -a --filter "name=$(DOTFILES_DOCKER_PREFIX)" --format "{{.Names}}" | xargs -r docker rm 2>/dev/null || true
	@docker images --filter "reference=$(DOTFILES_DOCKER_PREFIX)*" --format "{{.Repository}}:{{.Tag}}" | xargs -r docker rmi 2>/dev/null || true
	@docker compose -p $(DOTFILES_DOCKER_PREFIX) down -v 2>/dev/null || true
	@echo "$(GREEN)✓ Nettoyage terminé (uniquement dotfiles-test)$(NC)"

docker-shell: ## Ouvrir un shell dans le conteneur dotfiles-test en cours d'exécution
	@echo "$(BLUE)🐚 Ouverture d'un shell dans le conteneur dotfiles-test...$(NC)"
	@docker exec -it $(DOTFILES_CONTAINER) /bin/zsh 2>/dev/null || docker compose -p $(DOTFILES_DOCKER_PREFIX) exec dotfiles-test /bin/zsh 2>/dev/null || echo "$(YELLOW)⚠️  Aucun conteneur dotfiles-test en cours d'exécution$(NC)"

docker-test-auto: ## Tester l'installation complète et automatique dans Docker isolé
	@echo "$(BLUE)🧪 Test d'installation automatique complète dans Docker...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		if [ -f "test-docker.sh" ]; then \
			bash test-docker.sh; \
		else \
			echo "$(YELLOW)⚠️  Script test-docker.sh non trouvé$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

docker-build-test: ## Construire l'image Docker de test automatique (isolée)
	@echo "$(BLUE)🔨 Construction de l'image Docker de test (isolée avec préfixe)...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		docker build --load -f Dockerfile.test -t $(DOTFILES_DOCKER_PREFIX):auto . && \
		echo "$(GREEN)✓ Image Docker de test construite avec succès (isolée: $(DOTFILES_DOCKER_PREFIX):auto)$(NC)"; \
	else \
		echo "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi
