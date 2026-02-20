return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local shared = require("config.shared")

    require("oil").setup({
      default_file_explorer = false,
      columns = { "icon", "permissions", "size" },
      buf_options = { buflisted = false, bufhidden = "hide" },
      view_options = {
        show_hidden = true,
      },
      float = {
        border = shared.border,
      },
    })

    local map = require("config.map")
    map("n", "-", "<cmd>Oil<CR>", { desc = "Open parent dir (oil)", group = "Oil", docs = "navigation-cheatsheet.md" })
  end,
}
