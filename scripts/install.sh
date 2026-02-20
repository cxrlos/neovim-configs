#!/usr/bin/env bash
set -euo pipefail

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

info() { printf "%s\n" "${BLUE}→${NC} $*"; }
success() { printf "%s\n" "${GREEN}✓${NC} $*"; }
warn() { printf "%s\n" "${YELLOW}!${NC} $*"; }
die() {
    printf "%s\n" "${RED}✗${NC} $*"
    exit 1
}

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_CONFIG="$HOME/.config/nvim"

[[ "$(uname)" == "Darwin" ]] || die "This script targets macOS. See nvim/docs/lsp-cheatsheet.md for manual setup on other platforms."

printf "\n%s\n\n" "${BOLD}Neovim config installer${NC}"

# ── Homebrew ──────────────────────────────────────────────────────────────────

if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    success "Homebrew $(brew --version | head -1)"
fi

# ── Neovim ────────────────────────────────────────────────────────────────────

if ! command -v nvim &>/dev/null; then
    info "Installing Neovim..."
    brew install neovim
else
    success "Neovim $(nvim --version | head -1)"
fi

# ── Existing config ───────────────────────────────────────────────────────────

if [[ -e "$NVIM_CONFIG" || -L "$NVIM_CONFIG" ]]; then
    warn "Existing config found at $NVIM_CONFIG"
    read -r -p "  Replace it? [y/N] " response
    [[ "$response" =~ ^[yY]$ ]] || {
        echo "Aborted. Existing config untouched."
        exit 0
    }

    BACKUP="$HOME/.config/nvim.bak.$(date +%Y%m%d%H%M%S)"
    mv "$NVIM_CONFIG" "$BACKUP"
    info "Backed up to $BACKUP"
fi

# ── Dependencies ──────────────────────────────────────────────────────────────

BREW_DEPS=(ripgrep fd node python3 rustup-init tree-sitter tree-sitter@0.25)
for dep in "${BREW_DEPS[@]}"; do
    if brew list "$dep" &>/dev/null 2>&1; then
        success "$dep"
    else
        info "Installing $dep..."
        brew install "$dep"
    fi
done

# ── Install mode ─────────────────────────────────────────────────────────────

printf "\n%s\n" "${BOLD}How do you want to install the config?${NC}"
printf "  [1] Symlink  — repo changes are instantly live (recommended for development)\n"
printf "  [2] Copy     — standalone install, no dependency on this repo path\n\n"
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
    success "Config copied to $NVIM_CONFIG"
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
printf "    %s   install LSP servers\n" "${BOLD}:Mason${NC}"
printf "    %s   verify everything is wired up\n" "${BOLD}:checkhealth${NC}"
printf "    %s   inspect and update plugins\n" "${BOLD}:Lazy${NC}"
printf "%s\n" "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

printf "\n%s  (all should be visible — no blank boxes)\n" "${BOLD}Character check:${NC}"
printf "  Diagnostics   ✘  ▲  ◆  ●\n"
printf "  UI            ▶  ◀  ▸  …  ●\n"
printf "  Box drawing   ─  │  ╭  ╮  ╯  ╰\n"
printf "  Powerline     \ue0b0  \ue0b1  \ue0b2  \ue0b3   %s\n\n" "${DIM}(requires Nerd Font — blank = font missing)${NC}"
