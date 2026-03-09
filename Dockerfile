FROM ubuntu:noble

# ── Build-time arch detection ────────────────────────────────────────────────
# Docker's TARGETARCH is amd64 / arm64; we derive the convention each tool uses.
ARG TARGETARCH
ARG USERNAME=user
ARG USER_ID
ARG GROUP_ID
ARG DOCKER_GROUP_ID
ENV DEBIAN_FRONTEND=noninteractive

# ── System packages ──────────────────────────────────────────────────────────
RUN apt-get update -qq && apt-get install -y -qq \
    sudo curl ca-certificates git unzip tar gzip xz-utils \
    build-essential pkg-config libssl-dev \
    stow tmux fontconfig \
    && rm -rf /var/lib/apt/lists/*

# ── Create user with host UIDs/GIDs ──────────────────────────────────────────
RUN (id -un ${USER_ID} 2>/dev/null && userdel $(id -un ${USER_ID}) 2>/dev/null) || true \
    && groupadd -g ${GROUP_ID} ${USERNAME} \
    && useradd -u ${USER_ID} -g ${GROUP_ID} --create-home --shell /bin/bash ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && groupadd -g ${DOCKER_GROUP_ID} docker \
    && usermod -aG docker ${USERNAME}

# ── Architecture variables ───────────────────────────────────────────────────
# All install commands run as root so we resolve arch here once.
RUN set -e; \
    DPKG_ARCH=$(dpkg --print-architecture); \
    case "$DPKG_ARCH" in \
        amd64) echo "amd64"  > /tmp/GO_ARCH; echo "x86_64"  > /tmp/RUST_ARCH; echo "x64"   > /tmp/MISE_ARCH ;; \
        arm64) echo "arm64"  > /tmp/GO_ARCH; echo "aarch64" > /tmp/RUST_ARCH; echo "arm64" > /tmp/MISE_ARCH ;; \
        *)     echo "Unsupported arch: $DPKG_ARCH" && exit 1 ;; \
    esac

# ── Helper: latest GitHub release tag ────────────────────────────────────────
COPY gh-latest /usr/local/bin/gh-latest
RUN chmod +x /usr/local/bin/gh-latest

# ── Nushell ──────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest nushell/nushell); \
    curl -fsSL "https://github.com/nushell/nushell/releases/download/${VER}/nu-${VER}-${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/nu.tar.gz; \
    tar xzf /tmp/nu.tar.gz -C /tmp; \
    cp /tmp/nu-*/nu /usr/local/bin/; \
    rm -rf /tmp/nu.tar.gz /tmp/nu-*

# ── Starship ─────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest starship/starship); \
    curl -fsSL "https://github.com/starship/starship/releases/download/${VER}/starship-${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/starship.tar.gz; \
    tar xzf /tmp/starship.tar.gz -C /usr/local/bin/; \
    chmod +x /usr/local/bin/starship; \
    rm -f /tmp/starship.tar.gz

# ── Zoxide ───────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest ajeetdsouza/zoxide); \
    curl -fsSL "https://github.com/ajeetdsouza/zoxide/releases/download/${VER}/zoxide-${VER#v}-${RUST_ARCH}-unknown-linux-musl.tar.gz" -o /tmp/zoxide.tar.gz; \
    tar xzf /tmp/zoxide.tar.gz -C /usr/local/bin/ zoxide; \
    chmod +x /usr/local/bin/zoxide; \
    rm -f /tmp/zoxide.tar.gz

# ── Neovim ───────────────────────────────────────────────────────────────────
RUN set -e; \
    DPKG_ARCH=$(dpkg --print-architecture); \
    if [ "$DPKG_ARCH" = "amd64" ]; then \
        curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz; \
        tar xzf /tmp/nvim.tar.gz -C /opt/; \
        ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim; \
        rm -f /tmp/nvim.tar.gz; \
    else \
        apt-get update -qq && apt-get install -y -qq neovim && rm -rf /var/lib/apt/lists/*; \
    fi

# ── eza ──────────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest eza-community/eza); \
    curl -fsSL "https://github.com/eza-community/eza/releases/download/${VER}/eza_${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/eza.tar.gz; \
    tar xzf /tmp/eza.tar.gz -C /usr/local/bin/; \
    chmod +x /usr/local/bin/eza; \
    rm -f /tmp/eza.tar.gz

# ── fzf ──────────────────────────────────────────────────────────────────────
RUN set -e; \
    GO_ARCH=$(cat /tmp/GO_ARCH); \
    VER=$(gh-latest junegunn/fzf); \
    CLEAN_VER="${VER#v}"; \
    curl -fsSL "https://github.com/junegunn/fzf/releases/download/${VER}/fzf-${CLEAN_VER}-linux_${GO_ARCH}.tar.gz" -o /tmp/fzf.tar.gz; \
    tar xzf /tmp/fzf.tar.gz -C /usr/local/bin/; \
    chmod +x /usr/local/bin/fzf; \
    rm -f /tmp/fzf.tar.gz

# ── Carapace ─────────────────────────────────────────────────────────────────
RUN set -e; \
    GO_ARCH=$(cat /tmp/GO_ARCH); \
    VER=$(gh-latest carapace-sh/carapace-bin); \
    CLEAN_VER="${VER#v}"; \
    curl -fsSL "https://github.com/carapace-sh/carapace-bin/releases/download/${VER}/carapace-bin_${CLEAN_VER}_linux_${GO_ARCH}.tar.gz" -o /tmp/carapace.tar.gz; \
    mkdir -p /tmp/carapace-extract && tar xzf /tmp/carapace.tar.gz -C /tmp/carapace-extract; \
    cp /tmp/carapace-extract/carapace /usr/local/bin/; \
    rm -rf /tmp/carapace.tar.gz /tmp/carapace-extract

# ── direnv ───────────────────────────────────────────────────────────────────
RUN set -e; \
    GO_ARCH=$(cat /tmp/GO_ARCH); \
    VER=$(gh-latest direnv/direnv); \
    curl -fsSL "https://github.com/direnv/direnv/releases/download/${VER}/direnv.linux-${GO_ARCH}" -o /usr/local/bin/direnv; \
    chmod +x /usr/local/bin/direnv

# ── bat ──────────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest sharkdp/bat); \
    curl -fsSL "https://github.com/sharkdp/bat/releases/download/${VER}/bat-${VER}-${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/bat.tar.gz; \
    tar xzf /tmp/bat.tar.gz -C /tmp; \
    cp /tmp/bat-*/bat /usr/local/bin/; \
    rm -rf /tmp/bat.tar.gz /tmp/bat-*

# ── ripgrep ──────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest BurntSushi/ripgrep); \
    curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${VER}/ripgrep-${VER}-${RUST_ARCH}-unknown-linux-musl.tar.gz" -o /tmp/rg.tar.gz; \
    tar xzf /tmp/rg.tar.gz -C /tmp; \
    cp /tmp/ripgrep-*/rg /usr/local/bin/; \
    rm -rf /tmp/rg.tar.gz /tmp/ripgrep-*

# ── fd ───────────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest sharkdp/fd); \
    curl -fsSL "https://github.com/sharkdp/fd/releases/download/${VER}/fd-${VER}-${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/fd.tar.gz; \
    tar xzf /tmp/fd.tar.gz -C /tmp; \
    cp /tmp/fd-*/fd /usr/local/bin/; \
    rm -rf /tmp/fd.tar.gz /tmp/fd-*

# ── lazygit ──────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest jesseduffield/lazygit); \
    CLEAN_VER="${VER#v}"; \
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/${VER}/lazygit_${CLEAN_VER}_Linux_${RUST_ARCH}.tar.gz" -o /tmp/lazygit.tar.gz; \
    tar xzf /tmp/lazygit.tar.gz -C /tmp lazygit; \
    cp /tmp/lazygit /usr/local/bin/; \
    rm -rf /tmp/lazygit.tar.gz /tmp/lazygit

# ── zellij ───────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest zellij-org/zellij); \
    curl -fsSL "https://github.com/zellij-org/zellij/releases/download/${VER}/zellij-${RUST_ARCH}-unknown-linux-musl.tar.gz" -o /tmp/zellij.tar.gz; \
    tar xzf /tmp/zellij.tar.gz -C /usr/local/bin/; \
    chmod +x /usr/local/bin/zellij; \
    rm -f /tmp/zellij.tar.gz

# ── yazi ─────────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest sxyazi/yazi); \
    curl -fsSL "https://github.com/sxyazi/yazi/releases/download/${VER}/yazi-${RUST_ARCH}-unknown-linux-gnu.zip" -o /tmp/yazi.zip; \
    unzip -q /tmp/yazi.zip -d /tmp/yazi-extract; \
    cp /tmp/yazi-extract/yazi-*/yazi /usr/local/bin/; \
    cp /tmp/yazi-extract/yazi-*/ya /usr/local/bin/; \
    chmod +x /usr/local/bin/yazi /usr/local/bin/ya; \
    rm -rf /tmp/yazi.zip /tmp/yazi-extract

# ── worktrunk (wt) ───────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest max-sixty/worktrunk); \
    curl -fsSL "https://github.com/max-sixty/worktrunk/releases/download/${VER}/worktrunk-${RUST_ARCH}-unknown-linux-musl.tar.xz" -o /tmp/wt.tar.xz; \
    tar xJf /tmp/wt.tar.xz -C /tmp; \
    cp /tmp/worktrunk-*/wt /usr/local/bin/; \
    chmod +x /usr/local/bin/wt; \
    rm -rf /tmp/wt.tar.xz /tmp/worktrunk-*

# ── gh-dash ──────────────────────────────────────────────────────────────────
RUN set -e; \
    GO_ARCH=$(cat /tmp/GO_ARCH); \
    VER=$(gh-latest dlvhdr/gh-dash); \
    curl -fsSL "https://github.com/dlvhdr/gh-dash/releases/download/${VER}/gh-dash_${VER}_linux-${GO_ARCH}" -o /usr/local/bin/gh-dash; \
    chmod +x /usr/local/bin/gh-dash

# ── Node.js 22 ───────────────────────────────────────────────────────────────
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y -qq nodejs && \
    rm -rf /var/lib/apt/lists/*

# ── mise ─────────────────────────────────────────────────────────────────────
RUN set -e; \
    MISE_ARCH=$(cat /tmp/MISE_ARCH); \
    VER=$(gh-latest jdx/mise); \
    curl -fsSL "https://github.com/jdx/mise/releases/download/${VER}/mise-${VER}-linux-${MISE_ARCH}.tar.gz" -o /tmp/mise.tar.gz; \
    tar xzf /tmp/mise.tar.gz -C /tmp; \
    cp /tmp/mise/bin/mise /usr/local/bin/mise; \
    chmod +x /usr/local/bin/mise; \
    rm -rf /tmp/mise.tar.gz /tmp/mise

# ── atuin ────────────────────────────────────────────────────────────────────
RUN set -e; \
    RUST_ARCH=$(cat /tmp/RUST_ARCH); \
    VER=$(gh-latest atuinsh/atuin); \
    curl -fsSL "https://github.com/atuinsh/atuin/releases/download/${VER}/atuin-${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/atuin.tar.gz; \
    tar xzf /tmp/atuin.tar.gz -C /tmp; \
    cp /tmp/atuin-*/atuin /usr/local/bin/; \
    rm -rf /tmp/atuin.tar.gz /tmp/atuin-*

# ── JetBrainsMono Nerd Font ───────────────────────────────────────────────────
RUN set -e; \
    VER=$(gh-latest ryanoasis/nerd-fonts); \
    mkdir -p /usr/local/share/fonts/NerdFonts; \
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${VER}/JetBrainsMono.tar.xz" -o /tmp/nf.tar.xz; \
    tar xJf /tmp/nf.tar.xz -C /usr/local/share/fonts/NerdFonts; \
    fc-cache -f /usr/local/share/fonts/NerdFonts 2>/dev/null || true; \
    rm -f /tmp/nf.tar.xz

# ── TPM (Tmux Plugin Manager) ─────────────────────────────────────────────────
RUN git clone https://github.com/tmux-plugins/tpm /home/${USERNAME}/.tmux/plugins/tpm && \
    chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.tmux

# ── Copy dotfiles & stow ──────────────────────────────────────────────────────
COPY --chown=${USERNAME}:${USERNAME} . /home/${USERNAME}/dotfiles/
RUN mkdir -p /home/${USERNAME}/.config && \
    chown ${USERNAME}:${USERNAME} /home/${USERNAME}/.config && \
    cd /home/${USERNAME}/dotfiles && \
    sudo -u ${USERNAME} stow --dir=/home/${USERNAME}/dotfiles --target=/home/${USERNAME}/.config --ignore=wezterm --ignore=ghostty .
# ── Trust mise global config ──────────────────────────────────────────────────
RUN sudo -u ${USERNAME} mise trust /home/${USERNAME}/.config/mise/config.toml 2>/dev/null || true

# ── User-level init files ─────────────────────────────────────────────────────
USER ${USERNAME}
RUN mkdir -p \
        "$HOME/.cache/starship" \
        "$HOME/.cache/carapace" \
        "$HOME/.cache/mise" \
        "$HOME/.config/starship" \
        "$HOME/.config/nushell/vendor/autoload" \
        "$HOME/.local/share/atuin" \
        "$HOME/.local/share/mise/shims" && \
    wt shell-init nushell > "$HOME/.config/nushell/vendor/autoload/wt.nu"     2>/dev/null || touch "$HOME/.config/nushell/vendor/autoload/wt.nu" && \
    starship init nu       > "$HOME/.cache/starship/init.nu"                   2>/dev/null || touch "$HOME/.cache/starship/init.nu" && \
    zoxide init nushell    > "$HOME/.zoxide.nu"                                2>/dev/null || touch "$HOME/.zoxide.nu" && \
    mise activate nu       > "$HOME/.cache/mise/init.nu"                       2>/dev/null || touch "$HOME/.cache/mise/init.nu" && \
    carapace _carapace nushell > "$HOME/.cache/carapace/init.nu"               2>/dev/null || touch "$HOME/.cache/carapace/init.nu" && \
    atuin init nu          > "$HOME/.local/share/atuin/init.nu"                2>/dev/null || touch "$HOME/.local/share/atuin/init.nu"

# ── Set default shell to nushell ─────────────────────────────────────────────
USER root
RUN chsh -s "$(which nu)" ${USERNAME}

USER ${USERNAME}
WORKDIR /home/${USERNAME}
SHELL ["/usr/local/bin/nu", "-c"]
CMD ["/usr/local/bin/nu"]
