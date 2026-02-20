return {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = { "MunifTanjim/nui.nvim" },
  opts = {
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
    routes = {
      { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
      { filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
      { filter = { event = "msg_show", find = "%[nvim%-treesitter%]" }, view = "mini" },
      { filter = { event = "msg_show", find = "Downloading tree%-sitter" }, opts = { skip = true } },
      { filter = { event = "msg_show", kind = "error" }, view = "popup" },
      { filter = { event = "msg_show", kind = "lua_error" }, view = "popup" },
    },
    views = {
      popup = {
        border = { style = "rounded" },
        size = { width = "80%", height = "auto" },
        win_options = { wrap = true },
      },
      mini = { timeout = 10000 },
      notify = { timeout = 10000 },
    },
    presets = {
      bottom_search = false,
      command_palette = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  },
  config = function(_, opts)
    require("noice").setup(opts)

    local map = require("config.map")
    local d = { group = "Notifications", docs = "core-cheatsheet.md" }
    map("n", "<leader>sn", "<cmd>Noice history<CR>", vim.tbl_extend("force", d, { desc = "Notification history" }))
    map("n", "<leader>sl", "<cmd>Noice last<CR>", vim.tbl_extend("force", d, { desc = "Last notification" }))
    map("n", "<leader>sd", "<cmd>Noice dismiss<CR>", vim.tbl_extend("force", d, { desc = "Dismiss notifications" }))
  end,
}
