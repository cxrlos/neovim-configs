# Neovim Config

Personal Neovim configuration for daily development. `nvim/` maps 1:1 to `~/.config/nvim/` via symlink — edits are instantly live.

## Stack

| Layer          | Choice                                                    |
|----------------|-----------------------------------------------------------|
| Plugin manager | lazy.nvim — one file per plugin in `lua/plugins/`         |
| Theme          | Rose Pine                                                 |
| Completion     | blink.cmp                                                 |
| LSP            | mason + nvim-lspconfig (rustaceanvim for Rust)            |
| Fuzzy finder   | Telescope                                                 |
| File nav       | Harpoon v2, neo-tree, oil.nvim                            |
| Git            | gitsigns (lazygit via tmux `` `g ``)                      |
| Formatting     | conform.nvim (project-config-aware, format-on-save)       |
| Languages      | Rust, TypeScript/React, Python, Terraform, Docker, Lua    |

## Key files

| File                           | Purpose                                               |
|--------------------------------|-------------------------------------------------------|
| `nvim/lua/config/map.lua`      | Keymap wrapper — auto-registers in `?` cheatsheet     |
| `nvim/lua/config/shared.lua`   | Icons and border constants consumed by all plugins    |
| `nvim/lua/config/cheatsheet.lua` | `?` picker — reads from `config.map` registry       |
| `nvim/lua/lsp/init.lua`        | Shared `on_attach` and `capabilities`                 |
| `templates/plugin.lua`         | Required format for every new plugin file             |

## Lua conventions

- 2-space indent throughout
- `snake_case` for variables and functions; `PascalCase` only for module-level return tables
- Local aliases at the top of every file: `local map = vim.keymap.set`, `local opt = vim.opt`, etc.
- Each file in `lua/plugins/` returns a table of lazy.nvim plugin specs. No cross-file side effects.

## Plugin workflow

When adding a plugin or new keymap:

1. Add spec to `lua/plugins/<name>.lua` (new file if the category is distinct)
2. **Never use `vim.keymap.set` directly** for discoverable keymaps. Use `require("config.map")`:
   ```lua
   local map = require("config.map")
   map("n", "<leader>xx", fn, { desc = "Do thing", group = "GroupName", docs = "foo-cheatsheet.md" })
   ```
   `config.map` strips `group` and `docs` before passing to `vim.keymap.set` — Neovim rejects unknown opts keys.
   The `group` field is auto-derived into a which-key popup section AND a semantic category (icon + color) in the `?` picker. If the group is new, add it to `group_to_category` in `nvim/lua/config/shared.lua`.
3. Add the keymap to the matching `nvim/docs/*-cheatsheet.md`
4. Add to `expected_plugins` / `expected_keymaps` in `lua/config/health.lua`

## Language addition checklist

1. Treesitter grammar → `ensure_installed` in `lua/plugins/treesitter.lua`
2. Mason server → `ensure_installed` in `lua/plugins/lsp.lua`
3. Create `lua/lsp/servers/<lang>.lua` with server-specific overrides
4. Register in `lua/lsp/init.lua`
5. Add formatters/linters to `lua/plugins/formatting.lua`
6. Update `nvim/docs/lsp-cheatsheet.md`

## Keymap prefix assignments

Check before adding any new keymap:

| Prefix              | Owner               | Keys                                                        |
|---------------------|---------------------|-------------------------------------------------------------|
| `<leader>a`         | Claude / Agent      | `as` send, `aS` send+jump, `aa` add file, `ad` close diffs, `at` status, `ac` continue |
| `<leader>b`         | bufferline          | `bd`, `bo`                                                  |
| `<leader>c`         | code                | `ca` code action, `cf` format project                       |
| `<leader>d`         | debug / LSP         | `ds` doc symbols, `D` type def                              |
| `<leader>e/E`       | neo-tree            | toggle / reveal current file                                |
| `<leader>f`         | Telescope           | `ff`, `fg`, `fr`, `fb`, `fh`, `fs`, `fw`, `fd`, `fc`       |
| `<leader>ft`        | todo-comments       | find TODOs                                                  |
| `<leader>g`         | git                 | `gs`, `gr`, `gS`, `gu`, `gp`, `gd`, `gi`, `gb`             |
| `<leader>m`         | markdown            | `mt` toggle render                                          |
| `<leader>p`         | harpoon             | `pa` add, `pp` menu, `1–4` jump                             |
| `<leader>q`         | quickfix            | `qn`, `qp`, `qo`, `qc`                                     |
| `<leader>r`         | LSP rename          | `rn`                                                        |
| `<leader>s`         | search/notifs       | `sn`, `sl`, `sd`                                            |
| `<leader>u`         | undotree            | toggle                                                      |
| `<leader>w`         | LSP workspace       | `ws`                                                        |
| `<leader>y/Y`       | clipboard yank      | explicit `"+y` / `"+Y` (no auto-clipboard)                 |
| `<S-h>/<S-l>`       | bufferline          | cycle buffers                                               |
| `<C-h/j/k/l>`       | vim-tmux-navigator  | splits + tmux panes                                         |
| `[d` / `]d`         | LSP diagnostics     | prev/next                                                   |
| `gd` `gD` `gi`      | LSP navigation      | definition, declaration, implementation                     |
| `<leader>gd`        | LSP references      | Telescope                                                   |
| `K`                 | LSP hover           |                                                             |
| `gb`                | gitsigns            | toggle blame all lines (age-colored)                        |

## Known caveats

**mason-lspconfig v2: `handlers` key removed**
Old `handlers = { function(server_name) ... }` silently fails — `on_attach` is never called, no error shown. Use `vim.lsp.config()` (Neovim 0.11+ native API) and register keymaps via `LspAttach` autocmd:
```lua
vim.lsp.config("lua_ls", { settings = { ... } })
require("mason-lspconfig").setup({ ensure_installed = { "lua_ls" } })
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event) require("lsp").on_attach(nil, event.buf) end,
})
```
If LSP keymaps stop working, write a temp file from inside `on_attach` to verify it fires before debugging anything else.

**rustaceanvim owns rust-analyzer entirely**
Do not also configure `rust_analyzer` via lspconfig — duplicate server attachment, no error shown.

**Treesitter: use `branch = "master"`, not `main`**
The `main` branch is an incompatible rewrite requiring `tree-sitter-cli` as an external compiler dependency.

**Treesitter: never install Neovim's bundled parsers**
Neovim ships `c`, `lua`, `markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`. Installing these via nvim-treesitter overrides them with incompatible query versions → `get_query` / `Invalid node type` errors. Check bundled parsers: `ls /opt/homebrew/Cellar/neovim/*/lib/nvim/parser/`

**tree-sitter is a Neovim runtime dependency — never uninstall from brew**
Neovim is dynamically linked against a specific version. Removing it breaks Neovim entirely (`dyld: Library not loaded`). Both `tree-sitter` and `tree-sitter@<version>` are in `install.sh BREW_DEPS`.

**blink.cmp: all sources declared at setup time**
Sources cannot be added after `require("blink.cmp").setup()`.

**noice.nvim: `priority = 1000`**
Must intercept notifications before other plugins call `vim.notify`.

**`pcall(vim.cmd, ...)` doesn't suppress noice errors**
Neovim sends Vim errors to `msg_show` before the Lua exception propagates. `pcall` catches the exception but noice already displayed the error. Always gate with `pcall(require, ...)` instead:
```lua
local ok, builtin = pcall(require, "telescope.builtin")
if ok then builtin.find_files() else vim.notify("not ready", vim.log.levels.WARN) end
```

**`lazy-lock.json`: committed intentionally**
Run `:Lazy update` deliberately, not as a side effect of testing.

**`claudecode.nvim` runs in `provider = "none"` (external tmux) mode**
The plugin only runs a WebSocket server and writes a lock file at `~/.claude/ide/<port>.lock`.
The Claude CLI runs in the tmux `claude` window, launched with `claude --ide` from
`.tmux-sessionizer`. Consequences:
- `:ClaudeCode` and `:ClaudeCodeSendText` are no-ops — they need an in-editor terminal.
- `:ClaudeCode --continue` won't restart the tmux Claude; `<leader>ac` drives tmux directly.
- Multiple Neovim instances → multiple lock files → Claude picks the most recent.
  Close unwanted instances or `/ide` inside Claude to switch.
- The `User ClaudeCodeSendComplete` autocmd is the documented hook to focus tmux after
  a send. We gate it via a module-level `_jump_on_send` flag so `<leader>as` stays put
  but `<leader>aS` jumps.

**Leader key timing**
`vim.g.mapleader` must be set before `require("lazy")`. It's at the top of `nvim/init.lua`.

**Nerd Font glyphs in Cursor IDE**
Always blank. Judge icon correctness in Alacritty + Neovim, not the IDE editor pane.

**Nerd Font codepoints in `shared.lua`**
All icons use plain Unicode (U+2000–U+27FF). Do not reintroduce Nerd Font codepoints without explicit approval. If they return, use only FA4 range (U+F000–U+F2E0) — NF v3 Material Design (U+F0000+) absent from older installs.

**Plugin spec files can vanish silently**
After any batch file operation, verify with `ls nvim/lua/plugins/`. If LSP stops working, check the spec file exists before debugging the LSP wiring.

**`nvim --headless "+lua ..."` runs before `init.lua`**
Runtimepath isn't set up yet — `require("config.shared")` fails. Use `luac -p <file>` for syntax checks; `:lua ...` in a live session for runtime checks.

**`config.map` wrapper: `vim.keymap.set` rejects unknown opts keys**
`group` and `docs` must be stripped before passing opts to `vim.keymap.set`. The wrapper does this. If you bypass `config.map` and pass those keys directly, Neovim crashes at boot with `invalid key: docs`.

## Debugging strategy

1. **Layer 1 — runtime**: `LspAttach` autocmd in `mason.lua` verifies `gd` registered after `on_attach`. If not, a noice error fires immediately.
2. **Layer 2 — dev logging**: `require("config.shared").debug = true` enables `shared.log()` → `~/.local/state/nvim/user_debug.log`. Always reset to `false` before committing.
3. **Layer 3 — health check**: `:checkhealth user` verifies expected plugins, Mason servers, keymaps, and `LspAttach` autocmd.

When something fails silently, check in that order.
