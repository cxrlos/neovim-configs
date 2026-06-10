local M = { _jump_on_send = false }

local function tmux_select_claude()
  if not vim.env.TMUX then
    vim.notify("Not inside tmux — no claude window to jump to", vim.log.levels.WARN)
    return
  end
  vim.fn.system({ "tmux", "select-window", "-t", "claude" })
end

return {
  "coder/claudecode.nvim",
  lazy = false,
  opts = {
    terminal = {
      provider = "none",
    },
  },
  config = function(_, opts)
    require("claudecode").setup(opts)

    local map = require("config.map")
    local d = { group = "Agent", docs = "ai-cheatsheet.md" }

    map("x", "<leader>as", function()
      M._jump_on_send = false
      vim.cmd("ClaudeCodeSend")
    end, vim.tbl_extend("force", d, { desc = "Send selection (stay)" }))

    map("x", "<leader>aS", function()
      M._jump_on_send = true
      vim.cmd("ClaudeCodeSend")
    end, vim.tbl_extend("force", d, { desc = "Send selection + jump to tmux" }))

    map("n", "<leader>aa", "<cmd>ClaudeCodeAdd %<CR>", vim.tbl_extend("force", d, { desc = "Add current file to context" }))
    map("n", "<leader>ad", "<cmd>ClaudeCodeCloseAllDiffs<CR>", vim.tbl_extend("force", d, { desc = "Close pending diffs" }))
    map("n", "<leader>at", "<cmd>ClaudeCodeStatus<CR>", vim.tbl_extend("force", d, { desc = "Connection status" }))

    map("n", "<leader>ac", function()
      if not vim.env.TMUX then
        vim.notify("Not inside tmux — <leader>ac drives the tmux claude window", vim.log.levels.WARN)
        return
      end
      vim.fn.system({ "tmux", "send-keys", "-t", "claude", "claude --continue", "Enter" })
      tmux_select_claude()
    end, vim.tbl_extend("force", d, { desc = "Continue last session in tmux" }))

    vim.api.nvim_create_autocmd("User", {
      pattern = "ClaudeCodeSendComplete",
      group = vim.api.nvim_create_augroup("user_agent_send", { clear = true }),
      callback = function()
        if M._jump_on_send then
          tmux_select_claude()
        end
        M._jump_on_send = false
      end,
    })
  end,
}
