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
vim.o.mouse = "" -- keyboard only (tmux and the terminal too)

-- Keymaps
-- Counted j/k (e.g. 12j) go into the jumplist, so <C-o> comes back
for _, key in ipairs({ "j", "k" }) do
  vim.keymap.set({ "n", "x" }, key, function()
    return (vim.v.count > 1 and "m'" .. vim.v.count or "") .. key
  end, { expr = true, desc = "Move " .. key .. " (counted moves join the jumplist)" })
end

vim.keymap.set("n", "<Esc>", "<Cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlight" })

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

-- Plugins: vim.pack, pinned in nvim-pack-lock.json. Update with :lua vim.pack.update()
vim.pack.add({
  { src = "https://github.com/MunifTanjim/nui.nvim", version = vim.version.range("0.4") }, -- :Hardtime report
  { src = "https://github.com/m4xshen/hardtime.nvim", version = vim.version.range("1") },
  { src = "https://github.com/tris203/precognition.nvim", version = vim.version.range("1") },
})

-- Habit trainer (temporary, 2-4 weeks): hints a better motion, never blocks. :Hardtime report
-- Set up after the keymaps: it wraps whatever j/k/... maps exist when it starts.
require("hardtime").setup({ restriction_mode = "hint", disable_mouse = false })

-- Motion hints, hidden until asked for (trial: keep or drop)
require("precognition").setup({ startVisible = false })
vim.keymap.set("n", "<leader>tp", function()
  require("precognition").toggle()
end, { desc = "Toggle motion hints (precognition)" })
