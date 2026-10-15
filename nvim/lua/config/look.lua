-- Look: theme and in-buffer markdown

-- Look: Tokyo Night (night), like Alacritty, tmux, fzf and delta. Without lazy.nvim it would
-- style every plugin it knows; list only the ones in use (add gitsigns/neogit with the git batch).
require("tokyonight").setup({
  style = "night",
  plugins = {
    all = false,
    ["fzf-lua"] = true,
    ["mini.icons"] = true,
    ["mini.surround"] = true,
    ["nvim-treesitter-context"] = true,
    ["render-markdown.nvim"] = true,
    ["gitsigns.nvim"] = true,
    ["neogit"] = true,
  },
})
vim.cmd.colorscheme("tokyonight")

-- Markdown renders in the buffer (headings, tables, checkboxes, code); the cursor line shows the
-- raw text, and insert mode shows it all. No browser, no server.
require("render-markdown").setup({ latex = { enabled = false } }) -- no LaTeX toolchain (skipped)
