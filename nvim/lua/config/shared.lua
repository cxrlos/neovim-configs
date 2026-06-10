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
  category = {
    find = "▸",
    edit = "✎",
    code = "λ",
    git = "+",
    agent = "◆",
    general = "❯",
  },
}

M.palette = {
  base = "#191724",
  surface = "#1f1d2e",
  overlay = "#26233a",
  muted = "#6e6a86",
  subtle = "#908caa",
  text = "#e0def4",
  love = "#eb6f92",
  gold = "#f6c177",
  rose = "#ebbcba",
  pine = "#31748f",
  foam = "#9ccfd8",
  iris = "#c4a7e7",
}

M.category_color = {
  find = M.palette.foam,
  edit = M.palette.rose,
  code = M.palette.gold,
  git = M.palette.pine,
  agent = M.palette.iris,
  general = M.palette.subtle,
}

M.category_order = { "find", "edit", "code", "git", "agent", "general" }

local group_to_category = {
  Telescope = "find",
  Harpoon = "find",
  ["File Tree"] = "find",
  Buffer = "find",
  Navigation = "find",
  Editing = "edit",
  Clipboard = "edit",
  Quickfix = "edit",
  Windows = "edit",
  LSP = "code",
  Code = "code",
  Git = "git",
  Agent = "agent",
  General = "general",
  Markdown = "general",
}

function M.category_for_group(group)
  return group_to_category[group] or "general"
end

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
