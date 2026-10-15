-- LSP, completion, diagnostics

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
    vim.schedule(function() MiniClue.ensure_buf_triggers(ev.buf) end) -- after gd, for key hints
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
