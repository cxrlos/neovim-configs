return {
  "christoomey/vim-tmux-navigator",
  lazy = false,
  config = function()
    local map = require("config.map")
    local d = { group = "Windows", docs = "core-cheatsheet.md" }
    map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", vim.tbl_extend("force", d, { desc = "Navigate left (vim/tmux)" }))
    map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", vim.tbl_extend("force", d, { desc = "Navigate down (vim/tmux)" }))
    map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", vim.tbl_extend("force", d, { desc = "Navigate up (vim/tmux)" }))
    map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", vim.tbl_extend("force", d, { desc = "Navigate right (vim/tmux)" }))
  end,
}
