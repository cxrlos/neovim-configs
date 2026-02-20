local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
  group = augroup("yank_highlight"),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

autocmd("BufReadPost", {
  group = augroup("restore_cursor"),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current)
  end,
})

autocmd("FileType", {
  group = augroup("prose_files"),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

autocmd("BufEnter", {
  group = augroup("dir_open"),
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if vim.fn.isdirectory(bufname) ~= 1 then
      return
    end
    vim.schedule(function()
      local ok, neotree = pcall(require, "neo-tree.command")
      if not ok then
        return
      end
      local dir = bufname:gsub("/$", "")
      vim.cmd("bdelete " .. vim.fn.bufnr(bufname))
      local readme = dir .. "/README.md"
      if vim.fn.filereadable(readme) == 1 then
        vim.cmd("edit " .. readme)
      end
      neotree.execute({ action = "show", dir = dir })
      vim.cmd("wincmd l")
    end)
  end,
})

autocmd("VimEnter", {
  group = augroup("auto_tree"),
  nested = true,
  callback = vim.schedule_wrap(function()
    local buf = vim.api.nvim_get_current_buf()
    local name = vim.api.nvim_buf_get_name(buf)
    local ft = vim.bo[buf].filetype
    if ft == "dashboard" or name == "" or vim.fn.isdirectory(name) == 1 then
      return
    end
    local ok, neotree = pcall(require, "neo-tree.command")
    if ok then
      neotree.execute({ action = "show" })
      vim.cmd("wincmd l")
    end
  end),
})

autocmd("BufAdd", {
  group = augroup("max_buffers"),
  callback = function()
    local listed = vim.fn.getbufinfo({ buflisted = 1 })
    if #listed > 10 then
      vim.notify(
        string.format("%d buffers open. Close unused ones with <leader>bd or <leader>bo.", #listed),
        vim.log.levels.WARN
      )
    end
  end,
})

local project_markers = {
  python = { "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile" },
  rust = { "Cargo.toml" },
  typescript = { "package.json", "tsconfig.json" },
  javascript = { "package.json" },
  terraform = { "main.tf" },
}

local prompted_roots = {}

autocmd("FileType", {
  group = augroup("project_root_check"),
  pattern = vim.tbl_keys(project_markers),
  callback = function(event)
    vim.schedule(function()
      local ft = vim.bo[event.buf].filetype
      local markers = project_markers[ft]
      if not markers then
        return
      end

      local file = vim.api.nvim_buf_get_name(event.buf)
      if file == "" then
        return
      end

      local root = vim.fs.root(event.buf, markers)
      if root then
        return
      end

      local dir = vim.fn.fnamemodify(file, ":h")
      if prompted_roots[dir] then
        return
      end
      prompted_roots[dir] = true

      vim.notify(
        string.format(
          "No project root found for %s.\nLSP features (gd, references) need a project marker.\nExpected one of: %s",
          ft,
          table.concat(markers, ", ")
        ),
        vim.log.levels.WARN
      )
    end)
  end,
})

autocmd("FileType", {
  group = augroup("quick_close"),
  pattern = { "help", "lspinfo", "man", "notify", "qf", "checkhealth", "query" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})
