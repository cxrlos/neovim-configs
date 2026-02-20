return {
  "iamcco/markdown-preview.nvim",
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  ft = { "markdown" },
  build = "cd app && npm install",
  config = function()
    vim.g.mkdp_theme = "dark"
    vim.g.mkdp_auto_close = 0
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g._mkdp_running = false
    vim.g._mkdp_blink_phase = false

    local timer = nil

    local function start_blink()
      vim.g._mkdp_running = true
      vim.g._mkdp_blink_phase = false
      vim.notify("Markdown preview started — <leader>mp to stop", vim.log.levels.INFO)
      if timer then
        return
      end
      timer = vim.uv.new_timer()
      timer:start(
        0,
        1000,
        vim.schedule_wrap(function()
          vim.g._mkdp_blink_phase = not vim.g._mkdp_blink_phase
          vim.cmd("redrawstatus")
        end)
      )
    end

    local function stop_blink()
      vim.g._mkdp_running = false
      vim.g._mkdp_blink_phase = false
      if timer then
        timer:stop()
        timer:close()
        timer = nil
      end
      vim.cmd("redrawstatus")
      vim.notify("Markdown preview stopped", vim.log.levels.INFO)
    end

    local map = require("config.map")
    map("n", "<leader>mp", function()
      if vim.g._mkdp_running then
        vim.cmd("MarkdownPreviewStop")
        stop_blink()
      else
        vim.cmd("MarkdownPreview")
        start_blink()
      end
    end, { desc = "Toggle browser preview", group = "Markdown", docs = "markdown-cheatsheet.md" })
  end,
}
