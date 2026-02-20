return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>pa", desc = "Harpoon add file" },
    { "<leader>pp", desc = "Harpoon menu" },
    { "<leader>1", desc = "Harpoon file 1" },
    { "<leader>2", desc = "Harpoon file 2" },
    { "<leader>3", desc = "Harpoon file 3" },
    { "<leader>4", desc = "Harpoon file 4" },
  },
  init = function()
    local map = require("config.map")
    local d = { group = "Harpoon", docs = "navigation-cheatsheet.md" }
    map("n", "<leader>pa", function()
      require("harpoon"):list():add()
    end, vim.tbl_extend("force", d, { desc = "Harpoon add file" }))
    map("n", "<leader>pp", function()
      local h = require("harpoon")
      h.ui:toggle_quick_menu(h:list())
    end, vim.tbl_extend("force", d, { desc = "Harpoon menu" }))
    map("n", "<leader>1", function()
      require("harpoon"):list():select(1)
    end, vim.tbl_extend("force", d, { desc = "Harpoon file 1" }))
    map("n", "<leader>2", function()
      require("harpoon"):list():select(2)
    end, vim.tbl_extend("force", d, { desc = "Harpoon file 2" }))
    map("n", "<leader>3", function()
      require("harpoon"):list():select(3)
    end, vim.tbl_extend("force", d, { desc = "Harpoon file 3" }))
    map("n", "<leader>4", function()
      require("harpoon"):list():select(4)
    end, vim.tbl_extend("force", d, { desc = "Harpoon file 4" }))
  end,
  config = function()
    require("harpoon"):setup()
  end,
}
