# Markdown

## Keybindings

| Key          | Action                                        |
| ------------ | --------------------------------------------- |
| `<leader>mt` | Toggle between rendered and raw code view     |
| `<leader>mp` | Toggle browser preview (with Mermaid support) |

## About

Two markdown systems work together:

**render-markdown.nvim** activates automatically when opening any `.md` file. Headers, bullets,
code blocks, tables, and horizontal rules render inline inside Neovim. Use `<leader>mt` to
switch between the rendered view and raw source code.

**markdown-preview.nvim** opens a browser tab with full rendering including Mermaid diagrams.
The statusline shows a blinking indicator while the preview server is running. Press
`<leader>mp` again to stop the server.

Defined in `lua/plugins/render-markdown.lua` and `lua/plugins/markdown-preview.lua`.
