# neovim-configs

Neovim 0.12 config for two machines: `thinkpunk` (Fedora 44) and the macOS work Mac. Built
defaults-first: only non-default options, nvim's own keys where they exist, a plugin only for a
job nvim can't do. The editor is where agent-written code gets reviewed (see term-configs
AGENTS.md for the workflow map: tmux owns sessions, gh owns PRs, agents edit files only).

## Layout
| Path | What |
|---|---|
| `nvim/init.lua` | Leader, options, core keymaps and autocmds (no plugins), the `vim.pack.add` list, then `require`s the areas in order |
| `nvim/lua/config/look.lua` | Tokyo Night (night), in-buffer markdown rendering |
| `nvim/lua/config/parsing.lua` | Treesitter parsers, highlight + folds, `]m` function motions, sticky context |
| `nvim/lua/config/editing.lua` | mini.ai (`af` `ac` `au`), mini.surround (`sa` `sd` `sr`), mini.indentscope (`ii` `ai`) |
| `nvim/lua/config/lsp.lua` | Servers (`vim.lsp.enable`), native completion, `gd`, symbol highlight, diagnostics |
| `nvim/lua/config/navigation.lua` | fzf-lua (`<leader>s*`, `<leader><leader>`), oil (`-`), `<leader>bd` |
| `nvim/lua/config/git.lua` | gitsigns (`]c`, `<leader>h*`), Neogit + diffview (`<leader>g*`), review notes (`<leader>a*`) |
| `nvim/lua/config/format.lua` | conform (`<leader>f`; format-on-save opt-in) |
| `nvim/lua/config/habits.lua` | hardtime (hint mode) and precognition: temporary, remove once habits stick |
| `nvim/lua/config/keyhints.lua` | mini.clue. Must stay last: its triggers go after every mapping |
| `nvim/nvim-pack-lock.json` | Plugin lockfile (vim.pack). Commit it with any plugin change |

## Install
Tools (language servers, formatters, tree-sitter-cli) come from term-configs `install.sh`
(Fedora: dnf, pinned npm, pinned binaries; macOS: Brewfile). Then link this config:

    ln -sfn "$PWD/nvim" ~/.config/nvim

The first start installs the plugins at the lockfile's commits and builds the parsers.
Rust also needs `rustup component add rust-analyzer`.

## Rules
- **Defaults first.** Check `:h vim_diff` / `:h news` before setting an option; never restate a
  default. Prefer a built-in (`gc`, `gr*`, `]q`, `an`/`in`, `:DiffOrig`) over a plugin.
- **One owner per job.** Don't add what tmux, the shell or gh already own.
- **Plugins:** `vim.pack` only. Fresh and community-backed (record why if not, as for
  diffview-plus). Pin a semver range where the plugin tags releases; otherwise track the branch
  and let the lockfile pin the commit. A new plugin needs its tokyonight integration
  (`look.lua`) if it has one.
- **Updates:** `:lua vim.pack.update()`, read the review buffer, `:w` to apply, commit the lockfile.
  Never `force = true` without reading the changes. nvim-treesitter rebuilds parsers through the
  `PackChanged` hook.
- **Version pins** (here and in term-configs): the newest release at least two weeks old.
- **Every mapping has a `desc`** (mini.clue and `<leader>sk` show it). Leader groups:
  `a` agent notes, `b` buffer, `g` git, `h` hunk, `s` search, `t` toggles, `f` format,
  `y`/`Y` clipboard, `q` diagnostics list. `<leader>c*`, `<leader>e`, `<leader>b` are used by
  diffview inside its views.
- **No AI plugin in the editor**; agents run in tmux (`agent-run`). Nothing here may depend on a
  specific agent.
- **Security:** format-on-save only with `NVIM_FORMAT_ON_SAVE=1` from a direnv-allowed `.envrc`
  (project formatters run code). Node language servers prefer the project's `node_modules/.bin`.
- **Both OSes:** no OS-specific paths; branch on `vim.fn.has("mac")` if ever needed.

## Testing
Headless checks run against a sample project with Python/TS/Rust/Lua/Terraform/Markdown/web
targets: `nvim --headless <file> -c "luafile <script>"`, with the script waiting for the server
(`vim.wait`) and writing results to a file. Note: input fed from inside a Lua script is only
processed after it returns; check typed behaviour from a `vim.defer_fn`.
