return {
  settings = {
    Lua = {
      workspace = {
        checkThirdParty = false,
        library = { vim.fn.stdpath("config") .. "/lua" },
      },
      telemetry = { enable = false },
      diagnostics = { disable = { "missing-fields" } },
    },
  },
}
