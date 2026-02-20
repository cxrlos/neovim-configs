return {
  "RRethy/vim-illuminate",
  event = "BufReadPre",
  config = function()
    require("illuminate").configure({
      delay = 200,
      filetypes_denylist = { "dashboard", "neo-tree", "help", "lazy" },
    })
  end,
}
