# Neovim Configuration

Personal Neovim setup for Rust, TypeScript/React, Python, Terraform, and Lua. Rose Pine, Telescope, Harpoon, blink.cmp, mason + lspconfig.

## Install

```bash
git clone https://github.com/cxrlos/neovim-configs.git
cd neovim-configs
./scripts/install.sh
```

Handles Homebrew, Neovim, and all external dependencies. Asks before overwriting `~/.config/nvim`.

## Structure

```
nvim/
├── init.lua              entry point, leader key, lazy.nvim bootstrap
├── lua/
│   ├── config/           options, keymaps, autocmds, shared constants, cheatsheet
│   ├── plugins/          one spec file per plugin
│   └── lsp/              shared on_attach, diagnostics, per-server configs
└── docs/                 per-topic cheatsheet files
```

Press `?` inside Neovim for a searchable keybinding picker. See `nvim/docs/` for per-topic docs.
