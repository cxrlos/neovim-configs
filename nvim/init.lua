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
})

-- Language parsing (treesitter). Parsers nvim ships (c, lua, markdown, query, vim, vimdoc) aren't listed.
require("nvim-treesitter").install({
  "bash", "diff", "git_rebase", "gitcommit", "javascript", "json", "python",
  "regex", "rust", "toml", "tsx", "typescript", "yaml",
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

-- Code text objects: af/if function, ac/ic class, au/iu call (mini.ai's default f, renamed).
-- Next/last move to aN/iN/aL/iL so nvim's built-in an/in (grow/shrink selection) keep working.
local ai = require("mini.ai")
ai.setup({
  n_lines = 500, -- search far enough to find the edges of a long function
  custom_textobjects = {
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    u = ai.gen_spec.function_call(),
  },
  mappings = { around_next = "aN", inside_next = "iN", around_last = "aL", inside_last = "iL" },
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

-- Habit trainer (temporary, 2-4 weeks): hints a better motion, never blocks. :Hardtime report
-- Set up after the keymaps: it wraps whatever j/k/... maps exist when it starts.
require("hardtime").setup({ restriction_mode = "hint", disable_mouse = false })

-- Motion hints, hidden until asked for (trial: keep or drop)
require("precognition").setup({ startVisible = false })
vim.keymap.set("n", "<leader>tp", function()
  require("precognition").toggle()
end, { desc = "Toggle motion hints (precognition)" })
