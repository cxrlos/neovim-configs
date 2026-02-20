return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    heading = { sign = false, icons = { "# ", "## ", "### ", "#### " } },
    bullet = { icons = { "●", "○", "▸", "▹" } },
    code = { sign = false, width = "block", left_pad = 1 },
    dash = { icon = "─", width = "full" },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)

    local map = require("config.map")
    local d = { group = "Markdown", docs = "markdown-cheatsheet.md" }

    map(
      "n",
      "<leader>mt",
      "<cmd>RenderMarkdown toggle<CR>",
      vim.tbl_extend("force", d, { desc = "Toggle render mode" })
    )
  end,
}
