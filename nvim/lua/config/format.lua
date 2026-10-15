-- Formatting (conform)

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
