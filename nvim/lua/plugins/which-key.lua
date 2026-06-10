return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local shared = require("config.shared")
    local map = require("config.map")
    local wk = require("which-key")

    local function set_highlights()
      local p = shared.palette
      vim.api.nvim_set_hl(0, "WhichKey", { fg = p.foam, bold = true })
      vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = p.iris })
      vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = p.text })
      vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = p.muted })
      vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = p.surface })
      vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = p.foam, bg = p.surface })
      vim.api.nvim_set_hl(0, "WhichKeyTitle", { fg = p.iris, bold = true })
      vim.api.nvim_set_hl(0, "WhichKeyValue", { fg = p.subtle })

      for category, color in pairs(shared.category_color) do
        vim.api.nvim_set_hl(0, "WhichKeyCat" .. category, { fg = color, bold = true })
      end
    end

    wk.setup({
      preset = "helix",
      delay = 250,
      filter = function(mapping)
        return mapping.desc and mapping.desc ~= ""
      end,
      win = {
        border = shared.border,
        padding = { 1, 2 },
        title = true,
        title_pos = "center",
        wo = {
          winblend = 0,
        },
      },
      layout = {
        spacing = 4,
        align = "left",
      },
      icons = {
        breadcrumb = shared.icons.ui.arrow_right,
        separator = shared.icons.ui.arrow_right,
        group = "",
        mappings = false,
        rules = false,
        colors = false,
        keys = {
          Up = "↑",
          Down = "↓",
          Left = "←",
          Right = "→",
          C = "⌃ ",
          M = "⌥ ",
          D = "⌘ ",
          S = "⇧ ",
          CR = "↵ ",
          Esc = "⎋ ",
          BS = "⌫ ",
          Space = "␣ ",
          Tab = "⇥ ",
          F1 = "F1", F2 = "F2", F3 = "F3", F4 = "F4", F5 = "F5",
          F6 = "F6", F7 = "F7", F8 = "F8", F9 = "F9", F10 = "F10",
          F11 = "F11", F12 = "F12",
        },
      },
      show_help = false,
      show_keys = true,
      sort = { "group", "alphanum", "mod" },
    })

    set_highlights()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("user_whichkey_hl", { clear = true }),
      callback = set_highlights,
    })

    local groups = map.get_groups()
    local spec = {}
    for _, g in ipairs(groups) do
      local icon = shared.icons.category[g.category] or shared.icons.category.general
      table.insert(spec, {
        g.prefix,
        group = g.label,
        icon = { icon = icon, hl = "WhichKeyCat" .. g.category },
      })
    end

    wk.add(spec)

    map("n", "<leader>?", function()
      wk.show({ global = false })
    end, { desc = "Buffer-local keymaps (which-key)", group = "General", docs = "core-cheatsheet.md" })
  end,
}
