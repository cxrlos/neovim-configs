return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },
  keys = {
    { "<leader>ff", desc = "Find files" },
    { "<leader>fg", desc = "Live grep" },
    { "<leader>fr", desc = "Recent files" },
    { "<leader>fb", desc = "Buffers" },
    { "<leader>fh", desc = "Help tags" },
    { "<leader>fs", desc = "Document symbols" },
    { "<leader>fw", desc = "Workspace symbols" },
    { "<leader>fd", desc = "Diagnostics" },
    { "<leader>fc", desc = "Command history" },
  },
  config = function()
    local map = require("config.map")
    local shared = require("config.shared")
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        prompt_prefix = shared.icons.ui.arrow_right .. " ",
        selection_caret = shared.icons.ui.dot .. " ",
        border = true,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        sorting_strategy = "ascending",
        layout_config = {
          prompt_position = "top",
          horizontal = { preview_width = 0.55 },
        },
        mappings = {
          i = {
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          },
          n = {
            ["<Esc>"] = actions.close,
            ["q"] = actions.close,
          },
        },
      },
    })

    pcall(telescope.load_extension, "fzf")

    local d = { group = "Find", docs = "navigation-cheatsheet.md" }

    map("n", "<leader>ff", builtin.find_files, vim.tbl_extend("force", d, { desc = "Find files" }))
    map("n", "<leader>fg", function()
      builtin.grep_string({ search = "", only_sort_text = true })
    end, vim.tbl_extend("force", d, { desc = "Live grep" }))
    map("n", "<leader>fr", builtin.oldfiles, vim.tbl_extend("force", d, { desc = "Recent files" }))
    map("n", "<leader>fb", builtin.buffers, vim.tbl_extend("force", d, { desc = "Buffers" }))
    map("n", "<leader>fh", builtin.help_tags, vim.tbl_extend("force", d, { desc = "Help tags" }))
    map("n", "<leader>fs", builtin.lsp_document_symbols, vim.tbl_extend("force", d, { desc = "Document symbols" }))
    map("n", "<leader>fw", builtin.lsp_workspace_symbols, vim.tbl_extend("force", d, { desc = "Workspace symbols" }))
    map("n", "<leader>fd", builtin.diagnostics, vim.tbl_extend("force", d, { desc = "Diagnostics" }))
    map("n", "<leader>fc", builtin.command_history, vim.tbl_extend("force", d, { desc = "Command history" }))
  end,
}
