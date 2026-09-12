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
  base = "#282828",
  surface = "#3c3836",
  overlay = "#504945",
  muted = "#7c6f64",
  subtle = "#a89984",
  text = "#ebdbb2",
  love = "#fb4934",
  gold = "#fabd2f",
  rose = "#fe8019",
  pine = "#b8bb26",
  foam = "#8ec07c",
  iris = "#d3869b",
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
