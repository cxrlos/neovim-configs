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
  init = function()
    local map = require("config.map")
    local d = { group = "Find", docs = "navigation-cheatsheet.md" }
    local function tb(name)
      return function()
        require("telescope.builtin")[name]()
      end
    end

    map("n", "<leader>ff", tb("find_files"), vim.tbl_extend("force", d, { desc = "Find files" }))
    map("n", "<leader>fg", tb("live_grep"), vim.tbl_extend("force", d, { desc = "Live grep" }))
    map("n", "<leader>fr", tb("oldfiles"), vim.tbl_extend("force", d, { desc = "Recent files" }))
    map("n", "<leader>fb", tb("buffers"), vim.tbl_extend("force", d, { desc = "Buffers" }))
    map("n", "<leader>fh", tb("help_tags"), vim.tbl_extend("force", d, { desc = "Help tags" }))
    map("n", "<leader>fs", tb("lsp_document_symbols"), vim.tbl_extend("force", d, { desc = "Document symbols" }))
    map("n", "<leader>fw", tb("lsp_workspace_symbols"), vim.tbl_extend("force", d, { desc = "Workspace symbols" }))
    map("n", "<leader>fd", tb("diagnostics"), vim.tbl_extend("force", d, { desc = "Diagnostics" }))
    map("n", "<leader>fc", tb("command_history"), vim.tbl_extend("force", d, { desc = "Command history" }))
  end,
  config = function()
    local shared = require("config.shared")
    local telescope = require("telescope")
    local actions = require("telescope.actions")

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
  end,
}
