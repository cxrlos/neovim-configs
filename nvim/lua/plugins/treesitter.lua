-- nvim-treesitter MAIN branch — required on Neovim 0.11+/0.12. The master branch
-- is frozen and its query predicates break on 0.12's treesitter API (the
-- `range` / `get_node_text` crash via injections, e.g. render-markdown).
-- Highlighting is started per-buffer in a FileType autocmd; parsers are pulled
-- via install(). Bundled parsers (c, lua, markdown, markdown_inline, query, vim,
-- vimdoc) are intentionally NOT listed — Neovim ships them.
local ensure = {
  "rust", "python", "typescript", "tsx", "javascript", "html", "css", "json",
  "terraform", "hcl", "dockerfile", "yaml", "bash", "toml", "regex",
  "gitignore", "gitcommit",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(ensure)

      -- nvim-treesitter main's queries/vim/highlights.scm targets a grammar
      -- newer than Neovim's bundled `vim` parser (references node type "tab",
      -- which the bundled parser doesn't have). That merged query is invalid
      -- and crashes anything highlighting vim-language text via treesitter
      -- (e.g. noice's cmdline syntax highlighting), with no pcall to catch it.
      -- Force the highlights query back to Neovim's own bundled one, which is
      -- version-matched to the bundled parser.
      do
        local bundled = vim.env.VIMRUNTIME .. "/queries/vim/highlights.scm"
        local f = io.open(bundled, "r")
        if f then
          local content = f:read("*a")
          f:close()
          vim.treesitter.query.set("vim", "highlights", content)
        end
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          -- start highlighting only where a parser is actually available
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })
      local map = vim.keymap.set
      local select = require("nvim-treesitter-textobjects.select").select_textobject
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      local objects = {
        af = "@function.outer",
        ["if"] = "@function.inner",
        ac = "@class.outer",
        ic = "@class.inner",
        aa = "@parameter.outer",
        ia = "@parameter.inner",
      }
      for lhs, query in pairs(objects) do
        map({ "x", "o" }, lhs, function() select(query, "textobjects") end, { desc = "Textobject " .. query })
      end

      map("n", "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function start" })
      map("n", "]c", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Next class start" })
      map("n", "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev function start" })
      map("n", "[c", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "Prev class start" })

      map("n", "<leader>sa", function() swap.swap_next("@parameter.inner") end, { desc = "Swap arg forward" })
      map("n", "<leader>sA", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap arg backward" })
    end,
  },
}
