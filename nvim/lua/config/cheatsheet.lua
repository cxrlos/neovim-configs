local M = {}

local function docs_path(file)
  return vim.fn.stdpath("config") .. "/docs/" .. file
end

local function find_source_via_maparg(mode, raw)
  local info = vim.fn.maparg(raw, mode, false, true)
  if not info or type(info) ~= "table" then
    return nil
  end
  if not info.lnum or info.lnum == 0 then
    return nil
  end
  local file = nil
  if info.sid and info.sid > 0 then
    local ok, scripts = pcall(vim.fn.getscriptinfo)
    if ok then
      for _, s in ipairs(scripts) do
        if s.sid == info.sid then
          file = s.name
          break
        end
      end
    end
  end
  if file and file:match("%.lua$") then
    return { file = file, line = info.lnum }
  end
  return nil
end

local function find_source_via_grep(desc)
  local config_dir = vim.fn.stdpath("config") .. "/lua"
  local escaped = vim.fn.escape(desc, '"\\[]().+*?^$')

  local cmd = string.format('grep -rn "%s" "%s" --include="*.lua" | head -1', escaped, config_dir)
  local result = vim.fn.system(cmd)
  if vim.v.shell_error == 0 and result ~= "" then
    local file, line = result:match("^(.+%.lua):(%d+):")
    if file then
      return { file = file, line = tonumber(line) }
    end
  end

  local base = desc:match("^(.-)%s*%d+$") or desc
  if base ~= desc then
    local base_escaped = vim.fn.escape(base, '"\\[]().+*?^$')
    cmd = string.format('grep -rn "%s" "%s" --include="*.lua" | head -1', base_escaped, config_dir)
    result = vim.fn.system(cmd)
    if vim.v.shell_error == 0 and result ~= "" then
      local file, line = result:match("^(.+%.lua):(%d+):")
      if file then
        return { file = file, line = tonumber(line) }
      end
    end
  end

  return nil
end

local source_cache = {}

local function get_source(mode, raw, desc)
  local key = mode .. "|" .. raw
  if source_cache[key] then
    return source_cache[key]
  end
  local src = find_source_via_maparg(mode, raw)
  if not src then
    src = find_source_via_grep(desc)
  end
  source_cache[key] = src or false
  return source_cache[key]
end

local function open_lua_preview(src, on_back)
  local ok_read, lines = pcall(vim.fn.readfile, src.file)
  if not ok_read or #lines == 0 then
    vim.notify("Could not read: " .. src.file, vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "lua"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " " .. vim.fn.fnamemodify(src.file, ":~:.") .. "  ·  Enter → open  ·  Esc/q → back ",
    title_pos = "center",
  })

  local line = math.min(src.line or 1, #lines)
  pcall(vim.api.nvim_win_set_cursor, win, { line, 0 })
  vim.cmd("normal! zz")

  local function open_file()
    vim.api.nvim_win_close(win, true)
    vim.cmd("edit " .. src.file)
    pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
    vim.cmd("normal! zz")
  end

  local function go_back()
    vim.api.nvim_win_close(win, true)
    if on_back then
      vim.schedule(on_back)
    end
  end

  vim.keymap.set("n", "<CR>", open_file, { buffer = buf })
  vim.keymap.set("n", "q", go_back, { buffer = buf })
  vim.keymap.set("n", "<Esc>", go_back, { buffer = buf })
end

function M.open()
  if not pcall(require, "telescope") then
    vim.notify("Telescope not available", vim.log.levels.WARN)
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local keymaps = require("config.map").get_keymaps()
  local seen = {}
  local deduped = {}
  for _, km in ipairs(keymaps) do
    local base = km.desc:match("^(.-)%s*%d+$")
    if base then
      local key = km.mode .. "|" .. base
      if not seen[key] then
        seen[key] = true
        local copy = vim.tbl_extend("force", {}, km)
        copy.display_desc = base .. " N"
        copy.display_lhs = km.lhs:gsub("%d+$", "N")
        table.insert(deduped, copy)
      end
    else
      local copy = vim.tbl_extend("force", {}, km)
      copy.display_desc = km.desc
      copy.display_lhs = km.lhs
      table.insert(deduped, copy)
    end
  end

  table.sort(deduped, function(a, b)
    if a.group == "General" and b.group ~= "General" then
      return true
    end
    if a.group ~= "General" and b.group == "General" then
      return false
    end
    if a.group ~= b.group then
      return a.group < b.group
    end
    return a.display_lhs < b.display_lhs
  end)

  local mode_label = { n = "N", v = "V", x = "V" }

  pickers
    .new({}, {
      prompt_title = "Keybindings  ·  Enter → preview source  ·  Ctrl-d → docs",
      previewer = false,
      finder = finders.new_table({
        results = deduped,
        entry_maker = function(entry)
          local m = mode_label[entry.mode] or entry.mode:upper()
          return {
            value = entry,
            display = string.format("▸ %-16s [%s] %-22s %s", entry.group, m, entry.display_lhs, entry.display_desc),
            ordinal = entry.group .. " " .. entry.display_lhs .. " " .. entry.display_desc,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          local sel = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if not sel then
            return
          end
          local e = sel.value
          local src = get_source(e.mode, e.raw, e.desc)
          if src and src.file then
            open_lua_preview(src, function()
              M.open()
            end)
          else
            vim.notify(string.format("Lua source not found for [%s] %s", e.mode, e.lhs), vim.log.levels.WARN)
          end
        end)

        local function open_docs(bufnr)
          local sel = action_state.get_selected_entry()
          actions.close(bufnr)
          if sel then
            vim.cmd("edit " .. docs_path(sel.value.file))
          end
        end

        map("i", "<C-d>", function()
          open_docs(prompt_bufnr)
        end)
        map("n", "<C-d>", function()
          open_docs(prompt_bufnr)
        end)
        return true
      end,
    })
    :find()
end

return M
