#!/usr/bin/env bash
set -euo pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

info()    { printf "%s\n" "${BLUE}→${NC} $*"; }
success() { printf "%s\n" "${GREEN}✓${NC} $*"; }
warn()    { printf "%s\n" "${YELLOW}!${NC} $*"; }
die()     { printf "%s\n" "${RED}✗${NC} $*"; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_CONFIG="$HOME/.config/nvim"

# ── OS detection ───────────────────────────────────────────────────────────────

OS="unknown"
[[ "$(uname)" == "Darwin" ]] && OS="macos"
[[ -f /etc/arch-release ]]   && OS="arch"
[[ "$OS" == "unknown" ]] && die "Unsupported OS — targets macOS and Arch Linux."

printf "\n%s\n\n" "${BOLD}Neovim config installer  [${OS}]${NC}"

# ── Package managers ───────────────────────────────────────────────────────────

_ensure_brew() {
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        success "Homebrew $(brew --version | head -1)"
    fi
}

_ensure_yay() {
    if command -v yay &>/dev/null; then
        success "yay $(yay --version | head -1)"
        return 0
    fi
    warn "yay (AUR helper) not found"
    read -r -p "  Install yay? Required for AUR packages. [y/N] " yn
    [[ "$yn" =~ ^[yY]$ ]] || { warn "Skipping AUR packages"; return 1; }
    info "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    local tmp
    tmp=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si)
    rm -rf "$tmp"
    success "yay installed"
}

# ── Neovim ────────────────────────────────────────────────────────────────────

_install_nvim_macos() {
    _ensure_brew
    if ! command -v nvim &>/dev/null; then
        info "Installing Neovim..."
        brew install neovim
    else
        success "Neovim $(nvim --version | head -1)"
    fi
}

_install_nvim_arch() {
    if ! command -v nvim &>/dev/null; then
        info "Installing Neovim..."
        sudo pacman -S --noconfirm neovim
    else
        success "Neovim $(nvim --version | head -1)"
    fi
}

# ── Dependencies ───────────────────────────────────────────────────────────────

_install_deps_macos() {
    local deps=(ripgrep fd node python3 rustup-init tree-sitter tree-sitter@0.25)
    for dep in "${deps[@]}"; do
        if brew list "$dep" &>/dev/null 2>&1; then
            success "$dep"
        else
            info "Installing $dep..."
            brew install "$dep"
        fi
    done
}

_install_deps_arch() {
    info "Syncing package database..."
    sudo pacman -Sy --noconfirm

    # node → nodejs, python3 → python, rustup-init → rustup, tree-sitter@0.25 → tree-sitter
    local pacman_deps=(ripgrep fd nodejs python rustup tree-sitter)
    for dep in "${pacman_deps[@]}"; do
        if pacman -Qi "$dep" &>/dev/null; then
            success "$dep"
        else
            info "Installing $dep..."
            sudo pacman -S --noconfirm "$dep"
        fi
    done

    # Ensure default rust toolchain is set up
    if ! command -v rustc &>/dev/null; then
        info "Setting up Rust toolchain..."
        rustup default stable
    fi
}

# ── Run ───────────────────────────────────────────────────────────────────────

case "$OS" in
    macos)
        _install_nvim_macos
        _install_deps_macos
        ;;
    arch)
        _install_nvim_arch
        _install_deps_arch
        ;;
esac

# ── Existing config ───────────────────────────────────────────────────────────

if [[ -e "$NVIM_CONFIG" || -L "$NVIM_CONFIG" ]]; then
    warn "Existing config found at $NVIM_CONFIG"
    read -r -p "  Replace it? [y/N] " response
    [[ "$response" =~ ^[yY]$ ]] || { echo "Aborted. Existing config untouched."; exit 0; }
    BACKUP="$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
    mv "$NVIM_CONFIG" "$BACKUP"
    info "Backed up to $BACKUP"
fi

# ── Install mode ──────────────────────────────────────────────────────────────

printf "\n%s\n" "${BOLD}Install method:${NC}"
printf '  [1] Symlink — repo changes are instantly live %s(recommended)%s\n' "$DIM" "$NC"
printf "  [2] Copy    — standalone, no dependency on repo path\n\n"
read -r -p "Choice [1/2]: " install_mode

case "$install_mode" in
    2) MODE="copy" ;;
    *) MODE="symlink" ;;
esac

# ── Apply ─────────────────────────────────────────────────────────────────────

if [[ "$MODE" == "symlink" ]]; then
    ln -sf "$REPO_DIR/nvim" "$NVIM_CONFIG"
    success "Symlinked: $NVIM_CONFIG → $REPO_DIR/nvim"
else
    cp -r "$REPO_DIR/nvim" "$NVIM_CONFIG"
    success "Copied: $REPO_DIR/nvim → $NVIM_CONFIG"
fi

# ── Bootstrap plugins ─────────────────────────────────────────────────────────

info "Installing plugins (may take a minute on first run)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null
success "Plugins ready"

# ── Markdown preview build ────────────────────────────────────────────────────

MKDP_DIR="$HOME/.local/share/nvim/lazy/markdown-preview.nvim/app"
if [[ -d "$MKDP_DIR" && ! -d "$MKDP_DIR/node_modules" ]]; then
    info "Building markdown-preview..."
    (cd "$MKDP_DIR" && npm install 2>/dev/null)
    success "markdown-preview ready"
fi

# ── Done ──────────────────────────────────────────────────────────────────────

printf "\n%s\n" "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
printf "  %s\n\n" "${GREEN}Installation complete!${NC}"
printf "  Open nvim, then run:\n"
printf "    %s   install LSP servers\n"          "${BOLD}:Mason${NC}"
printf "    %s   verify everything is wired up\n" "${BOLD}:checkhealth${NC}"
printf "    %s   inspect and update plugins\n"   "${BOLD}:Lazy${NC}"
printf "%s\n" "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

printf "\n%s  (all should be visible — no blank boxes)\n" "${BOLD}Character check:${NC}"
printf "  Diagnostics   ✘  ▲  ◆  ●\n"
printf "  UI            ▶  ◀  ▸  …  ●\n"
printf "  Box drawing   ─  │  ╭  ╮  ╯  ╰\n"
printf "  Powerline     \ue0b0  \ue0b1  \ue0b2  \ue0b3   %s\n\n" "${DIM}(requires Nerd Font — blank = font missing)${NC}"
