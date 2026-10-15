-- Language parsing: treesitter, function motions, sticky context

-- Language parsing (treesitter). Parsers nvim ships (c, lua, markdown, query, vim, vimdoc) aren't listed.
require("nvim-treesitter").install({
  "bash", "css", "diff", "git_rebase", "gitcommit", "hcl", "html", "javascript", "jsdoc", "json",
  "python", "regex", "rust", "scss", "terraform", "toml", "tsx", "typescript", "yaml",
})
vim.o.foldlevelstart = 99 -- files open unfolded; zc/zo/zM/zR fold by code structure
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter", {}),
  desc = "Treesitter highlighting and folds where a parser exists",
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

-- ]m [m ]M [M: built-in "next method" counts braces; these use the syntax tree instead.
-- Python's ftplugin maps them (and ]] [[) per buffer, which would win over these.
vim.g.no_python_maps = true
local move = require("nvim-treesitter-textobjects.move")
for lhs, fn in pairs({
  ["]m"] = { move.goto_next_start, "Next function start" },
  ["[m"] = { move.goto_previous_start, "Previous function start" },
  ["]M"] = { move.goto_next_end, "Next function end" },
  ["[M"] = { move.goto_previous_end, "Previous function end" },
}) do
  vim.keymap.set({ "n", "x", "o" }, lhs, function()
    fn[1]("@function.outer", "textobjects")
  end, { desc = fn[2] })
end

-- Sticky context: the enclosing function/class header stays at the top while you scroll
require("treesitter-context").setup({ max_lines = 3 })
