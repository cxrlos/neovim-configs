#!/usr/bin/env bash
# Install this nvim config: check the tools, link ~/.config/nvim to ./nvim, then install the
# plugins (at the lockfile's commits) and the treesitter parsers. Safe to re-run. macOS and Linux
# (bash 3.2-safe: macOS /bin/bash).
# The tools themselves come from term-configs install.sh (dnf on Fedora, Brewfile on macOS).
#   ./install.sh          install / repair
#   ./install.sh --check  report only; exits 1 if anything is missing
set -eu
cd "$(dirname "$0")"
check=; [ "${1-}" = --check ] && check=1
problems=0
note() { printf '  %s\n' "$*"; }
todo() { note "$*"; problems=$((problems + 1)); }

echo "── tools ──"
missing=
for t in nvim git tree-sitter cc rg fd fzf; do command -v "$t" >/dev/null || missing="$missing $t"; done
if [ -z "$missing" ]; then note "all present"
else
    todo "missing:$missing"
    case $OSTYPE in
        darwin*) note "  macOS: term-configs install.sh (brew bundle); cc comes from xcode-select --install" ;;
        *) note "  Linux: term-configs install.sh (dnf on Fedora)" ;;
    esac
fi
if command -v nvim >/dev/null && ! nvim --headless -c 'lua os.exit(vim.fn.has("nvim-0.12") == 1 and 0 or 1)' >/dev/null 2>&1; then
    todo "nvim is older than 0.12"
fi
rust-analyzer --version >/dev/null 2>&1 || note "optional, Rust: rustup component add rust-analyzer"

echo "── link ──"
dst=${XDG_CONFIG_HOME:-$HOME/.config}/nvim src=$PWD/nvim
if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then note "$dst ok"
elif [ -n "$check" ]; then todo "$dst doesn't point at $src"
else
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        backup=$dst.backup-$(date +%Y%m%d-%H%M%S); mv "$dst" "$backup"; note "real config moved to $backup"
    fi
    mkdir -p "$(dirname "$dst")"; ln -sfn "$src" "$dst"; note "$dst -> $src"
fi

echo "── plugins and parsers ──"
if [ -n "$check" ] || [ $problems -gt 0 ]; then
    note "skipped$([ -n "$check" ] && echo " (--check)" || echo ": fix the above first")"
else
    # The first vim.pack call installs every plugin at the lockfile's commit; then wait for parsers.
    nvim --headless -c 'lua require("nvim-treesitter").install(require("config.parsing").parsers):wait(600000)' -c qa
    echo; note "plugins and parsers ready"
fi

[ $problems -gt 0 ] && { echo "Done, with $problems item(s) above."; exit 1; }
echo "Done."
