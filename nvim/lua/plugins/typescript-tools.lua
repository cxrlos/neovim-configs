return {
  "pmizio/typescript-tools.nvim",
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  config = function()
    local lsp = require("lsp")
    require("typescript-tools").setup({
      on_attach = lsp.on_attach,
      capabilities = lsp.capabilities,
      settings = {
        tsserver_file_preferences = {
          includeInlayParameterNameHints = "all",
          includeInlayVariableTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
        },
        expose_as_code_action = {
          "fix_all",
          "add_missing_imports",
          "remove_unused_imports",
        },
      },
    })
  end,
}
