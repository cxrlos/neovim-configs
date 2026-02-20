return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local shared = require("config.shared")
    local icons = shared.icons

    vim.api.nvim_set_hl(0, "MkdpBlinkA", { fg = "#e0def4", bg = "#31748f", bold = true })
    vim.api.nvim_set_hl(0, "MkdpBlinkB", { fg = "#191724", bg = "#9ccfd8", bold = true })

    vim.g._mkdp_running = false

    local grp = vim.api.nvim_create_augroup("user_mkdp_lualine", { clear = true })
    vim.api.nvim_create_autocmd("User", {
      group = grp,
      pattern = "MarkdownPreviewStart",
      callback = function()
        vim.g._mkdp_running = true
      end,
    })
    vim.api.nvim_create_autocmd("User", {
      group = grp,
      pattern = "MarkdownPreviewStop",
      callback = function()
        vim.g._mkdp_running = false
      end,
    })

    local function mkdp_status()
      if not vim.g._mkdp_running then
        return ""
      end
      return " MD PREVIEW ● <leader>mp to stop "
    end

    local function mkdp_color()
      if not vim.g._mkdp_running then
        return nil
      end
      if vim.g._mkdp_blink_phase then
        return "MkdpBlinkB"
      end
      return "MkdpBlinkA"
    end

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
        lualine_c = {
          { mkdp_status, color = mkdp_color },
        },
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
