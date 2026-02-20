return {
  "folke/todo-comments.nvim",
  event = "BufReadPre",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("todo-comments").setup()
    local map = require("config.map")
    local d = { group = "Find", docs = "navigation-cheatsheet.md" }
    map("n", "<leader>ft", "<cmd>TodoTelescope<CR>", vim.tbl_extend("force", d, { desc = "Find TODOs" }))
  end,
}
