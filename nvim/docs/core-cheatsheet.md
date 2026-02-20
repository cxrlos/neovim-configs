# Core

## Keybindings

Leader key is `<Space>`.

### Scrolling & search

| Key               | Action                                       |
| ----------------- | -------------------------------------------- |
| `<C-d>` / `<C-u>` | Scroll half page down / up (cursor centered) |
| `n` / `N`         | Next / prev search match (centered)          |

### Editing

| Key                | Action                                |
| ------------------ | ------------------------------------- |
| `J` (normal)       | Join line below without moving cursor |
| `J` / `K` (visual) | Move selection down / up              |

### Clipboard

| Key                       | Action                                    |
| ------------------------- | ----------------------------------------- |
| `<leader>y` / `<leader>Y` | Yank selection / line to system clipboard |
| `<leader>p` (visual)      | Paste without overwriting register        |

### Window navigation

| Key               | Action                                |
| ----------------- | ------------------------------------- |
| `<leader>h/j/k/l` | Focus left / down / up / right window |
| `<C-↑↓←→>`        | Resize window                         |

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

| Key | Action                                 |
| --- | -------------------------------------- |
| `?` | Open keybinding cheatsheet             |
| `Q` | Disabled (prevents accidental Ex mode) |

## About

Core keymaps are defined in `lua/config/keymaps.lua`. They are non-plugin, always-available bindings.

Window navigation mirrors the standard `<C-w>h/j/k/l` motions but using the leader key for consistency with the rest of the config. The `<C-hjkl>` variants were intentionally removed to keep a single navigation paradigm.

Clipboard operations use explicit `"+` register yanking rather than setting `clipboard=unnamedplus` globally, which avoids slowdowns on systems where clipboard access is slow.
