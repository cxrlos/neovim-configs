# Git

## Keybindings

### Navigation

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / prev hunk |

### Hunk operations

| Key | Action |
|-----|--------|
| `<leader>gs` | Stage hunk |
| `<leader>gr` | Reset hunk |
| `<leader>gS` | Stage entire buffer |
| `<leader>gu` | Undo stage hunk |
| `<leader>gp` | Preview hunk (floating diff) |

### Blame

| Key | Action |
|-----|--------|
| `gb` | Toggle inline blame on all lines |
| `<leader>gi` | Full commit info (normal mode, copyable, GitHub link) |

### Diff

| Key | Action |
|-----|--------|
| `<leader>gd` | Diff current file against index |

### Terminal

| Key | Action |
|-----|--------|
| `<leader>gt` | Floating terminal (for manual git commands) |

## About

**gitsigns.nvim** provides inline blame on all lines (`gb`), hunk staging/reset, and diffs.
`<leader>gi` opens a floating window in normal mode showing the full commit: hash, author,
date, message, and a GitHub commit URL. You can yank the hash or URL directly.

**Floating terminal** (`<leader>gt`) opens a popup shell for manual git operations.

Defined in `lua/plugins/gitsigns.lua` and `lua/config/keymaps.lua`.
