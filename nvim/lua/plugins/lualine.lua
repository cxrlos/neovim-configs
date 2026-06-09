return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local icons = require("config.shared").icons

    require("lualine").setup({
      options = {
        theme = "rose-pine",
        globalstatus = true,
        component_separators = { left = "▸", right = "◂" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = { "neo-tree" } },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          {
            "diff",
            symbols = {
              added = icons.git.add .. " ",
              modified = icons.git.change .. " ",
              removed = icons.git.delete .. " ",
            },
          },
        },
        lualine_c = {},
        lualine_x = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.error,
              warn = icons.diagnostics.warn,
              hint = icons.diagnostics.hint,
              info = icons.diagnostics.info,
            },
          },
          "filetype",
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
