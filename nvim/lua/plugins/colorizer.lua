return {
  "NvChad/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = {
    user_default_options = {
      css = true,
      tailwind = true,
      mode = "virtualtext",
      virtualtext = "●",
    },
    filetypes = { "css", "html", "javascript", "typescript", "typescriptreact", "javascriptreact", "lua" },
  },
}
