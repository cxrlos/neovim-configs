return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  event = "BufReadPre",
  opts = {
    indent = { char = "│" },
    scope = { enabled = true, show_start = false, show_end = false },
    exclude = { filetypes = { "dashboard", "neo-tree", "help", "lazy" } },
  },
}
