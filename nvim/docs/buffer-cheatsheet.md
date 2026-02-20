# Buffers

## Keybindings

| Key                         | Action                                     |
| --------------------------- | ------------------------------------------ |
| `<S-h>` / `<S-l>`           | Cycle to prev / next buffer                |
| `<leader>b1` – `<leader>b9` | Jump directly to buffer by tab position    |
| `<leader>bp`                | Pick buffer interactively (letter overlay) |
| `<leader>bd`                | Close current buffer                       |
| `<leader>bD`                | Pick a buffer to close (letter overlay)    |
| `<leader>bo`                | Close all other buffers                    |
| `<leader>ba`                | Close all buffers                          |
| `<leader>b<`                | Move current buffer tab left               |
| `<leader>b>`                | Move current buffer tab right              |

## About

Buffers are managed by `bufferline.nvim`. Tab position numbers appear in the bufferline so `<leader>b3` always refers to the third visible tab regardless of which file it contains.

Opening more than 10 buffers triggers a warning notification. Use `<leader>bo` to close everything except the current file, or `<leader>bp` to visually select which to close.

The `<leader>bp` letter-overlay picker is the fastest way to switch between many open buffers — each tab gets a unique letter, press it to jump there instantly.
