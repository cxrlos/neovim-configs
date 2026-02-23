# Core

## Keybindings

Leader key is `<Space>`.

### Search & scrolling

| Key               | Action                                       |
| ----------------- | -------------------------------------------- |
| `/`               | Search forward (inline at cursor position)   |
| `n` / `N`         | Next / prev search match (centered with zz)  |
| `<C-d>` / `<C-u>` | Scroll half page down / up (cursor centered) |

### Editing

| Key                | Action                                |
| ------------------ | ------------------------------------- |
| `J` (normal)       | Join line below without moving cursor |
| `J` / `K` (visual) | Move selection down / up              |

### Clipboard

| Key                  | Action                             |
| -------------------- | ---------------------------------- |
| `<leader>p` (visual) | Paste without overwriting register |

### Window navigation

| Key               | Action                                        |
| ----------------- | --------------------------------------------- |
| `<C-h/j/k/l>`    | Navigate left / down / up / right (vim + tmux) |
| `<M-h/j/k/l>`    | Resize window (Alt + hjkl)                      |

### Quickfix

| Key                         | Action                |
| --------------------------- | --------------------- |
| `<leader>qn` / `<leader>qp` | Quickfix next / prev  |
| `<leader>qo` / `<leader>qc` | Quickfix open / close |

### Location list

| Key                         | Action                    |
| --------------------------- | ------------------------- |
| `<leader>ln` / `<leader>lp` | Location list next / prev |

### General

| Key | Action |
|-----|--------|
| `?` | Open keybinding cheatsheet |
| `Q` | Disabled (prevents accidental Ex mode) |
| `<leader>u` | Toggle undo tree |
| `<leader>t` | Floating terminal |
| `<leader>F` | Format entire project (with confirmation) |

## About

Core keymaps are defined in `lua/config/keymaps.lua`. They are non-plugin, always-available bindings.

Window navigation uses `<C-h/j/k/l>`, shared with tmux via vim-tmux-navigator for seamless pane/window switching without a prefix.

System clipboard is global via `clipboard=unnamedplus` — all yanks go to the OS clipboard automatically. `<leader>p` in visual mode pastes without clobbering the unnamed register.
