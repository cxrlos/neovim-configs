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

-- Git status in oil: changed entries get their `git status -s` flags at the end of the line.
-- Green = staged (reviewed), yellow = still to review, ?? = untracked, red = deleted; a folder gets
-- • when something inside changed. Own code: the oil git plugins are small one-person projects.
-- Cost: one `git status` scoped to the listed folder, async (9 ms in a 50k-file repo). Skipped
-- while the listing has unsaved edits (it refreshes after :w); bursts collapse into one run.
local oil_git = vim.api.nvim_create_namespace("oil-git-status")
local function oil_git_render(buf, dir)
  local prefix = vim.system({ "git", "-C", dir, "rev-parse", "--show-prefix" }, { text = true }):wait()
  if prefix.code ~= 0 then return end -- not in a git repo
  prefix = vim.trim(prefix.stdout)
  vim.system({ "git", "-C", dir, "status", "--porcelain", "--untracked-files=all", "--", "." }, { text = true },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 or not vim.api.nvim_buf_is_valid(buf) then return end
      local marks = {}
      for line in vim.gsplit(res.stdout, "\n", { trimempty = true }) do
        local xy, path = line:sub(1, 2), line:sub(4):gsub("^.* %-> ", "")
        local name, rest = path:sub(#prefix + 1):match("^([^/]+)(.*)$")
        if name then
          local hl = (xy == "??" or xy:sub(2) ~= " ") and "Changed" or "Added"
          if xy:find("D") then hl = "Removed" end
          marks[name] = rest == "" and { vim.trim(xy), hl } or marks[name] or { "•", "Changed" }
        end
      end
      vim.api.nvim_buf_clear_namespace(buf, oil_git, 0, -1)
      for lnum = 1, vim.api.nvim_buf_line_count(buf) do
        local entry = require("oil").get_entry_on_line(buf, lnum)
        local mark = entry and marks[entry.name]
        if mark then
          vim.api.nvim_buf_set_extmark(buf, oil_git, lnum - 1, 0, { virt_text = { { " " .. mark[1], mark[2] } } })
        end
      end
    end))
end
local oil_git_pending = {}
local function oil_git_status(buf)
  if oil_git_pending[buf] then return end
  oil_git_pending[buf] = true
  vim.defer_fn(function()
    oil_git_pending[buf] = nil
    if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].modified then return end
    local dir = require("oil").get_current_dir(buf)
    if dir then oil_git_render(buf, dir) end
  end, 150)
end
local oil_group = vim.api.nvim_create_augroup("oil-git-status", {})
vim.api.nvim_create_autocmd("User", {
  group = oil_group,
  pattern = { "OilEnter", "OilMutationComplete" },
  desc = "Git status flags in oil",
  callback = function(ev) oil_git_status(ev.data and ev.data.buf or vim.api.nvim_get_current_buf()) end,
})
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "TextChanged" }, {
  group = oil_group,
  desc = "Refresh git status flags in oil",
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "oil" then oil_git_status(ev.buf) end
  end,
})
