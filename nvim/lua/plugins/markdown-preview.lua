return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  build = "cd app && npm install",
  config = function()
    vim.g.mkdp_theme = "dark"
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_filetypes = { "markdown" }

    local map = require("config.map")
    map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", {
      desc = "Toggle browser preview",
      group = "Markdown",
      docs = "markdown-cheatsheet.md",
    })
  end,
}
