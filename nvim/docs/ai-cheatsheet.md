# AI / Claude Code

Claude Code runs in its own tmux window (`claude` window, beside `editor`). Neovim
bridges to it via [`coder/claudecode.nvim`](https://github.com/coder/claudecode.nvim) —
a WebSocket + MCP server that lets the external Claude CLI see selections, read
LSP diagnostics, and propose edits as native Neovim diff splits.

## Keybindings

| Key          | Mode | Action                                                         |
| ------------ | ---- | -------------------------------------------------------------- |
| `<leader>as` | x    | Send selection to Claude as `@-mention`. Focus stays in Neovim |
| `<leader>aS` | x    | Send selection and jump to tmux `claude` window                |
| `<leader>aa` | n    | Add current file to Claude's context                           |
| `<leader>ad` | n    | Close pending diffs (`:ClaudeCodeCloseAllDiffs`)               |
| `<leader>at` | n    | Show connection status (`:ClaudeCodeStatus`)                   |
| `<leader>ac` | n    | Resume previous session (`claude --continue`) in tmux          |
| `a` (neo-tree) | n  | Send file/dir under cursor to Claude as `@-mention`           |
| `A` (neo-tree) | n  | Original neo-tree "add file" (renamed from `a`)               |

## Workflow

### Starting a session

`tm` → pick the project. The `.tmux-sessionizer` creates three windows: `editor`
(runs `nvim .`), `claude` (runs `claude --ide`), `shell`. Focus lands on `editor`.

When `claude --ide` boots, it scans `~/.claude/ide/*.lock` for a running Neovim and
auto-connects. If the handshake didn't happen — e.g. Claude was already running
when Neovim started — type `/ide` inside Claude to retry.

### Sending context

Visual-select code, hit `<leader>as`. Claude receives an @-mention like
`@nvim/lua/config/keymaps.lua#L40-58`. Focus stays in Neovim — keep coding, switch
to `claude` window when ready.

For "send + start talking immediately," use `<leader>aS` — focus jumps to the tmux
`claude` window.

For an entire file, `<leader>aa` from any buffer.

For files you can see in neo-tree but aren't viewing, navigate the tree and press `a`.

### Reviewing changes

When Claude proposes an edit, the plugin opens a native Neovim diff split via the
`openDiff` MCP tool. Standard diff navigation:

| Key  | Action                  |
| ---- | ----------------------- |
| `]c` | Next change             |
| `[c` | Previous change         |
| `do` | Pull change from Claude |
| `dp` | Push change to Claude   |
| `:w` | Accept and save         |
| `:q` | Reject and close        |

You can edit the diff before accepting — type into the right-hand buffer, then `:w`.

If you end a session with leftover open diffs, `<leader>ad` closes the pending ones.
Already-saved diffs aren't touched.

### Bash-tool writes (the autoread path)

When Claude uses its `bash` tool to touch files outside of `openDiff` (formatters,
shell commands, `mv`, etc.), the change lands on disk directly. `autoread = true` +
the `agent_checktime` autocmd reload the buffer the next time the cursor moves,
the window gains focus, or the file is re-entered.

`agent_reload_notify` (kept temporarily for stress-test validation) fires a
`vim.notify` whenever a buffer reloads from disk. Removed after validation.

## Troubleshooting

| Symptom                                  | Check                                                                                          |
| ---------------------------------------- | ---------------------------------------------------------------------------------------------- |
| `<leader>as` does nothing in Claude      | `:ClaudeCodeStatus` — is the WebSocket server up?                                              |
| Claude says "no IDE detected"            | `ls ~/.claude/ide/*.lock` — lock file present? If yes, type `/ide` inside Claude.              |
| `<leader>aS` doesn't jump to tmux        | `echo $TMUX` — not inside tmux, so jump no-ops with a warning                                  |
| Two Neovim instances → wrong one connects | Plugin picks the most recent lock file. Close the unwanted instance, then `/ide` in Claude.   |
| Diff split won't accept                 | `:w` writes; if it bounces, check the `User ClaudeCodeSendComplete` autocmd in `claudecode.lua` |

## Defined in

- `nvim/lua/plugins/claudecode.lua` — plugin spec + all `<leader>a*` keymaps
- `nvim/lua/plugins/neo-tree.lua` — `a` / `A` neo-tree remap
- `nvim/lua/config/autocmds.lua` — `agent_checktime`, `agent_reload_notify`
- `nvim/lua/config/options.lua` — `autoread`
- `.tmux-sessionizer` — `claude --ide` launch
