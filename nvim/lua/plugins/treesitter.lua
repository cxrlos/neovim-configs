return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua",
          "vim",
          "vimdoc",
          "markdown",
          "markdown_inline",
          "rust",
          "python",
          "typescript",
          "tsx",
          "javascript",
          "html",
          "css",
          "json",
          "terraform",
          "hcl",
          "dockerfile",
          "yaml",
          "bash",
          "toml",
          "regex",
          "gitignore",
          "gitcommit",
        },
        auto_install = false,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = { query = "@function.outer", desc = "Around function" },
              ["if"] = { query = "@function.inner", desc = "Inside function" },
              ["ac"] = { query = "@class.outer", desc = "Around class" },
              ["ic"] = { query = "@class.inner", desc = "Inside class" },
              ["aa"] = { query = "@parameter.outer", desc = "Around argument" },
              ["ia"] = { query = "@parameter.inner", desc = "Inside argument" },
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]f"] = { query = "@function.outer", desc = "Next function start" },
              ["]c"] = { query = "@class.outer", desc = "Next class start" },
            },
            goto_previous_start = {
              ["[f"] = { query = "@function.outer", desc = "Prev function start" },
              ["[c"] = { query = "@class.outer", desc = "Prev class start" },
            },
          },
          swap = {
            enable = true,
            swap_next = { ["<leader>sa"] = { query = "@parameter.inner", desc = "Swap arg forward" } },
            swap_previous = { ["<leader>sA"] = { query = "@parameter.inner", desc = "Swap arg backward" } },
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPre",
    opts = {
      max_lines = 3,
      trim_scope = "outer",
    },
  },
}
