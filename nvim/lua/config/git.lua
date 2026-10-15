-- Git review and review notes for the agent

-- Git review. The index means "reviewed": stage what you approve; what's unstaged is still to
-- review, and reset_hunk drops only the agent's newest edit. gitsigns: hunks in the buffer;
-- Neogit: status, commit (signed), fixup, absorb, rebase; diffview: multi-file and branch diffs,
-- merge conflicts (]x [x, <leader>co/ct/cb/ca; <leader>c* is reserved for it).
require("gitsigns").setup({
  attach_to_untracked = true, -- new files the agent created count as hunks too
  on_attach = function(buf)
    local gs = require("gitsigns")
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
    end
    map("n", "]c", function()
      if vim.wo.diff then return vim.cmd.normal({ "]c", bang = true }) end
      gs.nav_hunk("next")
    end, "Next git hunk")
    map("n", "[c", function()
      if vim.wo.diff then return vim.cmd.normal({ "[c", bang = true }) end
      gs.nav_hunk("prev")
    end, "Previous git hunk")
    map({ "o", "x" }, "ih", gs.select_hunk, "Inside git hunk")
    map("n", "<leader>hs", gs.stage_hunk, "Hunk: stage (approve) / unstage")
    map("x", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Hunk: stage selection")
    map("n", "<leader>hr", gs.reset_hunk, "Hunk: reset to the index (drop the agent's change)")
    map("x", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "Hunk: reset selection")
    map("n", "<leader>hp", gs.preview_hunk_inline, "Hunk: preview inline")
    map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Hunk: blame this line")
    map("n", "<leader>hq", function() gs.setqflist("all") end, "Hunk: every unreviewed hunk to quickfix")
    MiniClue.ensure_buf_triggers(buf) -- keep the key-hint triggers ahead of these buffer maps
  end,
})
require("diffview").setup({})
require("neogit").setup({ integrations = { diffview = true, fzf_lua = true } })
vim.keymap.set("n", "<leader>gg", "<Cmd>Neogit<CR>", { desc = "Git: status (Neogit)" })
vim.keymap.set("n", "<leader>gd", "<Cmd>DiffviewOpen<CR>", { desc = "Git: diff of unstaged changes" })
vim.keymap.set("n", "<leader>gD", "<Cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<CR>",
  { desc = "Git: this branch vs the default branch" })
vim.keymap.set("n", "<leader>gl", "<Cmd>DiffviewFileHistory --range=origin/HEAD..HEAD<CR>",
  { desc = "Git: this branch's commits" })
vim.keymap.set("n", "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>", { desc = "Git: this file's history" })
vim.keymap.set("n", "<leader>gq", "<Cmd>DiffviewClose<CR>", { desc = "Git: close the diff view" })

-- <leader>gy: GitHub permalink to this line or the selected lines (at HEAD; push first), for PR
-- comments or pointing an agent at code.
vim.keymap.set({ "n", "x" }, "<leader>gy", function()
  local root = vim.fs.root(0, ".git")
  local file = root and vim.fs.relpath(root, vim.api.nvim_buf_get_name(0))
  if not file then return vim.notify("not a file in a git repo", vim.log.levels.WARN) end
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  local lines = a == b and tostring(a) or (math.min(a, b) .. "-" .. math.max(a, b))
  local sha = vim.trim(vim.system({ "git", "rev-parse", "HEAD" }, { cwd = root }):wait().stdout)
  local res = vim.system({ "gh", "browse", "--no-browser", "--commit=" .. sha, file .. ":" .. lines }, { cwd = root }):wait()
  if res.code ~= 0 then return vim.notify(vim.trim(res.stderr), vim.log.levels.ERROR) end
  vim.fn.setreg("+", vim.trim(res.stdout))
  vim.notify("copied " .. vim.trim(res.stdout))
end, { desc = "Git: copy the GitHub link to this line / selection" })

-- Review notes for the agent (one way: nvim -> agent). Notes go into a quickfix list named
-- "agent-review" (so ]q walks them); <leader>as writes them to .review.md in the repo (globally
-- git-ignored) and types a short prompt into this session's `agent` window without pressing
-- Enter. Stage what you approve before sending: the prompt says staged work is approved.
local REVIEW = "agent-review"
local review_list = function()
  for nr = 1, vim.fn.getqflist({ nr = "$" }).nr do
    local l = vim.fn.getqflist({ nr = nr, id = 0, title = 0 })
    if l.title == REVIEW then return l.id end
  end
  vim.fn.setqflist({}, " ", { title = REVIEW })
  return vim.fn.getqflist({ id = 0 }).id
end
local add_note = function(l1, l2)
  vim.ui.input({ prompt = "Note for the agent: " }, function(text)
    if not text or text == "" then return end
    vim.fn.setqflist({}, "a", {
      id = review_list(),
      items = { { bufnr = vim.api.nvim_get_current_buf(), lnum = l1, end_lnum = l2, text = text } },
    })
  end)
end
vim.keymap.set("n", "<leader>an", function()
  add_note(vim.fn.line("."), vim.fn.line("."))
end, { desc = "Agent: add a review note on this line" })
vim.keymap.set("x", "<leader>an", function()
  local a, b = vim.fn.line("v"), vim.fn.line(".")
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
  add_note(math.min(a, b), math.max(a, b))
end, { desc = "Agent: add a review note on the selection" })
vim.keymap.set("n", "<leader>al", function()
  vim.cmd(vim.fn.getqflist({ id = review_list(), nr = 0 }).nr .. "chistory | copen")
end, { desc = "Agent: list review notes" })
vim.keymap.set("n", "<leader>ax", function()
  vim.fn.setqflist({}, "r", { id = review_list(), items = {} })
end, { desc = "Agent: clear review notes" })
vim.keymap.set("n", "<leader>as", function()
  local root = vim.fs.root(0, ".git")
  if not (root and vim.env.TMUX) then
    return vim.notify("not in a git repo inside tmux", vim.log.levels.WARN)
  end
  local items = vim.fn.getqflist({ id = review_list(), items = 0 }).items
  if #items == 0 then return vim.notify("no review notes") end
  local out = { "# Review notes (line numbers are from when each note was taken)", "" }
  for _, it in ipairs(items) do
    local file = vim.api.nvim_buf_get_name(it.bufnr)
    local lines = it.end_lnum > it.lnum and (it.lnum .. "-" .. it.end_lnum) or tostring(it.lnum)
    out[#out + 1] = ("- %s:%s %s"):format(vim.fs.relpath(root, file) or file, lines, it.text)
  end
  vim.fn.writefile(out, root .. "/.review.md")
  local session = vim.trim(vim.system({ "tmux", "display-message", "-p", "-t", vim.env.TMUX_PANE, "#S" }):wait().stdout)
  local sent = vim.system({ "tmux", "send-keys", "-t", "=" .. session .. ":agent", "-l",
    "Address every note in .review.md, then stop. Staged changes are approved; don't touch them." }):wait()
  if sent.code ~= 0 then
    return vim.notify("wrote .review.md, but no agent window in " .. session, vim.log.levels.WARN)
  end
  vim.notify("notes sent to " .. session .. ":agent (press Enter there)")
end, { desc = "Agent: write .review.md and type the prompt in the agent window" })
