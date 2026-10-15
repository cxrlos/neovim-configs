-- Editing: code text objects, surround, indent blocks

-- Code text objects: af/if function, ac/ic class, au/iu call (mini.ai's default f, renamed).
-- Next/last move to aN/iN/aL/iL so nvim's built-in an/in (grow/shrink selection) keep working.
local ai = require("mini.ai")
ai.setup({
  n_lines = 500, -- search far enough to find the edges of a long function
  custom_textobjects = {
    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    u = ai.gen_spec.function_call(),
  },
  mappings = { around_next = "aN", inside_next = "iN", around_last = "aL", inside_last = "iL" },
})

-- Surround: sa add (saiw" quotes a word), sd delete (sd"), sr replace (sr"'), sf/sh find/highlight.
-- Plain s waits a moment for these; use cl for the built-in s.
require("mini.surround").setup()

-- Indent text objects: ii / ai = this indentation block (Python, YAML), [i ]i its edges.
-- Never drawn: only the text objects and motions are wanted.
require("mini.indentscope").setup({ draw = { predicate = function() return false end } })
