return {
  "debugloop/telescope-undo.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  init = function()
    require("config.map")("n", "<leader>u", function()
      require("lazy").load({ plugins = { "telescope-undo.nvim" } })
      vim.cmd("Telescope undo")
    end, { desc = "Undo history", group = "General", docs = "core-cheatsheet.md" })
  end,
  config = function()
    require("telescope").load_extension("undo")
  end,
}
