-- Habit trainers (temporary)

-- Habit trainer (temporary, 2-4 weeks): hints a better motion, never blocks. :Hardtime report
-- Set up after the keymaps: it wraps whatever j/k/... maps exist when it starts.
require("hardtime").setup({ restriction_mode = "hint", disable_mouse = false })

-- Motion hints, hidden until asked for (trial: keep or drop)
require("precognition").setup({ startVisible = false })
vim.keymap.set("n", "<leader>tp", function()
  require("precognition").toggle()
end, { desc = "Toggle motion hints (precognition)" })
