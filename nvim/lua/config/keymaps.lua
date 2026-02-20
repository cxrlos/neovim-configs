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

map(
  { "n", "v" },
  "<leader>y",
  [["+y]],
  { desc = "Yank to system clipboard", group = "Clipboard", docs = "core-cheatsheet.md" }
)
map(
  "n",
  "<leader>Y",
  [["+Y]],
  { desc = "Yank line to system clipboard", group = "Clipboard", docs = "core-cheatsheet.md" }
)

map("n", "Q", "<nop>")
map("n", "?", function()
  require("config.cheatsheet").open()
end, { desc = "Keybinding cheatsheet", group = "General", docs = "core-cheatsheet.md" })

map("n", "<leader>h", "<C-w><C-h>", { desc = "Focus left window", group = "Windows", docs = "core-cheatsheet.md" })
map("n", "<leader>l", "<C-w><C-l>", { desc = "Focus right window", group = "Windows", docs = "core-cheatsheet.md" })
map("n", "<leader>j", "<C-w><C-j>", { desc = "Focus lower window", group = "Windows", docs = "core-cheatsheet.md" })
map("n", "<leader>k", "<C-w><C-k>", { desc = "Focus upper window", group = "Windows", docs = "core-cheatsheet.md" })

map(
  "n",
  "<C-Up>",
  "<cmd>resize +2<CR>",
  { desc = "Increase window height", group = "Windows", docs = "core-cheatsheet.md" }
)
map(
  "n",
  "<C-Down>",
  "<cmd>resize -2<CR>",
  { desc = "Decrease window height", group = "Windows", docs = "core-cheatsheet.md" }
)
map(
  "n",
  "<C-Left>",
  "<cmd>vertical resize -2<CR>",
  { desc = "Decrease window width", group = "Windows", docs = "core-cheatsheet.md" }
)
map(
  "n",
  "<C-Right>",
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
