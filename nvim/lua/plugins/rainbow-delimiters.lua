return {
  "HiPhish/rainbow-delimiters.nvim",
  event = "BufReadPre",
  config = function()
    vim.g.rainbow_delimiters = {
      highlight = {
        "RainbowDelimiterRed",
        "RainbowDelimiterYellow",
        "RainbowDelimiterBlue",
        "RainbowDelimiterOrange",
        "RainbowDelimiterGreen",
        "RainbowDelimiterViolet",
        "RainbowDelimiterCyan",
      },
    }
  end,
}
