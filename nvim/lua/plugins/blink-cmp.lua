return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  version = "*",
  dependencies = { "rafamadriz/friendly-snippets" },
  opts = {
    keymap = {
      preset = "default",
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide" },
      ["<CR>"] = { "accept", "fallback" },
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-d>"] = { "scroll_documentation_down" },
      ["<C-u>"] = { "scroll_documentation_up" },
    },
    appearance = { nerd_font_variant = "mono" },
    completion = {
      menu = { border = require("config.shared").border },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = { border = require("config.shared").border },
      },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
  opts_extend = { "sources.default" },
}
