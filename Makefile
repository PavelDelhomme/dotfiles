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

.PHONY: help install setup validate rollback reset clean symlinks migrate generate-man test test-all test-syntax test-managers test-manager test-scripts test-libs test-zshrc test-alias docker-build docker-run docker-test docker-stop docker-clean docker-test-auto docker-build-test docker-start sync-all-shells sync-manager convert-manager
.DEFAULT_GOAL := help

DOTFILES_DIR := $(HOME)/dotfiles
SCRIPT_DIR := $(DOTFILES_DIR)/scripts

# Couleurs pour les messages
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
RED := \033[0;31m
MAGENTA := \033[0;35m
NC := \033[0m

help: ## Afficher cette aide
	@echo -e "$(BLUE)════════════════════════════════════════════════════════════$(NC)"
	@echo -e "$(BLUE)  Dotfiles - Makefile Commands$(NC)"
	@echo -e "$(BLUE)════════════════════════════════════════════════════════════$(NC)"
	@echo ""
	@echo -e "$(GREEN)Installation:$(NC)"
	@echo "  make install          - Installation complète depuis zéro (bootstrap)"
	@echo "  make setup             - Lancer le menu interactif setup.sh"
	@echo "  make symlinks          - Créer les symlinks pour centraliser la config"
	@echo "  make migrate           - Migrer configuration existante vers dotfiles"
	@echo ""
	@echo -e "$(GREEN)Validation:$(NC)"
	@echo "  make validate          - Valider le setup complet"
	@echo ""
	@echo -e "$(GREEN)Tests:$(NC)"
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
	@echo -e "$(GREEN)Docker (Tests conteneurisés):$(NC)"
	@echo "  make docker-build      - Construire l'image Docker"
	@echo "  make docker-run        - Lancer un conteneur interactif"
	@echo "  make docker-compose-up - Lancer avec docker-compose"
	@echo "  make docker-test       - Tester les dotfiles dans Docker"
	@echo "  make docker-shell      - Ouvrir un shell dans le conteneur"
	@echo "  make docker-stop       - Arrêter le conteneur"
	@echo "  make docker-clean      - Nettoyer images et volumes Docker"
	@echo "  make docker-test-auto  - Tester installation automatique complète (isolé)"
	@echo "  make docker-build-test - Construire l'image Docker de test automatique"
	@echo "  make docker-start      - Démarrer conteneur interactif (après docker-build-test)"
	@echo ""
	@echo -e "$(GREEN)Docker VM (Tests multi-distributions):$(NC)"
	@echo "  make docker-vm         - Lancer conteneur dotfiles-vm (Arch/Ubuntu/Debian/Gentoo)"
	@echo "  make docker-vm-reset   - Réinitialiser le conteneur dotfiles-vm"
	@echo "  make docker-vm-shell   - Ouvrir un shell dans dotfiles-vm"
	@echo "  make docker-vm-stop    - Arrêter dotfiles-vm"
	@echo "  make docker-vm-clean   - Nettoyer complètement dotfiles-vm"
	@echo "  make docker-vm-list    - Lister tous les conteneurs dotfiles"
	@echo "  make docker-vm-all-clean - Nettoyer TOUS les conteneurs dotfiles"
	@echo "  make docker-test-install - Tester installation complète (distro + shell + mode)"
	@echo "  make docker-test-bootstrap - Tester installation bootstrap dans conteneur propre"
	@echo ""
	@echo -e "$(GREEN)Maintenance:$(NC)"
	@echo "  make rollback          - Rollback complet (désinstaller tout)"
	@echo "  make reset             - Réinitialisation complète (remise à zéro)"
	@echo "  make clean             - Nettoyer les fichiers temporaires"
	@echo "  make generate-man      - Générer les pages man pour toutes les fonctions"
	@echo ""
	@echo -e "$(GREEN)Configuration:$(NC)"
	@echo "  make git-config        - Configurer Git (nom, email)"
	@echo "  make git-remote        - Configurer remote Git (SSH/HTTPS)"
	@echo "  make auto-sync         - Configurer auto-sync Git (systemd timer)"
	@echo ""
	@echo -e "$(GREEN)Corrections automatiques:$(NC)"
	@echo "  make fix               - Afficher les fixes disponibles"
	@echo "  make fix FIX=exec          - Rendre tous les scripts exécutables"
	@echo "  make fix FIX=timer-auto-sync - Configurer timer auto-sync"
	@echo "  make fix FIX=symlink-gitconfig - Créer symlink .gitconfig"
	@echo "  make fix FIX=ssh-agent     - Configurer et démarrer SSH agent"
	@echo "  make fix FIX=all           - Appliquer tous les fixes détectés"
	@echo "  make fix FIX=detect        - Détecter les problèmes"
	@echo ""
	@echo -e "$(GREEN)Installations spécifiques:$(NC)"
	@echo "  make install APP=docker   - Installer Docker & Docker Compose"
	@echo "  make install APP=go       - Installer Go (Golang)"
	@echo "  make install APP=cursor   - Installer Cursor IDE"
	@echo "  make install APP=brave    - Installer Brave Browser"
	@echo "  make install APP=yay      - Installer yay (AUR helper - Arch Linux)"
	@echo "  make install APP=nvm      - Installer NVM (Node Version Manager)"
	@echo ""
	@echo -e "$(YELLOW)Note: Les commandes install-* sont dépréciées, utilisez make install APP=...$(NC)"
	@echo ""
	@echo -e "$(GREEN)Menus interactifs:$(NC)"
	@echo "  make menu            - Menu principal (tous les menus)"
	@echo "  make install-menu    - Menu d'installation (applications, outils)"
	@echo "  make config-menu     - Menu de configuration (Git, shell, symlinks)"
	@echo "  make shell-menu      - Menu de gestion des shells (zsh/fish/bash)"
	@echo "  make vm-menu         - Menu interactif de gestion des VM"
	@echo "  make fix-menu        - Menu de corrections automatiques"
	@echo "  make validate-menu   - Afficher la validation du setup"
	@echo ""
	@echo -e "$(GREEN)Outils:$(NC)"
	@echo "  make detect-shell     - Détecter le shell actuel et disponibles"
	@echo "  make convert-zsh-to-sh - Convertir fonctions Zsh en Sh compatible"
	@echo "  make generate-man     - Générer les pages man pour toutes les fonctions"
	@echo ""
	@echo -e "$(GREEN)Gestion des VM (tests):$(NC)"
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
	@echo -e "$(YELLOW)Pour plus d'options, utilisez: make setup$(NC)"
	@echo ""

install-all: ## Installation complète depuis zéro (bootstrap)
	@echo -e "$(BLUE)🚀 Installation complète des dotfiles...$(NC)"
	@if [ -f "$(DOTFILES_DIR)/bootstrap.sh" ]; then \
		bash "$(DOTFILES_DIR)/bootstrap.sh"; \
	else \
		echo -e "$(YELLOW)⚠️  bootstrap.sh non trouvé, clonage depuis GitHub...$(NC)"; \
		curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash; \
	fi

# Alias pour compatibilité
install: install-all ## Alias pour install-all (ou make install APP=... pour installer une app)

setup: ## Lancer le menu interactif setup.sh
	@echo -e "$(BLUE)📋 Menu interactif setup.sh...$(NC)"
	@bash "$(SCRIPT_DIR)/setup.sh"

validate: ## Valider le setup complet
	@echo -e "$(BLUE)✅ Validation du setup...$(NC)"
	@bash "$(SCRIPT_DIR)/test/validate_setup.sh"

rollback: ## Rollback complet (désinstaller tout)
	@echo -e "$(YELLOW)⚠️  ROLLBACK - Désinstallation complète$(NC)"
	@printf "Continuer? (tapez 'OUI' en majuscules): "
	@read confirm && \
	if [ "$$confirm" = "OUI" ]; then \
		bash "$(SCRIPT_DIR)/uninstall/rollback_all.sh"; \
	else \
		echo -e "$(YELLOW)Rollback annulé$(NC)"; \
	fi

reset: ## Réinitialisation complète (remise à zéro)
	@echo -e "$(YELLOW)⚠️  RÉINITIALISATION - Remise à zéro complète$(NC)"
	@printf "Continuer? (tapez 'OUI' en majuscules): "
	@read confirm && \
	if [ "$$confirm" = "OUI" ]; then \
		bash "$(SCRIPT_DIR)/uninstall/reset_all.sh"; \
	else \
		echo -e "$(YELLOW)Réinitialisation annulée$(NC)"; \
	fi

clean: ## Nettoyer les fichiers temporaires
	@echo -e "$(BLUE)🧹 Nettoyage des fichiers temporaires...$(NC)"
	@rm -f "$(DOTFILES_DIR)/logs/auto_sync.log" 2>/dev/null || true
	@rm -f /tmp/dotfiles_auto_sync.lock 2>/dev/null || true
	@rm -f /tmp/auto_backup_dotfiles.pid 2>/dev/null || true
	@echo -e "$(GREEN)✓ Nettoyage des logs terminé$(NC)"
	@echo ""
	@echo -e "$(BLUE)🧹 Nettoyage des fichiers de build (Gradle, etc.)...$(NC)"
	@if [ -d "frontend/android" ]; then \
		echo -e "$(YELLOW)  Nettoyage de frontend/android...$(NC)"; \
		cd frontend/android && \
		rm -rf .gradle build 2>/dev/null || true && \
		echo -e "$(GREEN)  ✓ frontend/android/.gradle et build supprimés$(NC)" && \
		cd ../..; \
	else \
		echo -e "$(YELLOW)  ⚠️  frontend/android non trouvé, ignoré$(NC)"; \
	fi
	@echo -e "$(GREEN)✓ Nettoyage terminé$(NC)"

symlinks: ## Créer les symlinks pour centraliser la config
	@echo -e "$(BLUE)🔗 Création des symlinks...$(NC)"
	@bash "$(SCRIPT_DIR)/config/create_symlinks.sh"

migrate: ## Migrer configuration existante vers dotfiles
	@echo -e "$(BLUE)🔄 Migration de la configuration existante...$(NC)"
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
	@echo -e "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=docker$(NC)"
	@bash "$(SCRIPT_DIR)/install/dev/install_docker.sh"

install-go: ## [DÉPRÉCIÉ] Installer Go (utiliser: make install APP=go)
	@echo -e "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=go$(NC)"
	@bash "$(SCRIPT_DIR)/install/dev/install_go.sh"

install-cursor: ## [DÉPRÉCIÉ] Installer Cursor (utiliser: make install APP=cursor)
	@echo -e "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=cursor$(NC)"
	@bash "$(SCRIPT_DIR)/install/apps/install_cursor.sh"

install-brave: ## [DÉPRÉCIÉ] Installer Brave (utiliser: make install APP=brave)
	@echo -e "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=brave$(NC)"
	@bash "$(SCRIPT_DIR)/install/apps/install_brave.sh"

install-yay: ## [DÉPRÉCIÉ] Installer yay (utiliser: make install APP=yay)
	@echo -e "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=yay$(NC)"
	@bash "$(SCRIPT_DIR)/install/tools/install_yay.sh"

install-nvm: ## [DÉPRÉCIÉ] Installer NVM (utiliser: make install APP=nvm)
	@echo -e "$(YELLOW)⚠️  Cette commande est dépréciée. Utilisez: make install APP=nvm$(NC)"
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
	@echo -e "$(BLUE)Shell actuel:$(NC)"
	@echo "  Shell: $$SHELL"
	@echo "  Nom: $$(basename "$$SHELL")"
	@echo "  Version: $$($$SHELL --version 2>/dev/null | head -n1 || echo "non disponible")"
	@echo ""
	@echo -e "$(BLUE)Shells disponibles:$(NC)"
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
	@echo -e "$(BLUE)🧪 Test complet des dotfiles...$(NC)"
	@if [ -f "$(SCRIPT_DIR)/test/test_dotfiles.sh" ]; then \
		bash "$(SCRIPT_DIR)/test/test_dotfiles.sh"; \
	else \
		echo -e "$(YELLOW)⚠️  Script de test non trouvé$(NC)"; \
		echo -e "$(YELLOW)   Création du script de test...$(NC)"; \
		make test-syntax test-managers test-scripts test-libs test-zshrc test-alias; \
	fi

test-syntax: ## Tester la syntaxe de tous les scripts
	@echo -e "$(BLUE)🔍 Test de syntaxe des scripts...$(NC)"
	@echo ""
	@echo -e "$(GREEN)Test syntaxe Zsh (managers):$(NC)"
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
	@echo -e "$(GREEN)Test syntaxe Bash (scripts config):$(NC)"
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
	@echo -e "$(GREEN)Test syntaxe bibliothèques:$(NC)"
	@if [ -f "$(SCRIPT_DIR)/lib/common.sh" ]; then \
		if bash -n "$(SCRIPT_DIR)/lib/common.sh" 2>/dev/null; then \
			echo "  ✓ common.sh"; \
		else \
			echo "  ✗ common.sh"; \
		fi; \
	fi

test-managers: ## Tester tous les managers
	@echo -e "$(BLUE)🔍 Test des managers...$(NC)"
	@for manager in pathman netman aliaman miscman searchman cyberman devman gitman helpman configman installman fileman virtman manman moduleman; do \
		if [ -f "$(DOTFILES_DIR)/zsh/functions/$$manager.zsh" ]; then \
			echo "  ✓ $$manager existe"; \
		else \
			echo "  ✗ $$manager manquant"; \
		fi; \
	done
	@echo ""
	@echo -e "$(GREEN)Structures modulaires:$(NC)"
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
		echo -e "$(YELLOW)⚠️  Usage: make test-manager MANAGER=<nom>$(NC)"; \
		echo -e "$(YELLOW)   Exemples: make test-manager MANAGER=aliaman$(NC)"; \
		echo -e "$(YELLOW)            make test-manager MANAGER=cyberman$(NC)"; \
		exit 1; \
	fi
	@echo -e "$(BLUE)🔍 Test du manager: $(MANAGER)$(NC)"
	@if [ -f "$(DOTFILES_DIR)/zsh/functions/$(MANAGER).zsh" ]; then \
		echo -e "$(GREEN)✓ Fichier trouvé$(NC)"; \
		if zsh -n "$(DOTFILES_DIR)/zsh/functions/$(MANAGER).zsh" 2>/dev/null; then \
			echo -e "$(GREEN)✓ Syntaxe valide$(NC)"; \
		else \
			echo -e "$(RED)✗ Erreur de syntaxe$(NC)"; \
			zsh -n "$(DOTFILES_DIR)/zsh/functions/$(MANAGER).zsh" 2>&1 || true; \
		fi; \
	else \
		echo -e "$(RED)✗ Fichier non trouvé$(NC)"; \
	fi

test-scripts: ## Tester les scripts de configuration
	@echo -e "$(BLUE)🔍 Test des scripts de configuration...$(NC)"
	@echo -e "$(GREEN)Scripts configman:$(NC)"
	@find "$(DOTFILES_DIR)/zsh/functions/configman/modules" -name "*.sh" 2>/dev/null | while read script; do \
		if bash -n "$$script" 2>/dev/null; then \
			echo "  ✓ $$(basename $$script)"; \
		else \
			echo "  ✗ $$(basename $$script)"; \
		fi; \
	done
	@echo -e "$(GREEN)Scripts virtman:$(NC)"
	@find "$(DOTFILES_DIR)/zsh/functions/virtman/modules" -name "*.sh" 2>/dev/null | while read script; do \
		if bash -n "$$script" 2>/dev/null; then \
			echo "  ✓ $$(basename $$script)"; \
		else \
			echo "  ✗ $$(basename $$script)"; \
		fi; \
	done

test-libs: ## Tester les bibliothèques communes
	@echo -e "$(BLUE)🔍 Test des bibliothèques communes...$(NC)"
	@if [ -f "$(SCRIPT_DIR)/lib/common.sh" ]; then \
		echo -e "$(GREEN)✓ common.sh existe$(NC)"; \
		if bash -n "$(SCRIPT_DIR)/lib/common.sh" 2>/dev/null; then \
			echo -e "$(GREEN)✓ Syntaxe valide$(NC)"; \
		else \
			echo -e "$(RED)✗ Erreur de syntaxe$(NC)"; \
		fi; \
	else \
		echo -e "$(RED)✗ common.sh non trouvé$(NC)"; \
	fi
	@if [ -f "$(SCRIPT_DIR)/lib/actions_logger.sh" ]; then \
		echo -e "$(GREEN)✓ actions_logger.sh existe$(NC)"; \
	fi
	@if [ -f "$(SCRIPT_DIR)/lib/install_logger.sh" ]; then \
		echo -e "$(GREEN)✓ install_logger.sh existe$(NC)"; \
	fi

test-zshrc: ## Tester zshrc_custom
	@echo -e "$(BLUE)🔍 Test de zshrc_custom...$(NC)"
	@if [ -f "$(DOTFILES_DIR)/zsh/zshrc_custom" ]; then \
		echo -e "$(GREEN)✓ zshrc_custom existe$(NC)"; \
		if zsh -n "$(DOTFILES_DIR)/zsh/zshrc_custom" 2>/dev/null; then \
			echo -e "$(GREEN)✓ Syntaxe valide$(NC)"; \
		else \
			echo -e "$(RED)✗ Erreur de syntaxe$(NC)"; \
			zsh -n "$(DOTFILES_DIR)/zsh/zshrc_custom" 2>&1 | head -5 || true; \
		fi; \
		if grep -q "module_status" "$(DOTFILES_DIR)/zsh/zshrc_custom" 2>/dev/null; then \
			echo -e "$(GREEN)✓ Variable 'status' corrigée (module_status)$(NC)"; \
		else \
			if grep -E "local status=|status=" "$(DOTFILES_DIR)/zsh/zshrc_custom" 2>/dev/null | grep -v "module_status" | grep -v "#"; then \
				echo -e "$(YELLOW)⚠️  Variable 'status' potentiellement en conflit$(NC)"; \
			else \
				echo -e "$(GREEN)✓ Pas de conflit de variable 'status'$(NC)"; \
			fi; \
		fi; \
	else \
		echo -e "$(RED)✗ zshrc_custom non trouvé$(NC)"; \
	fi

test-alias: ## Tester les alias
	@echo -e "$(BLUE)🔍 Test des alias...$(NC)"
	@if [ -f "$(DOTFILES_DIR)/zsh/aliases.zsh" ]; then \
		echo -e "$(GREEN)✓ aliases.zsh existe$(NC)"; \
		if zsh -n "$(DOTFILES_DIR)/zsh/aliases.zsh" 2>/dev/null; then \
			echo -e "$(GREEN)✓ Syntaxe valide$(NC)"; \
		else \
			echo -e "$(RED)✗ Erreur de syntaxe$(NC)"; \
		fi; \
		if grep -q "alias_status" "$(DOTFILES_DIR)/zsh/functions/aliaman.zsh" 2>/dev/null; then \
			echo -e "$(GREEN)✓ aliaman: variable 'status' corrigée (alias_status)$(NC)"; \
		else \
			if grep -E "local status=|status=" "$(DOTFILES_DIR)/zsh/functions/aliaman.zsh" 2>/dev/null | grep -v "alias_status" | grep -v "#"; then \
				echo -e "$(YELLOW)⚠️  aliaman: Variable 'status' potentiellement en conflit$(NC)"; \
			else \
				echo -e "$(GREEN)✓ aliaman: Pas de conflit de variable 'status'$(NC)"; \
			fi; \
		fi; \
	else \
		echo -e "$(YELLOW)⚠️  aliases.zsh non trouvé (optionnel)$(NC)"; \
	fi

################################################################################
# DOCKER - Tests dans environnement conteneurisé
################################################################################

# Préfixe pour isoler les conteneurs dotfiles des autres
DOTFILES_DOCKER_PREFIX = dotfiles-test
DOTFILES_CONTAINER = $(DOTFILES_DOCKER_PREFIX)-container
DOTFILES_IMAGE = $(DOTFILES_DOCKER_PREFIX)-image:latest

docker-build: ## Construire l'image Docker pour tester les dotfiles
	@echo -e "$(BLUE)🔨 Construction de l'image Docker (isolée avec préfixe)...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		DOCKER_BUILDKIT=0 docker build -t $(DOTFILES_IMAGE) . && \
		echo -e "$(GREEN)✓ Image Docker construite avec succès (isolée: $(DOTFILES_IMAGE))$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

docker-run: ## Lancer un conteneur Docker interactif pour tester les dotfiles
	@echo -e "$(BLUE)🚀 Lancement du conteneur Docker (isolé avec préfixe)...$(NC)"
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
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

docker-compose-up: ## Lancer avec docker-compose (isolé avec préfixe)
	@echo -e "$(BLUE)🚀 Lancement avec docker-compose (isolé avec préfixe)...$(NC)"
	@if command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1; then \
		docker compose -p $(DOTFILES_DOCKER_PREFIX) up -d && \
		docker compose -p $(DOTFILES_DOCKER_PREFIX) exec dotfiles-test /bin/zsh; \
	else \
		echo -e "$(YELLOW)⚠️  docker-compose n'est pas installé$(NC)"; \
		exit 1; \
	fi

docker-test: docker-build ## Tester les dotfiles dans Docker (build + run, isolé)
	@echo -e "$(BLUE)🧪 Test des dotfiles dans Docker (isolé avec préfixe)...$(NC)"
	@docker run --rm \
		--name $(DOTFILES_CONTAINER) \
		-v "$(PWD):/root/dotfiles:ro" \
		$(DOTFILES_IMAGE) \
		/bin/zsh -c "source /root/dotfiles/zsh/zshrc_custom && echo '✓ Dotfiles chargés avec succès' && zsh -c 'type installman >/dev/null && echo \"✓ installman disponible\" || echo \"✗ installman non disponible\"'"

docker-stop: ## Arrêter UNIQUEMENT les conteneurs Docker dotfiles-test
	@echo -e "$(BLUE)🛑 Arrêt UNIQUEMENT des conteneurs Docker dotfiles-test...$(NC)"
	@docker ps --filter "name=$(DOTFILES_DOCKER_PREFIX)" --format "{{.Names}}" | xargs -r docker stop 2>/dev/null || echo -e "$(YELLOW)⚠️  Aucun conteneur dotfiles-test en cours$(NC)"
	@docker compose -p $(DOTFILES_DOCKER_PREFIX) down 2>/dev/null || true

docker-clean: ## Nettoyer UNIQUEMENT les images et volumes Docker dotfiles-test
	@echo -e "$(BLUE)🧹 Nettoyage UNIQUEMENT des conteneurs/images/volumes dotfiles-test...$(NC)"
	@echo -e "$(YELLOW)⚠️  Vos autres conteneurs Docker ne seront PAS touchés$(NC)"
	@docker ps -a --filter "name=$(DOTFILES_DOCKER_PREFIX)" --format "{{.Names}}" | xargs -r docker stop 2>/dev/null || true
	@docker ps -a --filter "name=$(DOTFILES_DOCKER_PREFIX)" --format "{{.Names}}" | xargs -r docker rm 2>/dev/null || true
	@docker images --filter "reference=$(DOTFILES_DOCKER_PREFIX)*" --format "{{.Repository}}:{{.Tag}}" | xargs -r docker rmi 2>/dev/null || true
	@docker compose -p $(DOTFILES_DOCKER_PREFIX) down -v 2>/dev/null || true
	@echo -e "$(GREEN)✓ Nettoyage terminé (uniquement dotfiles-test)$(NC)"

docker-shell: ## Ouvrir un shell dans le conteneur dotfiles-test en cours d'exécution
	@echo -e "$(BLUE)🐚 Ouverture d'un shell dans le conteneur dotfiles-test...$(NC)"
	@docker exec -it $(DOTFILES_CONTAINER) /bin/zsh 2>/dev/null || docker compose -p $(DOTFILES_DOCKER_PREFIX) exec dotfiles-test /bin/zsh 2>/dev/null || echo -e "$(YELLOW)⚠️  Aucun conteneur dotfiles-test en cours d'exécution$(NC)"

docker-test-auto: ## Tester l'installation complète et automatique dans Docker isolé
	@echo -e "$(BLUE)🧪 Test d'installation automatique complète dans Docker...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		if [ -f "test-docker.sh" ]; then \
			bash test-docker.sh; \
		else \
			echo -e "$(YELLOW)⚠️  Script test-docker.sh non trouvé$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

docker-build-test: ## Construire l'image Docker de test automatique (isolée)
	@echo -e "$(BLUE)🔨 Construction de l'image Docker de test (isolée avec préfixe)...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		DOCKER_BUILDKIT=0 docker build -f Dockerfile.test -t $(DOTFILES_DOCKER_PREFIX):auto . && \
		echo -e "$(GREEN)✓ Image Docker de test construite avec succès (isolée: $(DOTFILES_DOCKER_PREFIX):auto)$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

docker-start: ## Démarrer un conteneur Docker interactif pour tester les dotfiles (après docker-build-test)
	@echo -e "$(BLUE)🚀 Démarrage d'un conteneur Docker interactif...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "$(DOTFILES_DOCKER_PREFIX):auto"; then \
			echo -e "$(GREEN)✓ Image $(DOTFILES_DOCKER_PREFIX):auto trouvée$(NC)"; \
			echo ""; \
			echo -e "$(CYAN)🐚 Choisissez le shell:$(NC)"; \
			echo "  1) zsh (recommandé - toutes les fonctionnalités)"; \
			echo "  2) bash (test de compatibilité basique)"; \
			echo "  3) fish (test de compatibilité basique)"; \
			echo ""; \
			read -p "Votre choix [défaut: 1 (zsh)]: " shell_choice; \
			shell_choice=$${shell_choice:-1}; \
			case "$$shell_choice" in \
				1) SELECTED_SHELL_CMD="/bin/zsh" ;; \
				2) SELECTED_SHELL_CMD="/bin/bash" ;; \
				3) SELECTED_SHELL_CMD="/usr/bin/fish" ;; \
				*) SELECTED_SHELL_CMD="/bin/zsh" ;; \
			esac; \
			echo -e "$(GREEN)✓ Shell: $$SELECTED_SHELL_CMD$(NC)"; \
			docker run -it --rm \
				--name $(DOTFILES_CONTAINER) \
				-v "$(PWD):/root/dotfiles:ro" \
				-v $(DOTFILES_DOCKER_PREFIX)-config:/root/.config \
				-v $(DOTFILES_DOCKER_PREFIX)-ssh:/root/.ssh \
				-e HOME=/root \
				-e DOTFILES_DIR=/root/dotfiles \
				-e TERM=xterm-256color \
				$(DOTFILES_DOCKER_PREFIX):auto \
				$$SELECTED_SHELL_CMD; \
		else \
			echo -e "$(YELLOW)⚠️  Image $(DOTFILES_DOCKER_PREFIX):auto non trouvée$(NC)"; \
			echo -e "$(YELLOW)   Construisez d'abord l'image avec: make docker-build-test$(NC)"; \
			echo -e "$(YELLOW)   Ou utilisez: make docker-test-auto$(NC)"; \
			exit 1; \
		fi; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

# =============================================================================
# NOUVELLES COMMANDES DOCKER - Tests multi-distributions
# =============================================================================

docker-vm: ## Lancer conteneur de test dotfiles-vm (interactif, avec gestion conteneurs existants)
	@echo -e "$(BLUE)🚀 Lancement du conteneur dotfiles-vm...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		# Vérifier si un conteneur dotfiles-vm existe \
		if docker ps -a --format '{{.Names}}' | grep -q '^dotfiles-vm$$'; then \
			CONTAINER_STATUS=$$(docker ps --format '{{.Names}}' | grep -q '^dotfiles-vm$$' && echo "running" || echo "stopped"); \
			echo -e "$(CYAN)📦 Conteneur dotfiles-vm existant détecté ($$CONTAINER_STATUS)$(NC)"; \
			IMAGE_NAME=$$(docker inspect --format='{{.Config.Image}}' dotfiles-vm 2>/dev/null || echo "unknown"); \
			CONTAINER_ARCH=$$(docker inspect --format='{{.Architecture}}' dotfiles-vm 2>/dev/null || echo ""); \
			HOST_ARCH=$$(uname -m); \
			# Normaliser les architectures (x86_64 = amd64, arm64 = aarch64) \
			case "$$HOST_ARCH" in \
				x86_64) NORMALIZED_HOST_ARCH="amd64" ;; \
				arm64) NORMALIZED_HOST_ARCH="aarch64" ;; \
				*) NORMALIZED_HOST_ARCH="$$HOST_ARCH" ;; \
			esac; \
			case "$$CONTAINER_ARCH" in \
				x86_64) NORMALIZED_CONTAINER_ARCH="amd64" ;; \
				arm64) NORMALIZED_CONTAINER_ARCH="aarch64" ;; \
				"") NORMALIZED_CONTAINER_ARCH="" ;; \
				*) NORMALIZED_CONTAINER_ARCH="$$CONTAINER_ARCH" ;; \
			esac; \
			echo -e "$(BLUE)   Image: $$IMAGE_NAME$(NC)"; \
			if [ -n "$$CONTAINER_ARCH" ]; then \
				echo -e "$(BLUE)   Architecture: $$CONTAINER_ARCH (hôte: $$HOST_ARCH)$(NC)"; \
			fi; \
			INTEGRITY_CHECK=0; \
			# Vérifier l'architecture seulement si elle est définie et différente \
			if [ -n "$$NORMALIZED_CONTAINER_ARCH" ] && [ "$$NORMALIZED_CONTAINER_ARCH" != "$$NORMALIZED_HOST_ARCH" ]; then \
				echo -e "$(YELLOW)⚠️  Architecture différente détectée (conteneur: $$CONTAINER_ARCH, hôte: $$HOST_ARCH)$(NC)"; \
				INTEGRITY_CHECK=1; \
			fi; \
			if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$$IMAGE_NAME$$"; then \
				echo -e "$(YELLOW)⚠️  L'image n'existe plus$(NC)"; \
				INTEGRITY_CHECK=1; \
			fi; \
			if [ "$$INTEGRITY_CHECK" = "1" ]; then \
				echo -e "$(YELLOW)⚠️  Problèmes d'intégrité détectés$(NC)"; \
				echo ""; \
			fi; \
			echo ""; \
			echo -e "$(CYAN)Que souhaitez-vous faire ?$(NC)"; \
			echo "  1) Utiliser le conteneur existant (recharger dotfiles)"; \
			echo "  2) Vérifier l'intégrité du conteneur"; \
			echo "  3) Créer un nouveau conteneur (supprimer l'ancien)"; \
			echo "  4) Supprimer le conteneur existant"; \
			echo "  5) Annuler"; \
			echo ""; \
			read -p "Choix [défaut: 1]: " action_choice; \
			action_choice=$${action_choice:-1}; \
			case "$$action_choice" in \
				1) \
					echo -e "$(GREEN)✓ Utilisation du conteneur existant$(NC)"; \
					if [ "$$CONTAINER_STATUS" = "stopped" ]; then \
						echo -e "$(BLUE)🔄 Démarrage du conteneur...$(NC)"; \
						# Attendre un peu après le démarrage pour que le conteneur soit prêt \
						if docker start dotfiles-vm >/dev/null 2>&1; then \
							sleep 1; \
							# Vérifier que le conteneur est bien démarré \
							if ! docker ps --format '{{.Names}}' | grep -q '^dotfiles-vm$$'; then \
								echo -e "$(RED)❌ Le conteneur s'est arrêté immédiatement$(NC)"; \
								echo -e "$(YELLOW)   Le conteneur est peut-être corrompu$(NC)"; \
								echo -e "$(YELLOW)   Recommandation: Recréer le conteneur (option 3)$(NC)"; \
								exit 1; \
							fi; \
						else \
							echo -e "$(RED)❌ Impossible de démarrer le conteneur$(NC)"; \
							echo -e "$(YELLOW)   Le conteneur est peut-être corrompu$(NC)"; \
							echo -e "$(YELLOW)   Recommandation: Recréer le conteneur (option 3)$(NC)"; \
							exit 1; \
						fi; \
					fi; \
					echo -e "$(BLUE)🔄 Rechargement des dotfiles...$(NC)"; \
					docker exec -it dotfiles-vm /bin/zsh -c " \
						export DOTFILES_DIR=/root/dotfiles; \
						export DOTFILES_ZSH_PATH=/root/dotfiles/zsh; \
						if [ -f /root/dotfiles/zsh/zshrc_custom ]; then \
							. /root/dotfiles/zsh/zshrc_custom 2>/dev/null || true; \
						fi; \
						exec /bin/zsh" 2>/dev/null || { \
							echo -e "$(RED)❌ Erreur lors de l'exécution$(NC)"; \
							echo -e "$(YELLOW)   Le conteneur est peut-être corrompu$(NC)"; \
							echo -e "$(YELLOW)   Recommandation: Recréer le conteneur (option 3)$(NC)"; \
							exit 1; \
						}; \
					exit 0 ;; \
				2) \
					echo -e "$(BLUE)🔍 Vérification de l'intégrité...$(NC)"; \
					if [ -f "$(PWD)/scripts/test/docker/check_container_integrity.sh" ]; then \
						bash "$(PWD)/scripts/test/docker/check_container_integrity.sh" dotfiles-vm; \
						INTEGRITY_RESULT=$$?; \
						echo ""; \
						if [ $$INTEGRITY_RESULT -eq 0 ]; then \
							echo -e "$(GREEN)✅ Conteneur intègre, vous pouvez l'utiliser$(NC)"; \
						else \
							echo -e "$(YELLOW)⚠️  Problèmes détectés, recommandation: recréer le conteneur$(NC)"; \
						fi; \
					else \
						echo -e "$(YELLOW)⚠️  Script de vérification non trouvé$(NC)"; \
					fi; \
					exit 0 ;; \
				3) \
					echo -e "$(YELLOW)⚠️  Suppression de l'ancien conteneur...$(NC)"; \
					docker stop dotfiles-vm 2>/dev/null || true; \
					docker rm dotfiles-vm 2>/dev/null || true; \
					echo -e "$(GREEN)✓ Ancien conteneur supprimé$(NC)"; \
					;; \
				4) \
					echo -e "$(YELLOW)⚠️  Suppression du conteneur...$(NC)"; \
					docker stop dotfiles-vm 2>/dev/null || true; \
					docker rm dotfiles-vm 2>/dev/null || true; \
					echo -e "$(GREEN)✓ Conteneur supprimé$(NC)"; \
					exit 0 ;; \
				5|*) \
					echo -e "$(YELLOW)Annulé$(NC)"; \
					exit 0 ;; \
			esac; \
		fi; \
		echo -e "$(CYAN)Distribution:$(NC)"; \
		echo "  1) Arch Linux (défaut)"; \
		echo "  2) Ubuntu"; \
		echo "  3) Debian"; \
		echo "  4) Gentoo $(YELLOW)⚠️  TRÈS LENT (compile depuis sources)$(NC)"; \
		echo "  5) Alpine"; \
		echo "  6) Fedora"; \
		echo "  7) CentOS"; \
		echo "  8) openSUSE"; \
		echo ""; \
		read -p "Choix [défaut: 1]: " distro_choice; \
		distro_choice=$${distro_choice:-1}; \
		case "$$distro_choice" in \
			1) DISTRO="arch" DOCKERFILE="scripts/test/docker/Dockerfile.test" ;; \
			2) DISTRO="ubuntu" DOCKERFILE="scripts/test/docker/Dockerfile.ubuntu" ;; \
			3) DISTRO="debian" DOCKERFILE="scripts/test/docker/Dockerfile.debian" ;; \
			4) DISTRO="gentoo" DOCKERFILE="scripts/test/docker/Dockerfile.gentoo"; \
				echo -e "$(YELLOW)⚠️  ATTENTION: Gentoo compile depuis les sources$(NC)"; \
				echo -e "$(YELLOW)   Cela peut prendre 30-60 minutes ou plus$(NC)"; \
				echo -e "$(YELLOW)   Recommandé: Utilisez Arch/Ubuntu/Debian pour des tests rapides$(NC)"; \
				read -p "Continuer avec Gentoo? (o/N): " confirm_gentoo; \
				case "$$confirm_gentoo" in \
					[oO]) ;; \
					*) echo -e "$(YELLOW)Annulé$(NC)"; exit 0 ;; \
				esac ;; \
			5) DISTRO="alpine" DOCKERFILE="scripts/test/docker/Dockerfile.alpine" ;; \
			6) DISTRO="fedora" DOCKERFILE="scripts/test/docker/Dockerfile.fedora" ;; \
			7) DISTRO="centos" DOCKERFILE="scripts/test/docker/Dockerfile.centos" ;; \
			8) DISTRO="opensuse" DOCKERFILE="scripts/test/docker/Dockerfile.opensuse" ;; \
			*) DISTRO="arch" DOCKERFILE="scripts/test/docker/Dockerfile.test" ;; \
		esac; \
		IMAGE_NAME="dotfiles-vm-$$DISTRO"; \
		echo -e "$(GREEN)✓ Distribution: $$DISTRO$(NC)"; \
		if [ "$$DISTRO" = "gentoo" ]; then \
			echo -e "$(YELLOW)⏳ Construction en cours... (peut prendre 30-60 minutes)$(NC)"; \
		else \
			echo -e "$(BLUE)🔨 Construction de l'image...$(NC)"; \
		fi; \
		DOCKER_BUILDKIT=0 docker build -f $$DOCKERFILE -t $$IMAGE_NAME:latest . || exit 1; \
		echo ""; \
		echo -e "$(CYAN)Options:$(NC)"; \
		echo "  1) Conteneur persistant (conserve les modifications)"; \
		echo "  2) Conteneur éphémère (reset à la sortie)"; \
		echo ""; \
		read -p "Choix [défaut: 1 (persistant)]: " reset_choice; \
		reset_choice=$${reset_choice:-1}; \
		if [ "$$reset_choice" = "2" ]; then \
			echo -e "$(YELLOW)⚠️  Mode éphémère: les modifications seront perdues$(NC)"; \
			RM_FLAG="--rm"; \
		else \
			echo -e "$(GREEN)✓ Mode persistant: les modifications seront conservées$(NC)"; \
			RM_FLAG=""; \
		fi; \
		echo ""; \
		echo -e "$(BLUE)🚀 Démarrage du conteneur...$(NC)"; \
		# Vérifier que l'image existe avant de lancer \
		if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "^$$IMAGE_NAME:latest$$"; then \
			echo -e "$(RED)❌ L'image $$IMAGE_NAME:latest n'existe plus$(NC)"; \
			echo -e "$(YELLOW)   Reconstruction de l'image...$(NC)"; \
			DOCKER_BUILDKIT=0 docker build -f $$DOCKERFILE -t $$IMAGE_NAME:latest . || exit 1; \
		fi; \
		# Vérifier l'architecture de l'image et normaliser \
		IMAGE_ARCH=$$(docker inspect --format='{{.Architecture}}' $$IMAGE_NAME:latest 2>/dev/null || echo ""); \
		HOST_ARCH=$$(uname -m); \
		# Normaliser les architectures (x86_64 = amd64, arm64 = aarch64) \
		case "$$HOST_ARCH" in \
			x86_64) NORMALIZED_HOST_ARCH="amd64" ;; \
			arm64) NORMALIZED_HOST_ARCH="aarch64" ;; \
			*) NORMALIZED_HOST_ARCH="$$HOST_ARCH" ;; \
		esac; \
		if [ -n "$$IMAGE_ARCH" ]; then \
			case "$$IMAGE_ARCH" in \
				x86_64) NORMALIZED_IMAGE_ARCH="amd64" ;; \
				arm64) NORMALIZED_IMAGE_ARCH="aarch64" ;; \
				*) NORMALIZED_IMAGE_ARCH="$$IMAGE_ARCH" ;; \
			esac; \
			# Vérifier seulement si les architectures normalisées sont différentes \
			if [ "$$NORMALIZED_IMAGE_ARCH" != "$$NORMALIZED_HOST_ARCH" ]; then \
				echo -e "$(YELLOW)⚠️  Architecture différente: image=$$IMAGE_ARCH, hôte=$$HOST_ARCH$(NC)"; \
				echo -e "$(YELLOW)   Le conteneur peut ne pas fonctionner correctement$(NC)"; \
				echo -e "$(YELLOW)   Reconstruction automatique de l'image pour votre architecture...$(NC)"; \
				DOCKER_BUILDKIT=0 docker build -f $$DOCKERFILE -t $$IMAGE_NAME:latest . || exit 1; \
				echo -e "$(GREEN)✓ Image reconstruite pour votre architecture$(NC)"; \
			fi; \
		fi; \
		docker run -it $$RM_FLAG \
			--name dotfiles-vm \
			-v "$(PWD):/root/dotfiles:rw" \
			-v dotfiles-vm-config:/root/.config \
			-v dotfiles-vm-ssh:/root/.ssh \
			-e HOME=/root \
			-e DOTFILES_DIR=/root/dotfiles \
			-e TERM=xterm-256color \
			$$IMAGE_NAME:latest \
			/bin/zsh || { \
				echo -e "$(RED)❌ Erreur lors du démarrage du conteneur$(NC)"; \
				echo -e "$(YELLOW)   Vérifiez les logs avec: docker logs dotfiles-vm$(NC)"; \
				exit 1; \
			}; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé. Installez-le avec: installman docker$(NC)"; \
		exit 1; \
	fi

docker-vm-reset: ## Réinitialiser le conteneur dotfiles-vm (supprimer et recréer)
	@if command -v docker >/dev/null 2>&1; then \
		echo -e "$(BLUE)🔄 Réinitialisation du conteneur dotfiles-vm...$(NC)"; \
		if docker ps -a --format '{{.Names}}' | grep -q '^dotfiles-vm$$'; then \
			docker stop dotfiles-vm 2>/dev/null || true; \
			docker rm dotfiles-vm 2>/dev/null || true; \
			echo -e "$(GREEN)✓ Conteneur supprimé$(NC)"; \
		else \
			echo -e "$(YELLOW)⚠️  Aucun conteneur dotfiles-vm à supprimer$(NC)"; \
		fi; \
		echo -e "$(CYAN)💡 Relancez avec: make docker-vm$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé$(NC)"; \
	fi

docker-vm-shell: ## Ouvrir un shell dans dotfiles-vm en cours
	@if command -v docker >/dev/null 2>&1; then \
		if docker ps --format '{{.Names}}' | grep -q '^dotfiles-vm$$'; then \
			echo -e "$(BLUE)🐚 Ouverture d'un shell dans dotfiles-vm...$(NC)"; \
			docker exec -it dotfiles-vm /bin/zsh; \
		elif docker ps -a --format '{{.Names}}' | grep -q '^dotfiles-vm$$'; then \
			echo -e "$(YELLOW)⚠️  Le conteneur dotfiles-vm est arrêté$(NC)"; \
			echo -e "$(CYAN)💡 Démarrez-le avec: make docker-vm$(NC)"; \
			echo -e "$(CYAN)   Ou redémarrez-le avec: docker start dotfiles-vm && make docker-vm-shell$(NC)"; \
		else \
			echo -e "$(YELLOW)⚠️  Conteneur dotfiles-vm non trouvé$(NC)"; \
			echo -e "$(CYAN)💡 Créez-le avec: make docker-vm$(NC)"; \
		fi; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé$(NC)"; \
	fi

docker-vm-stop: ## Arrêter le conteneur dotfiles-vm
	@if command -v docker >/dev/null 2>&1; then \
		if docker ps --format '{{.Names}}' | grep -q '^dotfiles-vm$$'; then \
			echo -e "$(BLUE)🛑 Arrêt du conteneur dotfiles-vm...$(NC)"; \
			docker stop dotfiles-vm 2>/dev/null && echo -e "$(GREEN)✓ Conteneur arrêté$(NC)"; \
		elif docker ps -a --format '{{.Names}}' | grep -q '^dotfiles-vm$$'; then \
			echo -e "$(YELLOW)⚠️  Le conteneur dotfiles-vm est déjà arrêté$(NC)"; \
		else \
			echo -e "$(YELLOW)⚠️  Aucun conteneur dotfiles-vm trouvé$(NC)"; \
		fi; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé$(NC)"; \
	fi

docker-vm-clean: ## Nettoyer complètement dotfiles-vm (conteneur + volumes)
	@if command -v docker >/dev/null 2>&1; then \
		echo -e "$(BLUE)🧹 Nettoyage complet de dotfiles-vm...$(NC)"; \
		if docker ps -a --format '{{.Names}}' | grep -q '^dotfiles-vm$$'; then \
			docker stop dotfiles-vm 2>/dev/null || true; \
			docker rm dotfiles-vm 2>/dev/null || true; \
			echo -e "$(GREEN)✓ Conteneur supprimé$(NC)"; \
		else \
			echo -e "$(YELLOW)⚠️  Aucun conteneur dotfiles-vm à supprimer$(NC)"; \
		fi; \
		if docker volume ls --format '{{.Name}}' | grep -q '^dotfiles-vm-'; then \
			docker volume rm dotfiles-vm-config dotfiles-vm-ssh 2>/dev/null || true; \
			echo -e "$(GREEN)✓ Volumes supprimés$(NC)"; \
		fi; \
		echo -e "$(GREEN)✓ Nettoyage terminé$(NC)"; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé$(NC)"; \
	fi

docker-vm-list: ## Lister tous les conteneurs dotfiles-vm
	@if command -v docker >/dev/null 2>&1; then \
		echo -e "$(BLUE)📋 Conteneurs dotfiles-vm:$(NC)"; \
		if docker ps -a --format '{{.Names}}' | grep -q 'dotfiles-vm'; then \
			docker ps -a --filter "name=dotfiles-vm" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"; \
			echo ""; \
			echo -e "$(CYAN)💡 Commandes utiles:$(NC)"; \
			echo "  make docker-vm-shell    - Ouvrir un shell dans dotfiles-vm"; \
			echo "  make docker-vm-stop     - Arrêter dotfiles-vm"; \
			echo "  make docker-vm-clean    - Nettoyer complètement"; \
		else \
			echo -e "$(YELLOW)Aucun conteneur dotfiles-vm trouvé$(NC)"; \
		fi; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé$(NC)"; \
	fi


docker-vm-all-clean: ## Nettoyer TOUS les conteneurs dotfiles (toutes distributions)
	@echo -e "$(BLUE)🧹 Nettoyage de TOUS les conteneurs dotfiles...$(NC)"
	@echo -e "$(YELLOW)⚠️  Cette action va supprimer tous les conteneurs dotfiles-vm et dotfiles-test-*$(NC)"
	@read -p "Continuer? (o/N): " confirm; \
	if [ "$$confirm" = "o" ] || [ "$$confirm" = "O" ]; then \
		echo -e "$(BLUE)Arrêt des conteneurs...$(NC)"; \
		docker ps -a --format '{{.Names}}' | grep -E '^dotfiles' | xargs -r docker stop 2>/dev/null || true; \
		echo -e "$(BLUE)Suppression des conteneurs...$(NC)"; \
		docker ps -a --format '{{.Names}}' | grep -E '^dotfiles' | xargs -r docker rm 2>/dev/null || true; \
		echo -e "$(GREEN)✓ Tous les conteneurs dotfiles supprimés$(NC)"; \
	else \
		echo -e "$(YELLOW)Annulé$(NC)"; \
	fi

docker-vm-access: ## Accéder à un conteneur dotfiles-vm spécifique
	@echo -e "$(BLUE)🐚 Accès à un conteneur dotfiles-vm...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		echo -e "$(CYAN)Conteneurs disponibles:$(NC)"; \
		docker ps -a --filter "name=dotfiles" --format "{{.Names}}\t{{.Status}}" | nl -w2 -s') ' || echo "Aucun conteneur trouvé"; \
		echo ""; \
		read -p "Nom du conteneur (ou numéro): " container_input; \
		container_name=""; \
		if echo "$$container_input" | grep -q '^[0-9]\+$$'; then \
			container_name=$$(docker ps -a --filter "name=dotfiles" --format "{{.Names}}" | sed -n "$${container_input}p"); \
		else \
			container_name="$$container_input"; \
		fi; \
		if [ -z "$$container_name" ]; then \
			echo -e "$(RED)❌ Conteneur non trouvé$(NC)"; \
			exit 1; \
		fi; \
		if docker ps --format "{{.Names}}" | grep -q "^$$container_name$$"; then \
			echo -e "$(GREEN)✓ Ouverture du shell dans $$container_name...$(NC)"; \
			docker exec -it "$$container_name" /bin/zsh 2>/dev/null || docker exec -it "$$container_name" /bin/bash 2>/dev/null || docker exec -it "$$container_name" /bin/sh; \
		else \
			echo -e "$(YELLOW)⚠️  Conteneur arrêté, démarrage...$(NC)"; \
			docker start "$$container_name" && \
			docker exec -it "$$container_name" /bin/zsh 2>/dev/null || docker exec -it "$$container_name" /bin/bash 2>/dev/null || docker exec -it "$$container_name" /bin/sh; \
		fi; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé$(NC)"; \
	fi

docker-test-install: ## Tester l'installation complète des dotfiles (interactif: distro + shell + mode)
	@bash "$(PWD)/scripts/test/docker/test_full_install.sh"

docker-test-bootstrap: ## Tester l'installation bootstrap dans un conteneur propre
	@echo -e "$(BLUE)🧪 Test d'installation bootstrap dans conteneur propre...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		echo -e "$(CYAN)Distribution:$(NC)"; \
		echo "  1) Arch Linux"; \
		echo "  2) Ubuntu"; \
		echo "  3) Debian"; \
		echo "  4) Gentoo $(YELLOW)⚠️  TRÈS LENT (compile depuis sources)$(NC)"; \
		echo "  5) Alpine"; \
		echo "  6) Fedora"; \
		echo "  7) CentOS"; \
		echo "  8) openSUSE"; \
		echo ""; \
		read -p "Choix [défaut: 1]: " distro_choice; \
		distro_choice=$${distro_choice:-1}; \
		case "$$distro_choice" in \
			1) DISTRO="arch" DOCKERFILE="scripts/test/docker/Dockerfile.test" ;; \
			2) DISTRO="ubuntu" DOCKERFILE="scripts/test/docker/Dockerfile.ubuntu" ;; \
			3) DISTRO="debian" DOCKERFILE="scripts/test/docker/Dockerfile.debian" ;; \
			4) DISTRO="gentoo" DOCKERFILE="scripts/test/docker/Dockerfile.gentoo"; \
				echo -e "$(YELLOW)⚠️  ATTENTION: Gentoo compile depuis les sources$(NC)"; \
				echo -e "$(YELLOW)   Cela peut prendre 30-60 minutes ou plus$(NC)"; \
				read -p "Continuer avec Gentoo? (o/N): " confirm_gentoo; \
				case "$$confirm_gentoo" in \
					[oO]) ;; \
					*) echo -e "$(YELLOW)Annulé$(NC)"; exit 0 ;; \
				esac ;; \
			5) DISTRO="alpine" DOCKERFILE="scripts/test/docker/Dockerfile.alpine" ;; \
			6) DISTRO="fedora" DOCKERFILE="scripts/test/docker/Dockerfile.fedora" ;; \
			7) DISTRO="centos" DOCKERFILE="scripts/test/docker/Dockerfile.centos" ;; \
			8) DISTRO="opensuse" DOCKERFILE="scripts/test/docker/Dockerfile.opensuse" ;; \
			*) DISTRO="arch" DOCKERFILE="scripts/test/docker/Dockerfile.test" ;; \
		esac; \
		IMAGE_NAME="dotfiles-test-$$DISTRO"; \
		echo -e "$(BLUE)🔨 Construction de l'image...$(NC)"; \
		DOCKER_BUILDKIT=0 docker build -f $$DOCKERFILE -t $$IMAGE_NAME:latest . || exit 1; \
		echo -e "$(BLUE)🚀 Test d'installation bootstrap...$(NC)"; \
		# Supprimer le conteneur existant s'il existe \
		if docker ps -a --format '{{.Names}}' | grep -q '^dotfiles-test-bootstrap$$'; then \
			echo -e "$(YELLOW)⚠️  Conteneur dotfiles-test-bootstrap existant détecté, suppression...$(NC)"; \
			docker stop dotfiles-test-bootstrap 2>/dev/null || true; \
			docker rm dotfiles-test-bootstrap 2>/dev/null || true; \
			echo -e "$(GREEN)✓ Ancien conteneur supprimé$(NC)"; \
		fi; \
		docker run --rm -it \
			--name dotfiles-test-bootstrap \
			-e HOME=/root \
			-e TERM=xterm-256color \
			$$IMAGE_NAME:latest \
			/bin/bash -c "curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash"; \
	else \
		echo -e "$(YELLOW)⚠️  Docker n'est pas installé$(NC)"; \
		exit 1; \
	fi
