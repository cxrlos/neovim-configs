return {
  "rose-pine/neovim",
  name = "rose-pine",
  priority = 1000,
  opts = {
    variant = "main",
    styles = {
      italic = true,
      bold = true,
    },
    highlight_groups = {
      Visual = { bg = require("config.shared").palette.overlay },
      Cursor = { fg = require("config.shared").palette.base, bg = require("config.shared").palette.foam },
    },
  },
  config = function(_, opts)
    require("rose-pine").setup(opts)
    vim.cmd("colorscheme rose-pine")
  end,
}
