local M = {}

M._diag_float_win = nil

function M.setup()
  local shared = require("config.shared")
  local icons = shared.icons.diagnostics

  vim.diagnostic.config({
    virtual_text = {
      prefix = shared.icons.ui.dot,
      source = "if_many",
    },
    signs = {
      text = {
        [vim.diagnostic.severity.ERROR] = icons.error,
        [vim.diagnostic.severity.WARN] = icons.warn,
        [vim.diagnostic.severity.HINT] = icons.hint,
        [vim.diagnostic.severity.INFO] = icons.info,
      },
    },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = shared.border,
      source = true,
    },
  })

  -- Neovim 0.11+: one global border for hover, signature help, and other floats
  -- replaces the deprecated per-handler vim.lsp.with() overrides.
  vim.o.winborder = shared.border

  vim.api.nvim_create_autocmd("CursorHold", {
    group = vim.api.nvim_create_augroup("user_diagnostic_hover", { clear = true }),
    callback = function()
      local _, win = vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter" },
        border = shared.border,
        source = true,
        scope = "cursor",
      })
      M._diag_float_win = win
    end,
  })
end

function M.close_diag_float()
  if M._diag_float_win and vim.api.nvim_win_is_valid(M._diag_float_win) then
    vim.api.nvim_win_close(M._diag_float_win, true)
    M._diag_float_win = nil
  end
end

return M
