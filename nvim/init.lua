-- Neovim 0.12. Only non-defaults: check `:h vim_diff` and `:h news` before adding an option.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Options
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.scrolloff = 8
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.o.inccommand = "split"
vim.o.confirm = true
vim.o.updatetime = 250
vim.o.virtualedit = "block"
vim.o.expandtab = true -- fallback; editorconfig and ftplugins override
vim.o.shiftwidth = 2
vim.o.grepprg = "rg --vimgrep --smart-case" -- the default -uu searches ignored and hidden files
-- Mouse: the wheel scrolls, clicks and drags do nothing (same in tmux and the terminal).
-- 'mouse' keeps its default (nvi): with it off, tmux doesn't pass the wheel in.
for _, mod in ipairs({ "", "2-", "3-", "4-", "C-", "S-", "A-" }) do
  for _, button in ipairs({ "Left", "Right", "Middle", "X1", "X2" }) do
    for _, event in ipairs({ "Mouse", "Drag", "Release" }) do
      local lhs = "<" .. mod .. button .. event .. ">"
      vim.keymap.set({ "n", "x", "o", "i" }, lhs, "<Nop>", { desc = "Mouse clicks are off" })
    end
  end
end

-- Keymaps
-- Counted j/k (e.g. 12j) go into the jumplist, so <C-o> comes back
for _, key in ipairs({ "j", "k" }) do
  vim.keymap.set({ "n", "x" }, key, function()
    return (vim.v.count > 1 and "m'" .. vim.v.count or "") .. key
  end, { expr = true, desc = "Move " .. key .. " (counted moves join the jumplist)" })
end

vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

-- Ctrl+h/j/k/l: move between splits; at the edge, on to the next tmux pane (tmux.conf sends these
-- keys to nvim). A zoomed tmux pane stays put.
for key, dir in pairs({ h = "L", j = "D", k = "U", l = "R" }) do
  vim.keymap.set("n", "<C-" .. key .. ">", function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd.wincmd(key)
    if vim.api.nvim_get_current_win() == win and vim.env.TMUX then
      vim.system({ "tmux", "if-shell", "-F", "#{window_zoomed_flag}", "", "select-pane -" .. dir })
    end
  end, { desc = "Focus the split or tmux pane " .. ({ h = "left", j = "below", k = "above", l = "right" })[key] })
end

-- Ctrl+Shift+h/j/k/l: move the split's border left/down/up/right (like tmux prefix H/J/K/L); a
-- count moves further. With no split on that axis, resize the tmux pane instead. The terminal
-- sends these as CSI u codes (term-configs alacritty.toml / ghostty), tmux passes them through.
for key, dir in pairs({ h = "L", j = "D", k = "U", l = "R" }) do
  vim.keymap.set("n", "<C-S-" .. key .. ">", function()
    local vertical = key == "h" or key == "l"
    local cells = vim.v.count1 * (vertical and 3 or 2)
    local cur = vim.fn.winnr()
    local after = vim.fn.winnr(vertical and "l" or "j") -- neighbour right / below
    local before = vim.fn.winnr(vertical and "h" or "k") -- neighbour left / above
    if after == cur and before == cur then
      if vim.env.TMUX then vim.system({ "tmux", "resize-pane", "-" .. dir, tostring(cells) }) end
      return
    end
    -- Moving the right/bottom border out grows this split; with no neighbour there, the border
    -- that moves is the left/top one, so the same key shrinks it
    local grow = key == "l" or key == "j"
    if after == cur then grow = not grow end
    vim.cmd((vertical and "vertical " or "") .. "resize " .. (grow and "+" or "-") .. cells)
  end, { desc = "Move the split border " .. ({ h = "left", j = "down", k = "up", l = "right" })[key] })
end

-- Search jumps land mid-screen (zv opens a fold over the match)
for _, key in ipairs({ "n", "N", "*", "#" }) do
  vim.keymap.set("n", key, key .. "zzzv", { desc = "Search " .. key .. ", centred" })
end

-- y stays inside nvim; <leader>y is the only way to the system clipboard (<leader>yy = line)
vim.keymap.set({ "n", "x" }, "<leader>y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", '"+y$', { desc = "Yank to end of line to system clipboard" })

-- Autocommands
-- Pick up agent edits while nvim keeps focus (focus changes are already checked)
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
  group = vim.api.nvim_create_augroup("reload-changed", {}),
  desc = "Reload files changed on disk",
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd.checktime()
    end
  end,
})

-- Reopen files where you left off (not commit messages or rebase todos)
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("last-position", {}),
  desc = "Jump to the last cursor position",
  callback = function(ev)
    local ft = vim.filetype.match({ buf = ev.buf }) or ""
    if ft == "gitcommit" or ft == "gitrebase" then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Spell check prose (]s [s next/previous error, z= suggestions, zg add word); <leader>ts toggles
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("spell", {}),
  pattern = { "markdown", "gitcommit" },
  desc = "Spell check prose",
  callback = function()
    vim.wo[0][0].spell = true
  end,
})
vim.keymap.set("n", "<leader>ts", function()
  vim.wo.spell = not vim.wo.spell
end, { desc = "Toggle spell check" })

-- Agent edits, continued. Your unsaved edits are written when nvim loses focus (switching to the
-- agent window), so the agent never works from a stale file. Only normal file buffers: an oil
-- listing is never saved by accident.
vim.api.nvim_create_autocmd("FocusLost", {
  group = vim.api.nvim_create_augroup("save-on-leave", {}),
  desc = "Write modified file buffers",
  callback = function()
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.bo[buf].modified and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
        vim.api.nvim_buf_call(buf, function() vim.cmd("silent! update") end)
      end
    end
  end,
})
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = vim.api.nvim_create_augroup("changed-on-disk", {}),
  desc = "Say when a file was reloaded",
  callback = function(ev)
    vim.notify(vim.fs.basename(ev.file) .. " changed on disk: reloaded (u undoes)", vim.log.levels.INFO)
  end,
})
-- :DiffOrig compares the buffer with the file on disk (after a "file changed" warning)
vim.api.nvim_create_user_command("DiffOrig", function()
  vim.cmd("vert new | set buftype=nofile | read ++edit # | 0d_ | diffthis | wincmd p | diffthis")
end, { desc = "Diff the buffer against the file on disk" })
vim.opt.diffopt:append("algorithm:histogram")

-- Plugins: vim.pack, pinned in nvim-pack-lock.json. Update with :lua vim.pack.update()
-- Hooks first: they must exist before vim.pack.add installs or updates anything.
vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-hooks", {}),
  desc = "Rebuild treesitter parsers when nvim-treesitter updates",
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

local gh = function(repo) return "https://github.com/" .. repo end
vim.pack.add({
  { src = gh("MunifTanjim/nui.nvim"), version = vim.version.range("0.4") }, -- :Hardtime report
  { src = gh("m4xshen/hardtime.nvim"), version = vim.version.range("1") },
  { src = gh("tris203/precognition.nvim"), version = vim.version.range("1") },
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" }, -- parsers only; needs tree-sitter-cli + cc
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" }, -- queries + ]m motions
  { src = gh("nvim-treesitter/nvim-treesitter-context") }, -- only tag is 2025-05: track the branch
  { src = gh("nvim-mini/mini.nvim"), version = vim.version.range("0.18") },
  { src = gh("neovim/nvim-lspconfig"), version = vim.version.range("2") }, -- server configs (lsp/*.lua) only
  { src = gh("ibhagwan/fzf-lua") }, -- no release tags: track main (the lockfile pins the commit)
  { src = gh("folke/tokyonight.nvim"), version = vim.version.range("4") },
  { src = gh("MeanderingProgrammer/render-markdown.nvim"), version = vim.version.range("8") },
  { src = gh("stevearc/oil.nvim"), version = "master" },
  { src = gh("stevearc/conform.nvim"), version = vim.version.range("9") },
  { src = gh("lewis6991/gitsigns.nvim"), version = vim.version.range("2") }, -- main has unreleased breaking changes
  { src = gh("NeogitOrg/neogit") }, -- last tag is stale: track master (lockfile pins the commit)
  -- One maintainer: a written exception (ARCHITECTURE-DRAFT 4.5). vim.pack can't read its short
  -- tags as versions, so it's pinned to one; bump by hand after reading the release notes.
  { src = gh("dlyongemallo/diffview-plus.nvim"), version = "v0.39" }, -- v2.16 lacks the big-delete crash fix; pin "3" once tagged
})

-- Untrusted checkouts (term-configs `wt pr`, listed one path per line in $XDG_STATE_HOME/wt/untrusted):
-- no language servers or formatters, which could run the checkout's own tools (node_modules/.bin,
-- build scripts, proc macros). Parsing, picker, git review and the rest work as usual.
do
  local cwd, list = vim.fn.getcwd(), (vim.env.XDG_STATE_HOME or vim.env.HOME .. "/.local/state") .. "/wt/untrusted"
  for path in (vim.uv.fs_stat(list) and io.lines(list) or function() end) do
    if path ~= "" and (cwd == path or vim.startswith(cwd, path .. "/")) then vim.g.untrusted = true end
  end
  if vim.g.untrusted then
    vim.schedule(function() vim.notify("untrusted checkout: language servers and formatters are off", vim.log.levels.WARN) end)
  end
end

-- One file per area (lua/config/), in this order: keyhints must stay last.
require("config.look")
require("config.parsing")
require("config.editing")
require("config.lsp")
require("config.navigation")
require("config.git")
require("config.format")
require("config.habits")
require("config.keyhints")
