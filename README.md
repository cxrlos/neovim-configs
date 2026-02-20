# My Neovim Configuration

My personal Neovim setup, built from scratch for daily development in Rust, TypeScript/React,
Python, Terraform, and more. I prioritize fast navigation, solid LSP indexing, and a clean
aesthetic — drawing from ThePrimeagen's workflow with the Rose Pine color scheme.

## What's inside

- **Theme** — [Rose Pine](https://github.com/rose-pine/neovim) dark
- **Navigation** — Telescope (fuzzy find), Harpoon v2 (active file pinning), neo-tree (sidebar), oil.nvim (filesystem as a buffer)
- **LSP & completion** — mason + nvim-lspconfig + blink.cmp covering Rust, TypeScript, Python, Terraform, Docker, GH Actions, Markdown, Lua
- **Treesitter** — syntax highlighting, text objects, sticky context header
- **Git** — gitsigns (inline hunks/blame) + lazygit (floating terminal)
- **AI** — Claude via codecompanion.nvim, on-demand only — no autocomplete
- **Formatting** — conform.nvim, respects each project's own config (`.prettierrc`, `biome.json`, `rustfmt.toml`, etc.)
- **Cheatsheet** — press `?` for a searchable keybinding picker with source preview
- **Markdown** — inline rendering + browser preview with Mermaid support

See [`nvim/docs/`](nvim/docs/) for per-topic documentation.

## Prerequisites

- macOS (the install script targets Homebrew; other platforms require manual setup)
- [Hack Nerd Font Mono](https://www.nerdfonts.com/) or any Nerd Font with Powerline symbols
- A Claude API key (for AI features — optional, everything else works without it)

## Install

```bash
git clone https://github.com/<your-username>/neovim-configs.git
cd neovim-configs
./scripts/install.sh
```

The script checks for an existing `~/.config/nvim` and asks before overwriting. It handles
Homebrew, Neovim, and all external dependencies. You choose between a symlink (edits are live)
or a standalone copy.

## Structure

```
nvim/
├── init.lua              entry point, leader key, lazy.nvim bootstrap
├── lua/
│   ├── config/           options, keymaps, autocmds, shared constants, map wrapper, cheatsheet
│   ├── plugins/          one spec file per plugin
│   └── lsp/              shared on_attach, diagnostics, per-server configs
└── docs/                 per-topic cheatsheet files (*-cheatsheet.md)
```

## License

MIT
