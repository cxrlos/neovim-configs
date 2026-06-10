local registry = {}

local function normalize_lhs(mode, lhs)
  local leader = vim.g.mapleader or "\\"
  if #leader == 1 and lhs:sub(1, 1) == leader then
    return "<leader>" .. lhs:sub(2)
  end
  return lhs
end

local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  local group = opts.group
  local docs = opts.docs
  local vim_opts = vim.tbl_extend("force", opts, {})
  vim_opts.group = nil
  vim_opts.docs = nil
  vim.keymap.set(mode, lhs, rhs, vim_opts)

  if not opts.desc or opts.desc == "" then
    return
  end

  local modes = type(mode) == "table" and mode or { mode }
  for _, m in ipairs(modes) do
    table.insert(registry, {
      lhs = normalize_lhs(m, lhs),
      raw = lhs,
      mode = m,
      desc = opts.desc,
      group = group or "General",
      file = docs or "core-cheatsheet.md",
    })
  end
end

local function get_keymaps()
  return registry
end

local function get_groups()
  local shared = require("config.shared")
  local seen = {}
  local groups = {}
  for _, km in ipairs(registry) do
    local first = km.lhs:match("^<leader>(.)")
    if first then
      local prefix = "<leader>" .. first
      if not seen[prefix] then
        seen[prefix] = true
        table.insert(groups, {
          prefix = prefix,
          label = km.group,
          category = shared.category_for_group(km.group),
        })
      end
    end
  end
  return groups
end

return setmetatable({
  get_keymaps = get_keymaps,
  get_groups = get_groups,
}, {
  __call = function(_, mode, lhs, rhs, opts)
    map(mode, lhs, rhs, opts)
  end,
})
