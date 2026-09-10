return {
  "selimacerbas/markdown-preview.nvim",
  dependencies = { "selimacerbas/live-server.nvim" },
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewRefresh" },
  opts = {
    open_browser = true,
    default_theme = "dark",
    mermaid_renderer = "js",
    scroll_sync = true,
  },
  config = function(_, opts)
    require("markdown_preview").setup(opts)

    local map = require("config.map")
    local d = { group = "Markdown", docs = "markdown-cheatsheet.md" }

    map(
      "n",
      "<leader>mp",
      "<cmd>MarkdownPreview<CR>",
      vim.tbl_extend("force", d, { desc = "Start mermaid/markdown preview" })
    )
    map("n", "<leader>mP", "<cmd>MarkdownPreviewStop<CR>", vim.tbl_extend("force", d, { desc = "Stop preview" }))
    map("n", "<leader>mr", "<cmd>MarkdownPreviewRefresh<CR>", vim.tbl_extend("force", d, { desc = "Refresh preview" }))
  end,
}
