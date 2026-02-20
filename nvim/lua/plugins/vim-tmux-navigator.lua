return {
  "christoomey/vim-tmux-navigator",
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Navigate left (vim/tmux)" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Navigate down (vim/tmux)" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Navigate up (vim/tmux)" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Navigate right (vim/tmux)" },
  },
  init = function()
    local map = require("config.map")
    local d = { group = "Windows", docs = "core-cheatsheet.md" }
    map("n", "<C-h>", "<cmd>TmuxNavigateLeft<cr>", vim.tbl_extend("force", d, { desc = "Navigate left (vim/tmux)" }))
    map("n", "<C-j>", "<cmd>TmuxNavigateDown<cr>", vim.tbl_extend("force", d, { desc = "Navigate down (vim/tmux)" }))
    map("n", "<C-k>", "<cmd>TmuxNavigateUp<cr>", vim.tbl_extend("force", d, { desc = "Navigate up (vim/tmux)" }))
    map("n", "<C-l>", "<cmd>TmuxNavigateRight<cr>", vim.tbl_extend("force", d, { desc = "Navigate right (vim/tmux)" }))
  end,
}
