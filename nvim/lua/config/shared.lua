local M = {}

M.debug = false

M.border = "rounded"

M.icons = {
  diagnostics = {
    error = "✘ ",
    warn = "▲ ",
    hint = "◆ ",
    info = "● ",
  },
  git = {
    add = "+",
    change = "~",
    delete = "-",
  },
  ui = {
    arrow_right = "▶",
    arrow_left = "◀",
    dot = "●",
    folder = "▸ ",
    file = "· ",
    ellipsis = "…",
  },
}

local log_path = vim.fn.stdpath("log") .. "/user_debug.log"

function M.log(msg)
  if not M.debug then
    return
  end
  local timestamp = os.date("%H:%M:%S")
  local line = string.format("[%s] %s", timestamp, msg)
  vim.fn.writefile({ line }, log_path, "a")
end

return M
