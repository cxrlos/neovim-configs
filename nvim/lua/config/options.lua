local opt = vim.opt

opt.number = true
opt.relativenumber = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.wrap = false
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.hlsearch = false
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.termguicolors = true
opt.cursorline = true
-- Block (steady) in normal/visual, thin bar in insert; colored via the Cursor
-- highlight (set in colorscheme.lua) so it stays visible over a selection.
opt.guicursor = "n-v-c:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkon0"
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"

opt.autoread = true

opt.splitbelow = true
opt.splitright = true

opt.updatetime = 50
opt.timeoutlen = 300

opt.mouse = "a"
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 0
opt.fileencoding = "utf-8"
opt.spelllang = { "en_us" }
