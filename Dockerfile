# Dockerfile pour tester les dotfiles dans un environnement conteneurisé
FROM archlinux:latest

# Variables d'environnement
ENV DOTFILES_DIR=/root/dotfiles
ENV HOME=/root

# Installer les dépendances nécessaires (zsh, bash, fish pour tests multi-shell)
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        zsh \
        bash \
        fish \
        git \
        vim \
        curl \
        wget \
        sudo \
        base-devel \
        which \
        man-db \
        man-pages \
        openssh \
        python \
        python-pip \
        make \
        fzf

# Installer Oh My Zsh (optionnel)
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true

# Installer Powerlevel10k (optionnel)
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k 2>/dev/null || true

# Créer le répertoire dotfiles
WORKDIR /root
RUN mkdir -p ${DOTFILES_DIR}

# Copier les dotfiles dans le conteneur
COPY . ${DOTFILES_DIR}/

# Configurer ZSH pour utiliser les dotfiles
RUN if [ -f "${DOTFILES_DIR}/zsh/zshrc_custom" ]; then \
        echo "source ${DOTFILES_DIR}/zsh/zshrc_custom" >> ~/.zshrc; \
    fi

# Créer des répertoires nécessaires
RUN mkdir -p ~/.config/moduleman \
    ~/.ssh \
    ${DOTFILES_DIR}/.config/moduleman

# Exposer un port pour les tests (si nécessaire)
# EXPOSE 8080

# Commande par défaut : shell ZSH
CMD ["/bin/zsh"]

