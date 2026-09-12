return {
  "ellisonleao/gruvbox.nvim",
  name = "gruvbox",
  priority = 1000,
  opts = {
    contrast = "",
    italic = {
      strings = true,
      comments = true,
    },
    bold = true,
    overrides = {
      Visual = { bg = require("config.shared").palette.overlay },
      Cursor = { fg = require("config.shared").palette.base, bg = require("config.shared").palette.foam },
    },
  },
  config = function(_, opts)
    require("gruvbox").setup(opts)
    vim.cmd("colorscheme gruvbox")
  end,
}
