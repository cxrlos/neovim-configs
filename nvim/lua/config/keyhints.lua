-- Key hints (mini.clue): loaded last, after every mapping

-- Key hints (mini.clue): pause after a prefix and a window lists what can follow, with each map's
-- desc. Last in the file, so its triggers come after every mapping above.
local clue = require("mini.clue")
clue.setup({
  triggers = {
    { mode = { "n", "x" }, keys = "<Leader>" },
    { mode = { "n", "x" }, keys = "g" },
    { mode = "n", keys = "[" },
    { mode = "n", keys = "]" },
    { mode = "n", keys = "<C-w>" },
    { mode = { "n", "x" }, keys = "z" },
    { mode = { "n", "x" }, keys = "'" },
    { mode = { "n", "x" }, keys = "`" },
    { mode = { "n", "x" }, keys = '"' },
    { mode = { "i", "c" }, keys = "<C-r>" },
    { mode = "i", keys = "<C-x>" },
  },
  clues = {
    { mode = "n", keys = "<Leader>a", desc = "+agent review notes" },
    { mode = "n", keys = "<Leader>b", desc = "+buffer" },
    { mode = "n", keys = "<Leader>g", desc = "+git" },
    { mode = "n", keys = "<Leader>h", desc = "+hunk" },
    { mode = "n", keys = "<Leader>s", desc = "+search" },
    { mode = "n", keys = "<Leader>t", desc = "+toggle" },
    clue.gen_clues.square_brackets(),
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),
  },
  window = { delay = 500 },
})
