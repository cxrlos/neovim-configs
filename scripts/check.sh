#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "→ Checking Lua formatting..."
stylua --check "$ROOT/nvim/" "$ROOT/templates/"

echo "→ Linting Lua..."
luacheck "$ROOT/nvim/lua/" --config "$ROOT/.luacheckrc"

echo "→ Testing config loads..."
NVIM_APPNAME=nvim-check nvim --headless "+lua print('Config OK')" +qa

echo "✓ All checks passed"
