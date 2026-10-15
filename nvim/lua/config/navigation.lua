-- Navigation: picker (fzf-lua), explorer (oil), buffers

-- Navigation. fzf-lua runs the system fzf/rg/fd and inherits FZF_DEFAULT_OPTS (colours);
-- files shows dotfiles but skips gitignored ones; grep skips both. In a picker: alt-h toggles
-- hidden, alt-i ignored files. oil edits a directory like a buffer.
require("mini.icons").setup() -- file icons for fzf-lua and oil (Nerd Font)
vim.o.shada = "!,'1000,<50,s10,h" -- remember 1000 files (default 100) for recent-file search
local fzf = require("fzf-lua")
-- Grep skips files over 1 MB (seed CSVs, notebooks, lockfiles); matches inside them are hidden.
-- Inserted before the trailing -e of fzf-lua's own rg_opts rather than restating them.
local rg_opts, n = require("fzf-lua.defaults").defaults.grep.rg_opts:gsub(" %-e$", " --max-filesize=1M -e")
assert(n == 1, "fzf-lua's default grep rg_opts changed: update the --max-filesize insert")
fzf.setup({ grep = { rg_opts = rg_opts } })
-- The nearest package (package.json, pyproject.toml, dbt_project.yml, Cargo.toml), else the cwd
local package_root = function()
  return vim.fs.root(0, { "package.json", "pyproject.toml", "dbt_project.yml", "Cargo.toml" }) or vim.fn.getcwd()
end
local pick = function(lhs, fn, desc, mode)
  vim.keymap.set(mode or "n", lhs, fn, { desc = desc })
end
pick("<leader><leader>", fzf.buffers, "Pick an open buffer")
pick("<leader>sf", fzf.files, "Search files")
pick("<leader>sg", fzf.live_grep, "Search by grep (live)")
pick("<leader>sw", fzf.grep_cword, "Search the word under the cursor")
pick("<leader>sw", fzf.grep_visual, "Search the selection", "x")
pick("<leader>s/", fzf.blines, "Search lines in this buffer")
pick("<leader>so", function()
  fzf.oldfiles({ cwd_only = true, include_current_session = true })
end, "Search recent files in this project")
pick("<leader>sO", fzf.oldfiles, "Search recent files everywhere")
pick("<leader>sp", function() fzf.files({ cwd = package_root() }) end, "Search files in this package")
pick("<leader>sP", function() fzf.live_grep({ cwd = package_root() }) end, "Search by grep in this package")
pick("<leader>sc", fzf.git_status, "Search changed files (git status, incl. untracked)")
pick("<leader>sq", fzf.grep_quickfix, "Search by grep within the quickfix list")
pick("<leader>sr", fzf.resume, "Resume the last search")
pick("<leader>ss", fzf.lsp_live_workspace_symbols, "Search symbols in the project (LSP)")
pick("<leader>sd", fzf.diagnostics_workspace, "Search diagnostics in the project")
pick("<leader>sh", fzf.helptags, "Search help")
pick("<leader>sk", fzf.keymaps, "Search keymaps")

require("oil").setup({
  watch_for_changes = true, -- files the agent creates show up
  delete_to_trash = true, -- safety net: oil has open data-loss reports (#768, #780)
  lsp_file_methods = { timeout_ms = 5000 }, -- big TS repos need more than 1 s to answer renames
  keymaps = {
    ["<C-h>"] = false, -- keep Ctrl+hjkl for split/tmux navigation
    ["<C-l>"] = false,
    ["<C-x>"] = { "actions.select", opts = { horizontal = true } },
  },
})
vim.keymap.set("n", "-", "<Cmd>Oil<CR>", { desc = "Open the parent directory (oil)" })
vim.keymap.set("n", "<leader>bd", function()
  require("mini.bufremove").delete()
end, { desc = "Delete the buffer, keep the window" })
