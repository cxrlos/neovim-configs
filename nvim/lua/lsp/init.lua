local M = {}

function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end
  return capabilities
end

M.capabilities = M.get_capabilities()

function M.on_attach(client, bufnr)
  local map = require("config.map")
  local d = { buffer = bufnr, group = "LSP", docs = "lsp-cheatsheet.md" }

  map("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("force", d, { desc = "Go to definition" }))

  map("n", "gD", function()
    local ok_telescope, builtin = pcall(require, "telescope.builtin")
    if ok_telescope then
      builtin.lsp_references({ include_declaration = false, initial_mode = "normal" })
    else
      vim.lsp.buf.references()
    end
  end, vim.tbl_extend("force", d, { desc = "Show all usages" }))

  map("n", "K", function()
    require("lsp.handlers").close_diag_float()
    vim.lsp.buf.hover()
  end, vim.tbl_extend("force", d, { desc = "Hover documentation" }))
  map("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("force", d, { desc = "Rename symbol" }))
  map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("force", d, { desc = "Code action" }))
  map("n", "<leader>D", vim.lsp.buf.type_definition, vim.tbl_extend("force", d, { desc = "Type definition" }))
  map("n", "<leader>ds", vim.lsp.buf.document_symbol, vim.tbl_extend("force", d, { desc = "Document symbols" }))
  map("n", "<leader>ws", vim.lsp.buf.workspace_symbol, vim.tbl_extend("force", d, { desc = "Workspace symbols" }))

  map("n", "[d", vim.diagnostic.goto_prev, vim.tbl_extend("force", d, { desc = "Prev diagnostic" }))
  map("n", "]d", vim.diagnostic.goto_next, vim.tbl_extend("force", d, { desc = "Next diagnostic" }))
end

return M
