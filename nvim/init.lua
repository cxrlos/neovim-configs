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

-- Keymaps
-- Search jumps land mid-screen (zv opens a fold over the match)
for _, key in ipairs({ "n", "N", "*", "#" }) do
  vim.keymap.set("n", key, key .. "zzzv", { desc = "Search " .. key .. ", centred" })
end

-- y stays inside nvim; Y is the only way to the system clipboard
vim.keymap.set({ "n", "x" }, "Y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set("n", "YY", '"+yy', { desc = "Yank line to system clipboard" })

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
