# LSP

## Keybindings

### Navigation

| Key  | Action                                                       |
| ---- | ------------------------------------------------------------ |
| `gd` | Go to definition (press again on import to follow to source) |
| `gD` | Show all usages (Telescope)                                  |
| `K`  | Hover documentation (shows signature + source)               |

### Actions

| Key          | Action            |
| ------------ | ----------------- |
| `<leader>rn` | Rename symbol     |
| `<leader>ca` | Code action       |
| `<leader>D`  | Type definition   |
| `<leader>ds` | Document symbols  |
| `<leader>ws` | Workspace symbols |

### Diagnostics

| Key         | Action                                         |
| ----------- | ---------------------------------------------- |
| `[d` / `]d` | Prev / next diagnostic                         |
| Cursor hold | Auto-shows diagnostic float on warnings/errors |

## Adding a new language

1. Add the treesitter grammar name to `ensure_installed` in `lua/plugins/treesitter.lua`
2. Add the Mason server name to `ensure_installed` in `lua/plugins/mason.lua`
3. Create `lua/lsp/servers/<server_name>.lua` with server-specific overrides (return `{}` if none needed)
4. Add formatters and linters to `lua/plugins/formatting.lua`
5. Update this file with any language-specific keymaps

## About

LSP keymaps are buffer-local — registered in `lua/lsp/init.lua`'s `on_attach` function, only
active when an LSP server attaches to a buffer.

For cross-file navigation in Python: `gd` on a function call goes to the import line; `gd` again
on the import follows to the source file. This is standard pyright behavior. `K` shows the full
signature and source location without navigating.

Servers are installed and managed by Mason. Run `:Mason` to view and install servers.

Rust uses `rustaceanvim` instead of plain `lspconfig` — do not configure `rust_analyzer` separately.

Defined in `lua/lsp/init.lua`, `lua/lsp/handlers.lua`, and `lua/lsp/servers/*.lua`.
