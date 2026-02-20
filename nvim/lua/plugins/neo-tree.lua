return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  cmd = "Neotree",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local shared = require("config.shared")

    require("neo-tree").setup({
      close_if_last_window = true,
      popup_border_style = shared.border,
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = { indent_size = 2, with_markers = true },
        name = {
          trailing_slash = false,
          highlight_opened_files = "name",
          use_git_status_colors = true,
        },
        icon = {
          folder_closed = shared.icons.ui.folder:gsub("%s", ""),
          folder_open = "▾",
          folder_empty = "▸",
        },
        git_status = {
          symbols = {
            added = shared.icons.git.add,
            modified = shared.icons.git.change,
            deleted = shared.icons.git.delete,
            renamed = "→",
            untracked = "?",
            ignored = "·",
            unstaged = shared.icons.git.change,
            staged = shared.icons.git.add,
            conflict = "!",
          },
        },
      },
      window = {
        width = 35,
        mappings = {
          ["<space>"] = "none",
          ["<C-h>"] = function()
            vim.cmd("TmuxNavigateLeft")
          end,
          ["<C-l>"] = function()
            vim.cmd("TmuxNavigateRight")
          end,
          ["<C-j>"] = function()
            vim.cmd("TmuxNavigateDown")
          end,
          ["<C-k>"] = function()
            vim.cmd("TmuxNavigateUp")
          end,
        },
      },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
      },
    })

    local function apply_highlights()
      vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", { fg = "#6e6a86", italic = true })
      vim.api.nvim_set_hl(0, "NeoTreeFileName", { fg = "#c8c5dc" })
      vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", { fg = "#e0def4", bold = true })
    end

    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("user_neotree_hl", { clear = true }),
      callback = apply_highlights,
    })
    apply_highlights()

    local map = require("config.map")
    local d = { group = "File Tree", docs = "navigation-cheatsheet.md" }
    map("n", "<leader>e", "<cmd>Neotree toggle<CR>", vim.tbl_extend("force", d, { desc = "Toggle file tree" }))
    map("n", "<leader>E", "<cmd>Neotree reveal<CR>", vim.tbl_extend("force", d, { desc = "Reveal file in tree" }))
  end,
}
