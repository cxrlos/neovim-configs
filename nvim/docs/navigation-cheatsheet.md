# Navigation

## Keybindings

### Telescope (fuzzy finder)

| Key          | Action                   |
| ------------ | ------------------------ |
| `<leader>ff` | Find files               |
| `<leader>fg` | Live grep across project |
| `<leader>fr` | Recent files             |
| `<leader>fb` | Open buffers             |
| `<leader>fh` | Help tags                |
| `<leader>fs` | Document symbols         |
| `<leader>fw` | Workspace symbols        |
| `<leader>fd` | Diagnostics              |
| `<leader>fc` | Command history          |

Inside Telescope: `<C-j>/<C-k>` to move, `<C-q>` to send to quickfix, `<Esc>` to close.

### File tree (neo-tree)

| Key                       | Action                           |
| ------------------------- | -------------------------------- |
| `<leader>e`               | Toggle file tree sidebar         |
| `<leader>E`               | Reveal current file in tree      |
| `<C-h>` / `<C-l>`         | Exit tree to left / right window |

### Oil (filesystem as buffer)

| Key | Action                       |
| --- | ---------------------------- |
| `-` | Open parent directory in oil |

In oil, edit filenames directly and `:w` to apply changes. Use `dd` to delete, `yy`+`p` to copy files.

### Harpoon (active file pins)

| Key                       | Action                  |
| ------------------------- | ----------------------- |
| `<leader>pa`              | Pin current file        |
| `<leader>pp`              | Open harpoon menu       |
| `<leader>1` – `<leader>4` | Jump to pinned file 1–4 |

## About

**Telescope** is the primary discovery tool — use it when you don't know where something is.

**Harpoon** is the primary switching tool — pin the 3–4 files you're actively working in and jump between them instantly. ThePrimeagen's workflow: use Telescope to find a file once, pin it with `<leader>pa`, then navigate via `<leader>1-4` for the rest of the session.

**neo-tree** is for visual project orientation, especially in unfamiliar codebases. `nvim .` opens it automatically.

**oil** is for filesystem operations (rename, move, delete in bulk). It treats directories as editable buffers.
