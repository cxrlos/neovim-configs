return {
  "<author>/<repo>",

  -- event = "VeryLazy",
  -- ft    = { "rust", "typescript" },
  -- cmd   = { "SomeCommand" },
  -- keys  = { { "<leader>x", desc = "Trigger description" } },

  dependencies = {
    -- "<author>/<dep>",
  },

  opts = {},

  -- config = function(_, opts)
  --   require("<plugin>").setup(opts)
  --
  --   local map = require("config.map")
  --   map("n", "<leader>x", "<cmd>SomeCommand<CR>", {
  --     desc  = "Description",
  --     group = "GroupName",
  --     docs  = "category-cheatsheet.md",
  --   })
  -- end,
}
