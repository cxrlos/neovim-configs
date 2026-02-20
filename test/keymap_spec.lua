vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      local always = {
        { mode = "n", raw = "<leader>ff", desc = "Find files" },
        { mode = "n", raw = "<leader>fg", desc = "Live grep" },
        { mode = "n", raw = "<leader>fr", desc = "Recent files" },
        { mode = "n", raw = "<leader>fb", desc = "Buffers" },
        { mode = "n", raw = "<leader>pa", desc = "Harpoon add file" },
        { mode = "n", raw = "<leader>pp", desc = "Harpoon menu" },
        { mode = "n", raw = "<leader>1", desc = "Harpoon file 1" },
        { mode = "n", raw = "<leader>h", desc = "Focus left window" },
        { mode = "n", raw = "<leader>l", desc = "Focus right window" },
        { mode = "n", raw = "<leader>j", desc = "Focus lower window" },
        { mode = "n", raw = "<leader>k", desc = "Focus upper window" },
        { mode = "n", raw = "<leader>qn", desc = "Quickfix next" },
        { mode = "n", raw = "<leader>y", desc = "Yank to system clipboard" },
        { mode = "n", raw = "<leader>Y", desc = "Yank line to system clipboard" },
        { mode = "n", raw = "<leader>u", desc = "Undo history" },
        { mode = "n", raw = "<leader>gt", desc = "Floating terminal" },
        { mode = "n", raw = "?", desc = "Keybinding cheatsheet" },
      }

      local lazy_loaded = {
        { mode = "n", raw = "<leader>e", desc = "Toggle file tree", plugin = "neo-tree" },
        { mode = "n", raw = "<leader>E", desc = "Reveal file in tree", plugin = "neo-tree" },
        { mode = "n", raw = "<leader>bd", desc = "Close buffer", plugin = "bufferline" },
        { mode = "n", raw = "<leader>bo", desc = "Close other buffers", plugin = "bufferline" },
        { mode = "n", raw = "<leader>bp", desc = "Pick buffer", plugin = "bufferline" },
        { mode = "n", raw = "<leader>sn", desc = "Notification history", plugin = "noice" },
      }

      local registry = require("config.map").get_keymaps()
      local lookup = {}
      for _, km in ipairs(registry) do
        lookup[km.mode .. "|" .. km.raw] = km.desc
      end

      local pass = 0
      local fail = 0
      local skip = 0
      local errors = {}

      for _, exp in ipairs(always) do
        local key = exp.mode .. "|" .. exp.raw
        if lookup[key] then
          pass = pass + 1
        else
          fail = fail + 1
          table.insert(errors, string.format("  FAIL: [%s] %s (%s)", exp.mode, exp.raw, exp.desc))
        end
      end

      for _, exp in ipairs(lazy_loaded) do
        local key = exp.mode .. "|" .. exp.raw
        if lookup[key] then
          pass = pass + 1
        else
          skip = skip + 1
        end
      end

      print(string.format("Keymap spec: %d passed, %d failed, %d skipped (lazy-loaded)", pass, fail, skip))
      for _, e in ipairs(errors) do
        print(e)
      end

      if fail > 0 then
        vim.cmd("cquit 1")
      else
        vim.cmd("qall!")
      end
    end, 2000)
  end,
})
