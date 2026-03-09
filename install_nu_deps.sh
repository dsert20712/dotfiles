#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Install all tools needed to run omerxx/dotfiles on Ubuntu 24
# https://github.com/omerxx/dotfiles
#
# Usage (Docker as root):    ./install_nu_deps.sh
# Usage (regular Ubuntu):    sudo ./install_nu_deps.sh
#
# Creates user "user" if needed. System tools go to /usr/local/bin,
# user-scoped tools go to ~/.<tool>/ via su.
# =============================================================================

TARGET_USER="user"
TARGET_HOME="/home/${TARGET_USER}"
ARCH=$(dpkg --print-architecture)

echo "=== omerxx/dotfiles dependency installer ==="
echo "Arch: $ARCH | User: $TARGET_USER"

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: run as root or with sudo"
    exit 1
fi

case "$ARCH" in
    amd64) GO_ARCH="amd64"; RUST_ARCH="x86_64"; KUBE_ARCH="amd64" ;;
    arm64) GO_ARCH="arm64"; RUST_ARCH="aarch64"; KUBE_ARCH="arm64" ;;
    *) echo "Unsupported arch: $ARCH"; exit 1 ;;
esac

# ============================================================
# Phase 0: User + system packages
# ============================================================
if id "$TARGET_USER" &>/dev/null; then
    echo "[ok] User '$TARGET_USER' exists"
else
    echo "[creating] User '$TARGET_USER'"
    useradd -m -s /bin/bash "$TARGET_USER"
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
    sudo curl ca-certificates git unzip tar gzip xz-utils \
    build-essential pkg-config libssl-dev \
    stow tmux \
    2>&1 | tail -1

# Passwordless sudo
if ! grep -q "^${TARGET_USER}" /etc/sudoers.d/* 2>/dev/null; then
    echo "${TARGET_USER} ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/${TARGET_USER}"
    chmod 440 "/etc/sudoers.d/${TARGET_USER}"
fi

# --- Helpers ---
as_user() { su - "$TARGET_USER" -c "$1"; }
user_has() { as_user "command -v $1" &>/dev/null; }
install_if_missing() {
    local cmd="$1" fn="$2"
    if user_has "$cmd"; then echo "[ok] $cmd"; else echo "[installing] $cmd ..."; $fn; fi
}

# ============================================================
# Phase 1: System-level binaries → /usr/local/bin
# ============================================================

# --- Nushell ---
install_nushell() {
    local ver
    ver=$(curl -s https://api.github.com/repos/nushell/nushell/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/nushell/nushell/releases/download/${ver}/nu-${ver}-${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/nu.tar.gz
    tar xzf /tmp/nu.tar.gz -C /tmp
    cp /tmp/nu-*/nu* /usr/local/bin/ 2>/dev/null || cp /tmp/nu-*/nu /usr/local/bin/
    rm -rf /tmp/nu.tar.gz /tmp/nu-*
}
install_if_missing nu install_nushell

# --- Starship ---
install_starship() { curl -fsSL https://starship.rs/install.sh | sh -s -- -y; }
install_if_missing starship install_starship

# --- Zoxide ---
install_zoxide() { curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash; }
install_if_missing zoxide install_zoxide

# --- Neovim ---
install_nvim() {
    if [ "$ARCH" = "amd64" ]; then
        curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz -o /tmp/nvim.tar.gz
        tar xzf /tmp/nvim.tar.gz -C /opt/
        ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
        rm -f /tmp/nvim.tar.gz
    else
        apt-get install -y -qq neovim
    fi
}
install_if_missing nvim install_nvim

# --- eza ---
install_eza() {
    local ver
    ver=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/eza-community/eza/releases/download/${ver}/eza_${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/eza.tar.gz
    tar xzf /tmp/eza.tar.gz -C /usr/local/bin/
    chmod +x /usr/local/bin/eza
    rm -f /tmp/eza.tar.gz
}
install_if_missing eza install_eza

# --- fzf ---
install_fzf() {
    local ver clean_ver
    ver=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep tag_name | cut -d '"' -f4)
    clean_ver="${ver#v}"
    curl -fsSL "https://github.com/junegunn/fzf/releases/download/${ver}/fzf-${clean_ver}-linux_${GO_ARCH}.tar.gz" -o /tmp/fzf.tar.gz
    tar xzf /tmp/fzf.tar.gz -C /usr/local/bin/
    chmod +x /usr/local/bin/fzf
    rm -f /tmp/fzf.tar.gz
}
install_if_missing fzf install_fzf

# --- Carapace ---
install_carapace() {
    local ver
    ver=$(curl -s https://api.github.com/repos/carapace-sh/carapace-bin/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/carapace-sh/carapace-bin/releases/download/${ver}/carapace-bin_linux_${GO_ARCH}.tar.gz" -o /tmp/carapace.tar.gz
    mkdir -p /tmp/carapace-extract && tar xzf /tmp/carapace.tar.gz -C /tmp/carapace-extract
    cp /tmp/carapace-extract/carapace /usr/local/bin/
    rm -rf /tmp/carapace.tar.gz /tmp/carapace-extract
}
install_if_missing carapace install_carapace

# --- direnv ---
install_direnv() {
    local ver
    ver=$(curl -s https://api.github.com/repos/direnv/direnv/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/direnv/direnv/releases/download/${ver}/direnv.linux-${GO_ARCH}" -o /usr/local/bin/direnv
    chmod +x /usr/local/bin/direnv
}
install_if_missing direnv install_direnv

# --- bat (required by tmux-sessionx) ---
install_bat() {
    local ver clean_ver
    ver=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep tag_name | cut -d '"' -f4)
    clean_ver="${ver#v}"
    curl -fsSL "https://github.com/sharkdp/bat/releases/download/${ver}/bat-${clean_ver}-${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/bat.tar.gz
    tar xzf /tmp/bat.tar.gz -C /tmp
    cp /tmp/bat-*/bat /usr/local/bin/
    rm -rf /tmp/bat.tar.gz /tmp/bat-*
}
install_if_missing bat install_bat

# --- ripgrep (nvim telescope) ---
install_rg() {
    local ver
    ver=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/BurntSushi/ripgrep/releases/download/${ver}/ripgrep-${ver}-${RUST_ARCH}-unknown-linux-musl.tar.gz" -o /tmp/rg.tar.gz
    tar xzf /tmp/rg.tar.gz -C /tmp
    cp /tmp/ripgrep-*/rg /usr/local/bin/
    rm -rf /tmp/rg.tar.gz /tmp/ripgrep-*
}
install_if_missing rg install_rg

# --- fd (nvim telescope) ---
install_fd() {
    local ver
    ver=$(curl -s https://api.github.com/repos/sharkdp/fd/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/sharkdp/fd/releases/download/${ver}/fd-${ver}-${RUST_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/fd.tar.gz
    tar xzf /tmp/fd.tar.gz -C /tmp
    cp /tmp/fd-*/fd /usr/local/bin/
    rm -rf /tmp/fd.tar.gz /tmp/fd-*
}
install_if_missing fd install_fd

# --- lazygit (nvim) ---
install_lazygit() {
    local ver clean_ver
    ver=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep tag_name | cut -d '"' -f4)
    clean_ver="${ver#v}"
    curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/${ver}/lazygit_${clean_ver}_Linux_${RUST_ARCH}.tar.gz" -o /tmp/lazygit.tar.gz
    tar xzf /tmp/lazygit.tar.gz -C /tmp lazygit
    cp /tmp/lazygit /usr/local/bin/
    rm -rf /tmp/lazygit.tar.gz /tmp/lazygit
}
install_if_missing lazygit install_lazygit

# --- zellij ---
install_zellij() {
    local ver
    ver=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/zellij-org/zellij/releases/download/${ver}/zellij-${RUST_ARCH}-unknown-linux-musl.tar.gz" -o /tmp/zellij.tar.gz
    tar xzf /tmp/zellij.tar.gz -C /usr/local/bin/
    chmod +x /usr/local/bin/zellij
    rm -f /tmp/zellij.tar.gz
}
install_if_missing zellij install_zellij

# --- yazi (terminal file manager) ---
install_yazi() {
    local ver
    ver=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/sxyazi/yazi/releases/download/${ver}/yazi-${RUST_ARCH}-unknown-linux-gnu.zip" -o /tmp/yazi.zip
    unzip -q /tmp/yazi.zip -d /tmp/yazi-extract
    cp /tmp/yazi-extract/yazi-*/yazi /usr/local/bin/
    cp /tmp/yazi-extract/yazi-*/ya /usr/local/bin/
    chmod +x /usr/local/bin/yazi /usr/local/bin/ya
    rm -rf /tmp/yazi.zip /tmp/yazi-extract
}
install_if_missing yazi install_yazi

# --- worktrunk (wt) - git worktree manager ---
install_wt() {
    local ver
    ver=$(curl -s https://api.github.com/repos/max-sixty/worktrunk/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/max-sixty/worktrunk/releases/download/${ver}/worktrunk-${RUST_ARCH}-unknown-linux-musl.tar.xz" -o /tmp/wt.tar.xz
    tar xJf /tmp/wt.tar.xz -C /tmp
    cp /tmp/worktrunk-*/wt /usr/local/bin/
    chmod +x /usr/local/bin/wt
    rm -rf /tmp/wt.tar.xz /tmp/worktrunk-*
}
install_if_missing wt install_wt

# --- gh-dash (GitHub dashboard TUI) ---
install_ghdash() {
    local ver
    ver=$(curl -s https://api.github.com/repos/dlvhdr/gh-dash/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/dlvhdr/gh-dash/releases/download/${ver}/gh-dash_${ver#v}_linux-${GO_ARCH}" -o /tmp/gh-dash
    cp /tmp/gh-dash /usr/local/bin/gh-dash
    chmod +x /usr/local/bin/gh-dash
    rm -f /tmp/gh-dash
}
install_if_missing gh-dash install_ghdash

# --- kubectl ---
install_kubectl() {
    local stable
    stable=$(curl -sL https://dl.k8s.io/release/stable.txt)
    curl -fsSL "https://dl.k8s.io/release/${stable}/bin/linux/${KUBE_ARCH}/kubectl" -o /usr/local/bin/kubectl
    chmod +x /usr/local/bin/kubectl
}
install_if_missing kubectl install_kubectl

# --- kubectx + kubens ---
install_kubectx() {
    local ver
    ver=$(curl -s https://api.github.com/repos/ahmetb/kubectx/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${ver}/kubectx_${ver}_linux_${RUST_ARCH}.tar.gz" -o /tmp/kubectx.tar.gz
    curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${ver}/kubens_${ver}_linux_${RUST_ARCH}.tar.gz" -o /tmp/kubens.tar.gz
    tar xzf /tmp/kubectx.tar.gz -C /usr/local/bin/ kubectx
    tar xzf /tmp/kubens.tar.gz -C /usr/local/bin/ kubens
    rm -rf /tmp/kubectx* /tmp/kubens*
}
install_if_missing kubectx install_kubectx

# --- Node.js (needed by nvim Mason/LSP) ---
install_node() {
    local ver="22"
    curl -fsSL "https://deb.nodesource.com/setup_${ver}.x" | bash -
    apt-get install -y -qq nodejs
}
install_if_missing node install_node

# --- Nerd Font (icons for starship, eza, nvim, tmux catppuccin) ---
install_nerd_font() {
    local font_dir="/usr/local/share/fonts/NerdFonts"
    mkdir -p "$font_dir"
    local ver
    ver=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep tag_name | cut -d '"' -f4)
    curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/download/${ver}/JetBrainsMono.tar.xz" -o /tmp/nf.tar.xz
    tar xJf /tmp/nf.tar.xz -C "$font_dir"
    rm -f /tmp/nf.tar.xz
    fc-cache -f "$font_dir" 2>/dev/null || true
    echo "[ok] JetBrainsMono Nerd Font installed to $font_dir"
}
if [ ! -d "/usr/local/share/fonts/NerdFonts" ]; then
    echo "[installing] Nerd Font (JetBrainsMono) ..."
    apt-get install -y -qq fontconfig 2>&1 | tail -1
    install_nerd_font
else
    echo "[ok] Nerd Font"
fi

# ============================================================
# Phase 2: User-scoped installs
# ============================================================

# --- mise ---
if ! user_has mise; then
    echo "[installing] mise ..."
    as_user 'curl -fsSL https://mise.run | sh'
fi
echo "[ok] mise"
as_user 'mkdir -p "$HOME/.local/share/mise/shims"'

# --- Atuin ---
if ! user_has atuin; then
    echo "[installing] atuin ..."
    as_user 'curl -fsSL https://setup.atuin.sh | bash'
fi
echo "[ok] atuin"

# --- Turso ---
if ! as_user 'test -f "$HOME/.turso/turso"' 2>/dev/null; then
    echo "[installing] turso ..."
    as_user 'curl -sSfL https://get.tur.so/install.sh | bash'
fi
echo "[ok] turso"

# --- GitButler CLI (but) ---
if ! user_has but; then
    echo "[installing] gitbutler CLI ..."
    as_user 'curl -fsSL https://gitbutler.com/cli | sh'
fi
echo "[ok] gitbutler CLI (but)"

# --- TPM (Tmux Plugin Manager) ---
TPM_DIR="${TARGET_HOME}/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    echo "[installing] TPM (tmux plugin manager) ..."
    as_user 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'
fi
echo "[ok] TPM"

# ============================================================
# Phase 3: Clone dotfiles + stow
# ============================================================
DOTFILES_DIR="${TARGET_HOME}/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    echo "[cloning] omerxx/dotfiles ..."
    as_user 'git clone https://github.com/omerxx/dotfiles.git ~/dotfiles'
fi
echo "[ok] dotfiles repo"

# ============================================================
# Phase 4: Create dirs, generate init files
# ============================================================
echo ""
echo "=== Generating nushell init files ==="

as_user 'mkdir -p "$HOME/.cache/starship" "$HOME/.cache/carapace" "$HOME/.cache/mise"'
as_user 'mkdir -p "$HOME/.config/starship" "$HOME/.config/nushell/vendor/autoload"'
as_user 'mkdir -p "$HOME/.local/share/atuin"'

as_user 'wt shell-init nushell > "$HOME/.config/nushell/vendor/autoload/wt.nu" 2>/dev/null || touch "$HOME/.config/nushell/vendor/autoload/wt.nu"'
as_user '[ -f "$HOME/.config/starship/starship.toml" ] || touch "$HOME/.config/starship/starship.toml"'

as_user 'starship init nu > "$HOME/.cache/starship/init.nu" 2>/dev/null || touch "$HOME/.cache/starship/init.nu"'
as_user 'zoxide init nushell > "$HOME/.zoxide.nu" 2>/dev/null || touch "$HOME/.zoxide.nu"'
as_user 'export PATH="$HOME/.local/bin:$PATH"; mise activate nu > "$HOME/.cache/mise/init.nu" 2>/dev/null || touch "$HOME/.cache/mise/init.nu"'
as_user 'carapace _carapace nushell > "$HOME/.cache/carapace/init.nu" 2>/dev/null || touch "$HOME/.cache/carapace/init.nu"'
as_user 'export PATH="$HOME/.atuin/bin:$PATH"; atuin init nu > "$HOME/.local/share/atuin/init.nu" 2>/dev/null || touch "$HOME/.local/share/atuin/init.nu"'

# Set shell to nu
chsh -s "$(which nu)" "$TARGET_USER" 2>/dev/null || true

echo ""
echo "=== All tools installed ==="
echo ""
echo "Next steps:"
echo "  1. Run: su - $TARGET_USER"
echo "  2. cd ~/dotfiles && stow .   (symlinks configs to ~/.config)"
echo "  3. In tmux: prefix + I       (install tmux plugins via TPM)"
echo "  4. Open nvim — Mason will auto-install LSP servers"
