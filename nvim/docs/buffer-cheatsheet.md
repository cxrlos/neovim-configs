# Buffers

## Keybindings

| Key                         | Action                                     |
| --------------------------- | ------------------------------------------ |
| `<S-h>` / `<S-l>`           | Cycle to prev / next buffer                |
| `<leader>b1` – `<leader>b9` | Jump directly to buffer by tab position    |
| `<leader>bd`                | Close current buffer                       |
| `<leader>bo`                | Close all other buffers                    |
| `<leader>ba`                | Close all buffers                          |
| `<leader>b<`                | Move current buffer tab left               |
| `<leader>b>`                | Move current buffer tab right              |

## About

Buffers are managed by `bufferline.nvim`. Tab position numbers appear in the bufferline so `<leader>b3` always refers to the third visible tab regardless of which file it contains.

Opening more than 10 buffers triggers a warning notification. Use `<leader>bo` to close everything except the current file. Use `<leader>fb` (Telescope) to fuzzy-search and jump to any open buffer.
