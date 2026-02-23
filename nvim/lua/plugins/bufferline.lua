return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local shared = require("config.shared")
    local icons = shared.icons
    local map = require("config.map")
    local d = { group = "Buffer", docs = "buffer-cheatsheet.md" }

    require("bufferline").setup({
      options = {
        mode = "buffers",
        numbers = "ordinal",
        separator_style = "thin",
        show_buffer_close_icons = false,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        diagnostics_indicator = function(_, _, diag)
          local ret = (diag.error and icons.diagnostics.error .. diag.error .. " " or "")
            .. (diag.warning and icons.diagnostics.warn .. diag.warning or "")
          return vim.trim(ret)
        end,
        offsets = {
          {
            filetype = "neo-tree",
            text = "Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    })

    map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", vim.tbl_extend("force", d, { desc = "Prev buffer" }))
    map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", vim.tbl_extend("force", d, { desc = "Next buffer" }))

    map("n", "<leader>bd", "<cmd>bdelete<CR>", vim.tbl_extend("force", d, { desc = "Close buffer" }))
    map(
      "n",
      "<leader>bo",
      "<cmd>BufferLineCloseOthers<CR>",
      vim.tbl_extend("force", d, { desc = "Close other buffers" })
    )
    map("n", "<leader>ba", "<cmd>bufdo bdelete<CR>", vim.tbl_extend("force", d, { desc = "Close all buffers" }))
    map("n", "<leader>b<", "<cmd>BufferLineMovePrev<CR>", vim.tbl_extend("force", d, { desc = "Move buffer left" }))
    map("n", "<leader>b>", "<cmd>BufferLineMoveNext<CR>", vim.tbl_extend("force", d, { desc = "Move buffer right" }))

    for i = 1, 9 do
      map("n", "<leader>b" .. i, function()
        require("bufferline").go_to(i, true)
      end, vim.tbl_extend("force", d, { desc = "Go to buffer " .. i }))
    end
  end,
}
