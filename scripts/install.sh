#!/usr/bin/env bash
set -euo pipefail

# ── Colors & helpers ──────────────────────────────────────────────────────────

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
NC=$'\033[0m'

warn() { printf "%s\n" "${YELLOW}!${NC} $*"; }
err() { printf "%s\n" "${RED}✗${NC} $*"; }
die() { err "$@"; exit 1; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_CONFIG="$HOME/.config/nvim"

# ── OS detection ──────────────────────────────────────────────────────────────

OS="unknown"
[[ "$(uname)" == "Darwin" ]] && OS="macos"
[[ -f /etc/fedora-release ]] && OS="fedora"
[[ "$OS" == "unknown" ]] && die "Unsupported OS — targets macOS and Fedora."

printf "\n%s\n" "${BOLD}Neovim config installer  [${OS}]${NC}"

# ── Reinstall detection ──────────────────────────────────────────────────────

INSTALL_MODE="fresh"

if [[ -e "$NVIM_CONFIG" || -L "$NVIM_CONFIG" ]]; then
    printf "\n  Existing config found at %s\n\n" "$NVIM_CONFIG"
    printf "  [1] Update     — install missing deps, keep current config %s(default)%s\n" "$DIM" "$NC"
    printf "  [2] Reinstall  — remove config and link fresh\n\n"
    read -r -p "  Choice [1/2]: " choice
    case "${choice:-1}" in
        1) INSTALL_MODE="update" ;;
        2) INSTALL_MODE="reinstall" ;;
        *) die "Invalid choice" ;;
    esac
fi

printf "\n"

# ── Counters ──────────────────────────────────────────────────────────────────

deps_installed=0 deps_ok=0 deps_failed=0

# ── Package managers ──────────────────────────────────────────────────────────

_ensure_brew() {
    if ! command -v brew &>/dev/null; then
        warn "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

# ── Dependencies ──────────────────────────────────────────────────────────────

BREW_DEPS=(neovim ripgrep fd node python3 rustup-init tree-sitter tree-sitter@0.25)
# gcc/make: treesitter parsers and telescope-fzf-native compile locally
DNF_DEPS=(neovim ripgrep fd-find nodejs npm python3 rustup gcc make)

_install_deps() {
    case "$OS" in
        macos)
            _ensure_brew
            for dep in "${BREW_DEPS[@]}"; do
                if brew list "$dep" &>/dev/null; then
                    ((++deps_ok))
                else
                    brew install "$dep" &>/dev/null && ((++deps_installed)) || { warn "Failed: $dep"; ((++deps_failed)); }
                fi
            done
            ;;
        fedora)
            for dep in "${DNF_DEPS[@]}"; do
                if rpm -q --whatprovides "$dep" &>/dev/null; then
                    ((++deps_ok))
                else
                    sudo dnf install -y "$dep" &>/dev/null && ((++deps_installed)) || { warn "Failed: $dep"; ((++deps_failed)); }
                fi
            done
            # Fedora's rustup ships only rustup-init; it installs the toolchain into ~/.cargo
            if ! command -v rustc &>/dev/null && [[ ! -x "$HOME/.cargo/bin/rustc" ]]; then
                rustup-init -y --no-modify-path --default-toolchain stable &>/dev/null || warn "Failed: rust toolchain"
            fi
            ;;
    esac
}

_install_deps

# ── Config link ───────────────────────────────────────────────────────────────

_is_correct_link() {
    [[ -L "$NVIM_CONFIG" ]] && [[ "$(readlink "$NVIM_CONFIG")" == "$REPO_DIR/nvim" ]]
}

if [[ "$INSTALL_MODE" == "reinstall" ]]; then
    rm -rf "$NVIM_CONFIG"
    ln -sf "$REPO_DIR/nvim" "$NVIM_CONFIG"
elif [[ "$INSTALL_MODE" == "fresh" ]]; then
    mkdir -p "$(dirname "$NVIM_CONFIG")"
    ln -sf "$REPO_DIR/nvim" "$NVIM_CONFIG"
elif ! _is_correct_link; then
    warn "Config exists but is not linked to this repo — skipping link"
fi

# ── Bootstrap plugins ────────────────────────────────────────────────────────

nvim --headless "+Lazy! sync" +qa 2>/dev/null || true

# ── Markdown preview ─────────────────────────────────────────────────────────

MKDP_DIR="$HOME/.local/share/nvim/lazy/markdown-preview.nvim/app"
if [[ -d "$MKDP_DIR" && ! -d "$MKDP_DIR/node_modules" ]]; then
    (cd "$MKDP_DIR" && npm install 2>/dev/null) || true
fi

# ── Summary ───────────────────────────────────────────────────────────────────

printf "\n"
printf "  deps:   %s installed, %s ok" "$deps_installed" "$deps_ok"
((deps_failed > 0)) && printf ", ${RED}%s failed${NC}" "$deps_failed"
printf "\n"
printf "  config: %s\n" "$(_is_correct_link && printf "linked" || printf "not linked")"
printf "\n  ${GREEN}done${NC} — open ${BOLD}nvim${NC} and run ${BOLD}:checkhealth${NC}\n\n"
