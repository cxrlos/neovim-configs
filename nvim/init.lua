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

-- Look: Tokyo Night (night), like Alacritty, tmux, fzf and delta. Without lazy.nvim it would
-- style every plugin it knows; list only the ones in use (add gitsigns/neogit with the git batch).
require("tokyonight").setup({
  style = "night",
  plugins = {
    all = false,
    ["fzf-lua"] = true,
    ["mini.icons"] = true,
    ["mini.surround"] = true,
    ["nvim-treesitter-context"] = true,
    ["render-markdown.nvim"] = true,
    ["gitsigns.nvim"] = true,
    ["neogit"] = true,
  },
})
vim.cmd.colorscheme("tokyonight")

-- Markdown renders in the buffer (headings, tables, checkboxes, code); the cursor line shows the
-- raw text, and insert mode shows it all. No browser, no server.
require("render-markdown").setup({ latex = { enabled = false } }) -- no LaTeX toolchain (skipped)

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

-- Surround: sa add (saiw" quotes a word), sd delete (sd"), sr replace (sr"'), sf/sh find/highlight.
-- Plain s waits a moment for these; use cl for the built-in s.
require("mini.surround").setup()

-- Indent text objects: ii / ai = this indentation block (Python, YAML), [i ]i its edges.
-- Never drawn: only the text objects and motions are wanted.
require("mini.indentscope").setup({ draw = { predicate = function() return false end } })

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

-- LSP. Servers come from term-configs install.sh (dnf / pinned npm / pinned binaries) or brew;
-- nvim-lspconfig supplies their configs. Node servers prefer the project's node_modules/.bin.
-- Keys are nvim's defaults: grr references, gri implementations, grt type definition, grn rename,
-- gra code action, gO symbols, K hover, <C-s> signature help (insert), ]d [d diagnostics. Plus gd.
vim.lsp.config("lua_ls", {
  -- Without a .luarc.json, assume Lua for nvim: LuaJIT plus the runtime's API (no lazydev)
  on_init = function(client)
    local root = client.workspace_folders and client.workspace_folders[1].name
    if root and (vim.uv.fs_stat(root .. "/.luarc.json") or vim.uv.fs_stat(root .. "/.luarc.jsonc")) then
      return
    end
    client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua or {}, {
      runtime = { version = "LuaJIT", path = { "lua/?.lua", "lua/?/init.lua" } },
      workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
    })
  end,
  settings = { Lua = {} },
})
vim.lsp.config("basedpyright", {
  settings = { basedpyright = { disableOrganizeImports = true } }, -- ruff owns imports
})
vim.lsp.config("jsonls", {
  settings = {
    json = {
      validate = { enable = true },
      schemas = {
        { fileMatch = { "package.json" }, url = "https://json.schemastore.org/package.json" },
        { fileMatch = { "tsconfig*.json", "jsconfig*.json" }, url = "https://json.schemastore.org/tsconfig.json" },
      },
    },
  },
})
-- Completion: nvim's own. The menu opens as you type (words from open buffers, plus the language
-- server where one is attached). <C-n>/<C-p> move, <C-y> accepts (only <C-y> applies auto-imports
-- and snippets), <C-e> closes. <Tab>/<S-Tab> jump through snippet fields. No auto-pairs.
vim.o.autocomplete = true
vim.o.complete = ".^5,w^3,b^3" -- buffer words, capped; the LSP source is added per buffer below
vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.pumheight = 10

-- eslint and biome attach only where their config file exists
vim.lsp.enable({
  "ts_ls", "html", "cssls", "jsonls", "eslint", "biome",
  "basedpyright", "ruff", "rust_analyzer", "lua_ls", "terraformls", "marksman", "bashls", "yamlls",
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", {}),
  desc = "LSP: completion source, gd, ruff hover off, symbol highlight",
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if client.name == "ruff" then
      client.server_capabilities.hoverProvider = false -- basedpyright owns hover
    end
    if client:supports_method("textDocument/completion") then
      -- The server feeds the omnifunc; 'autocomplete' does the triggering (one trigger owner)
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = false })
      if not vim.bo[ev.buf].complete:find("^o") then
        vim.bo[ev.buf].complete = "o," .. vim.bo[ev.buf].complete
      end
    end
    if client:supports_method("textDocument/definition") then
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = ev.buf, desc = "Go to definition (LSP)" })
    end
    if client:supports_method("textDocument/documentHighlight") then
      local group = vim.api.nvim_create_augroup("lsp-highlight-" .. ev.buf, {})
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = group, buffer = ev.buf, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group, buffer = ev.buf, callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

-- Diagnostics: short inline text (source only when several servers report); <leader>td swaps it
-- for full messages under the cursor line.
local inline = { source = "if_many" }
vim.diagnostic.config({ virtual_text = inline, severity_sort = true })
vim.keymap.set("n", "<leader>td", function()
  local full = vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = not full and { current_line = true }, virtual_text = full and inline })
end, { desc = "Toggle full diagnostic messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to the location list" })

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

-- Git review. The index means "reviewed": stage what you approve; what's unstaged is still to
-- review, and reset_hunk drops only the agent's newest edit. gitsigns: hunks in the buffer;
-- Neogit: status, commit (signed), fixup, absorb, rebase; diffview: multi-file and branch diffs,
-- merge conflicts (]x [x, <leader>co/ct/cb/ca; <leader>c* is reserved for it).
require("gitsigns").setup({
  attach_to_untracked = true, -- new files the agent created count as hunks too
  on_attach = function(buf)
    local gs = require("gitsigns")
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end
    map("n", "]c", function()
      if vim.wo.diff then return vim.cmd.normal({ "]c", bang = true }) end
      gs.nav_hunk("next")
    end, "Next git hunk")
    map("n", "[c", function()
      if vim.wo.diff then return vim.cmd.normal({ "[c", bang = true }) end
      gs.nav_hunk("prev")
    end, "Previous git hunk")
    map({ "o", "x" }, "ih", gs.select_hunk, "Inside git hunk")
    map("n", "<leader>hs", gs.stage_hunk, "Hunk: stage (approve) / unstage")
    map("x", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Hunk: stage selection")
    map("n", "<leader>hr", gs.reset_hunk, "Hunk: reset to the index (drop the agent's change)")
    map("x", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Hunk: reset selection")
    map("n", "<leader>hp", gs.preview_hunk_inline, "Hunk: preview inline")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Hunk: blame this line")
    map("n", "<leader>hq", function() gs.setqflist("all") end, "Hunk: every unreviewed hunk to quickfix")
  end,
})
require("diffview").setup({})
require("neogit").setup({ integrations = { diffview = true, fzf_lua = true } })
vim.keymap.set("n", "<leader>gg", "<Cmd>Neogit<CR>", { desc = "Git: status (Neogit)" })
vim.keymap.set("n", "<leader>gd", "<Cmd>DiffviewOpen<CR>", { desc = "Git: diff of unstaged changes" })
vim.keymap.set("n", "<leader>gD", "<Cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<CR>",
  { desc = "Git: this branch vs the default branch" })
vim.keymap.set("n", "<leader>gl", "<Cmd>DiffviewFileHistory --range=origin/HEAD..HEAD<CR>",
  { desc = "Git: this branch's commits" })
vim.keymap.set("n", "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>", { desc = "Git: this file's history" })
vim.keymap.set("n", "<leader>gq", "<Cmd>DiffviewClose<CR>", { desc = "Git: close the diff view" })

-- <leader>gy: GitHub permalink to this line or the selected lines (at HEAD; push first), for PR
-- comments or pointing an agent at code.
vim.keymap.set({ "n", "x" }, "<leader>gy", function()
  local root = vim.fs.root(0, ".git")
  local file = root and vim.fs.relpath(root, vim.api.nvim_buf_get_name(0))
  if not file then return vim.notify("not a file in a git repo", vim.log.levels.WARN) end
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  local lines = a == b and tostring(a) or (math.min(a, b) .. "-" .. math.max(a, b))
  local sha = vim.trim(vim.system({ "git", "rev-parse", "HEAD" }, { cwd = root }):wait().stdout)
  local res = vim.system({ "gh", "browse", "--no-browser", "--commit=" .. sha, file .. ":" .. lines }, { cwd = root }):wait()
  if res.code ~= 0 then return vim.notify(vim.trim(res.stderr), vim.log.levels.ERROR) end
  vim.fn.setreg("+", vim.trim(res.stdout))
  vim.notify("copied " .. vim.trim(res.stdout))
end, { desc = "Git: copy the GitHub link to this line / selection" })

-- Review notes for the agent (one way: nvim -> agent). Notes go into a quickfix list named
-- "agent-review" (so ]q walks them); <leader>as writes them to .review.md in the repo (globally
-- git-ignored) and types a short prompt into this session's `agent` window without pressing
-- Enter. Stage what you approve before sending: the prompt says staged work is approved.
local REVIEW = "agent-review"
local review_list = function()
  for nr = 1, vim.fn.getqflist({ nr = "$" }).nr do
    local l = vim.fn.getqflist({ nr = nr, id = 0, title = 0 })
    if l.title == REVIEW then return l.id end
  end
  vim.fn.setqflist({}, " ", { title = REVIEW })
  return vim.fn.getqflist({ id = 0 }).id
end
local add_note = function(l1, l2)
  vim.ui.input({ prompt = "Note for the agent: " }, function(text)
    if not text or text == "" then return end
    vim.fn.setqflist({}, "a", {
      id = review_list(),
      items = { { bufnr = vim.api.nvim_get_current_buf(), lnum = l1, end_lnum = l2, text = text } },
    })
  end)
end
vim.keymap.set("n", "<leader>an", function()
  add_note(vim.fn.line("."), vim.fn.line("."))
end, { desc = "Agent: add a review note on this line" })
vim.keymap.set("x", "<leader>an", function()
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  add_note(math.min(a, b), math.max(a, b))
end, { desc = "Agent: add a review note on the selection" })
vim.keymap.set("n", "<leader>al", function()
  vim.cmd(vim.fn.getqflist({ id = review_list(), nr = 0 }).nr .. "chistory | copen")
end, { desc = "Agent: list review notes" })
vim.keymap.set("n", "<leader>ax", function()
  vim.fn.setqflist({}, "r", { id = review_list(), items = {} })
end, { desc = "Agent: clear review notes" })
vim.keymap.set("n", "<leader>as", function()
  local root = vim.fs.root(0, ".git")
  if not (root and vim.env.TMUX) then
    return vim.notify("not in a git repo inside tmux", vim.log.levels.WARN)
  end
  local items = vim.fn.getqflist({ id = review_list(), items = 0 }).items
  if #items == 0 then return vim.notify("no review notes") end
  local out = { "# Review notes (line numbers are from when each note was taken)", "" }
  for _, it in ipairs(items) do
    local file = vim.api.nvim_buf_get_name(it.bufnr)
    local lines = it.end_lnum > it.lnum and (it.lnum .. "-" .. it.end_lnum) or tostring(it.lnum)
    out[#out + 1] = ("- %s:%s %s"):format(vim.fs.relpath(root, file) or file, lines, it.text)
  end
  vim.fn.writefile(out, root .. "/.review.md")
  local session = vim.trim(vim.system({ "tmux", "display-message", "-p", "-t", vim.env.TMUX_PANE, "#S" }):wait().stdout)
  local sent = vim.system({ "tmux", "send-keys", "-t", "=" .. session .. ":agent", "-l",
    "Address every note in .review.md, then stop. Staged changes are approved; don't touch them." }):wait()
  if sent.code ~= 0 then
    return vim.notify("wrote .review.md, but no agent window in " .. session, vim.log.levels.WARN)
  end
  vim.notify("notes sent to " .. session .. ":agent (press Enter there)")
end, { desc = "Agent: write .review.md and type the prompt in the agent window" })

-- Formatting (conform). <leader>f formats the buffer or selection with the project's own tool
-- when it has one (node_modules/.bin), else the installed one; LSP formatting only as a fallback.
-- Format-on-save is opt-in per project: a direnv-allowed .envrc exporting NVIM_FORMAT_ON_SAVE=1
-- (otherwise a repo's own prettier would run on every save). <leader>tf toggles it for the session.
vim.g.format_on_save = vim.env.NVIM_FORMAT_ON_SAVE == "1"
local web = { "biome", "prettier", stop_after_first = true } -- biome only with a biome.json
require("conform").setup({
  formatters_by_ft = {
    python = { "ruff_organize_imports", "ruff_format" },
    lua = { "stylua" },
    rust = { "rustfmt" },
    terraform = { "terraform_fmt" },
    ["terraform-vars"] = { "terraform_fmt" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    javascript = web,
    javascriptreact = web,
    typescript = web,
    typescriptreact = web,
    json = web,
    jsonc = web,
    css = web,
    scss = { "prettier" },
    html = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
  },
  formatters = { biome = { require_cwd = true } },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = function()
    return vim.g.format_on_save and { timeout_ms = 2000 } or nil
  end,
})
vim.keymap.set({ "n", "x" }, "<leader>f", function()
  require("conform").format({ async = true })
end, { desc = "Format the buffer / selection" })
vim.keymap.set("n", "<leader>tf", function()
  vim.g.format_on_save = not vim.g.format_on_save
  vim.notify("format on save: " .. (vim.g.format_on_save and "on" or "off"))
end, { desc = "Toggle format on save" })
