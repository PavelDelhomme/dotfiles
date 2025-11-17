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

.PHONY: help install setup validate rollback reset clean symlinks migrate
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
	@echo ""
	@echo "$(GREEN)Configuration:$(NC)"
	@echo "  make git-config        - Configurer Git (nom, email)"
	@echo "  make git-remote        - Configurer remote Git (SSH/HTTPS)"
	@echo "  make auto-sync         - Configurer auto-sync Git (systemd timer)"
	@echo ""
	@echo "$(GREEN)Installations spécifiques:$(NC)"
	@echo "  make install-docker   - Installer Docker & Docker Compose"
	@echo "  make install-go       - Installer Go (Golang)"
	@echo "  make install-cursor   - Installer Cursor IDE"
	@echo "  make install-brave    - Installer Brave Browser"
	@echo "  make install-yay      - Installer yay (AUR helper - Arch Linux)"
	@echo ""
	@echo "$(YELLOW)Pour plus d'options, utilisez: make setup$(NC)"
	@echo ""

install: ## Installation complète depuis zéro (bootstrap)
	@echo "$(BLUE)🚀 Installation complète des dotfiles...$(NC)"
	@if [ -f "$(DOTFILES_DIR)/bootstrap.sh" ]; then \
		bash "$(DOTFILES_DIR)/bootstrap.sh"; \
	else \
		echo "$(YELLOW)⚠️  bootstrap.sh non trouvé, clonage depuis GitHub...$(NC)"; \
		curl -fsSL https://raw.githubusercontent.com/PavelDelhomme/dotfiles/main/bootstrap.sh | bash; \
	fi

setup: ## Lancer le menu interactif setup.sh
	@echo "$(BLUE)📋 Menu interactif setup.sh...$(NC)"
	@bash "$(DOTFILES_DIR)/setup.sh"

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
	@rm -f "$(DOTFILES_DIR)/auto_sync.log" 2>/dev/null || true
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

# Installations spécifiques
install-docker: ## Installer Docker & Docker Compose
	@bash "$(SCRIPT_DIR)/install/dev/install_docker.sh"

install-go: ## Installer Go (Golang)
	@bash "$(SCRIPT_DIR)/install/dev/install_go.sh"

install-cursor: ## Installer Cursor IDE
	@bash "$(SCRIPT_DIR)/install/apps/install_cursor.sh"

install-brave: ## Installer Brave Browser
	@bash "$(SCRIPT_DIR)/install/apps/install_brave.sh"

install-yay: ## Installer yay (AUR helper - Arch Linux)
	@bash "$(SCRIPT_DIR)/install/tools/install_yay.sh"

# Alias pour compatibilité
all: install ## Alias pour install
setup-menu: setup ## Alias pour setup
check: validate ## Alias pour validate

