return {
  "mrcjkb/rustaceanvim",
  version = "^5",
  ft = { "rust" },
  config = function()
    local lsp = require("lsp")
    vim.g.rustaceanvim = {
      server = {
        on_attach = lsp.on_attach,
        capabilities = lsp.capabilities,
        default_settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = { command = "clippy" },
            inlayHints = { lifetimeElisionHints = { enable = "always" } },
          },
        },
      },
    }
  end,
}
