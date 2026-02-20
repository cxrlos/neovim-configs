return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = { ui = { border = require("config.shared").border } },
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      local handlers = require("lsp.handlers")
      handlers.setup()

      vim.lsp.config("*", {
        root_markers = { ".git" },
      })

      local servers = {
        "lua_ls",
        "pyright",
        "terraformls",
        "dockerls",
        "yamlls",
        "marksman",
      }

      for _, name in ipairs(servers) do
        local ok, server_opts = pcall(require, "lsp.servers." .. name)
        if ok and type(server_opts) == "table" then
          vim.lsp.config(name, server_opts)
        end
      end

      require("mason-lspconfig").setup({
        ensure_installed = vim.list_extend(vim.deepcopy(servers), { "ts_ls", "rust_analyzer" }),
        automatic_enable = {
          exclude = { "ts_ls", "rust_analyzer" },
        },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_keymaps", { clear = true }),
        callback = function(event)
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          local name = client and client.name or "unknown"
          local shared = require("config.shared")
          shared.log("LspAttach: " .. name .. " → buf " .. event.buf)

          require("lsp").on_attach(client, event.buf)

          local test_map = vim.fn.maparg("gd", "n", false, true)
          if not test_map or not test_map.lhs then
            vim.notify(
              "LSP keymaps failed to register for " .. name .. ". Check :checkhealth user",
              vim.log.levels.ERROR
            )
          end
        end,
      })
    end,
  },
}
