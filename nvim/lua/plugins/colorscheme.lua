return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  opts = {
    flavour = "mocha",
    dim_inactive = { enabled = false },
    transparent_background = true,
    styles = {
      comments = { "italic" },
      keywords = { "bold" },
    },
    custom_highlights = {
      Visual = { bg = "#45475a" },                  -- light tint on selection
      Cursor = { fg = "#1e1e2e", bg = "#89dceb" },   -- sky block, pops over Visual
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd("colorscheme catppuccin-mocha")
  end,
}
