return {
  "debugloop/telescope-undo.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  keys = {
    { "<leader>u", "<cmd>Telescope undo<CR>", desc = "Undo history" },
  },
  config = function()
    require("config.map")(
      "n",
      "<leader>u",
      "<cmd>Telescope undo<CR>",
      { desc = "Undo history", group = "General", docs = "core-cheatsheet.md" }
    )
    require("telescope").load_extension("undo")
  end,
}
