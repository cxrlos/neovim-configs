return {
  "rose-pine/neovim",
  name = "rose-pine",
  priority = 1000,
  opts = {
    variant = "main",
    dark_variant = "main",
    dim_inactive_windows = false,
    extend_background_behind_borders = true,
    styles = {
      bold = true,
      italic = true,
      transparency = false,
    },
  },
  config = function(_, opts)
    require("rose-pine").setup(opts)
    vim.cmd("colorscheme rose-pine")
  end,
}
