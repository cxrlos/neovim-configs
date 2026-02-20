return {
  "nvimdev/dashboard-nvim",
  event = "VimEnter",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local function telescope(picker)
      return function()
        local ok, builtin = pcall(require, "telescope.builtin")
        if ok then
          builtin[picker]()
        else
          vim.notify("Telescope not installed yet — run :Lazy sync", vim.log.levels.WARN)
        end
      end
    end

    local function edit_config()
      vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
    end

    require("dashboard").setup({
      theme = "doom",
      config = {
        header = {
          "",
          "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗  ",
          "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║  ",
          "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║  ",
          "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║  ",
          "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║  ",
          "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝  ",
          "",
        },
        center = {
          { icon = "▶  ", key = "f", desc = "Find file", action = telescope("find_files") },
          { icon = "◆  ", key = "r", desc = "Recent files", action = telescope("oldfiles") },
          { icon = "●  ", key = "g", desc = "Live grep", action = telescope("live_grep") },
          { icon = "▸  ", key = "c", desc = "Config", action = edit_config },
          {
            icon = "✘  ",
            key = "q",
            desc = "Quit",
            action = function()
              vim.cmd("qa")
            end,
          },
        },
        footer = {},
      },
    })
  end,
}
