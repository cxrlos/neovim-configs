local map = require("config.map")

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down half page", group = "Navigation", docs = "core-cheatsheet.md" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up half page", group = "Navigation", docs = "core-cheatsheet.md" })

map("n", "n", "nzzzv", { desc = "Next search match", group = "Navigation", docs = "core-cheatsheet.md" })
map("n", "N", "Nzzzv", { desc = "Prev search match", group = "Navigation", docs = "core-cheatsheet.md" })

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down", group = "Editing", docs = "core-cheatsheet.md" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up", group = "Editing", docs = "core-cheatsheet.md" })

map("n", "J", "mzJ`z", { desc = "Join line", group = "Editing", docs = "core-cheatsheet.md" })

map(
  "x",
  "<leader>p",
  [["_dP]],
  { desc = "Paste without overwriting", group = "Clipboard", docs = "core-cheatsheet.md" }
)


map("n", "Q", "<nop>")
map("n", "?", function()
  require("config.cheatsheet").open()
end, { desc = "Keybinding cheatsheet", group = "General", docs = "core-cheatsheet.md" })

map(
  "n",
  "<M-k>",
  "<cmd>resize +2<CR>",
  { desc = "Increase window height", group = "Windows", docs = "core-cheatsheet.md" }
)
map(
  "n",
  "<M-j>",
  "<cmd>resize -2<CR>",
  { desc = "Decrease window height", group = "Windows", docs = "core-cheatsheet.md" }
)
map(
  "n",
  "<M-h>",
  "<cmd>vertical resize -2<CR>",
  { desc = "Decrease window width", group = "Windows", docs = "core-cheatsheet.md" }
)
map(
  "n",
  "<M-l>",
  "<cmd>vertical resize +2<CR>",
  { desc = "Increase window width", group = "Windows", docs = "core-cheatsheet.md" }
)

map("n", "<leader>qn", "<cmd>cnext<CR>zz", { desc = "Quickfix next", group = "Quickfix", docs = "core-cheatsheet.md" })
map("n", "<leader>qp", "<cmd>cprev<CR>zz", { desc = "Quickfix prev", group = "Quickfix", docs = "core-cheatsheet.md" })
map("n", "<leader>qo", "<cmd>copen<CR>", { desc = "Quickfix open", group = "Quickfix", docs = "core-cheatsheet.md" })
map("n", "<leader>qc", "<cmd>cclose<CR>", { desc = "Quickfix close", group = "Quickfix", docs = "core-cheatsheet.md" })

map(
  "n",
  "<leader>ln",
  "<cmd>lnext<CR>zz",
  { desc = "Location list next", group = "Location List", docs = "core-cheatsheet.md" }
)
map(
  "n",
  "<leader>lp",
  "<cmd>lprev<CR>zz",
  { desc = "Location list prev", group = "Location List", docs = "core-cheatsheet.md" }
)

map("n", "<leader>t", function()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.85)
  local height = math.floor(vim.o.lines * 0.8)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " terminal ",
    title_pos = "center",
  })
  vim.fn.termopen(vim.o.shell, {
    on_exit = function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Floating terminal", group = "General", docs = "core-cheatsheet.md" })
