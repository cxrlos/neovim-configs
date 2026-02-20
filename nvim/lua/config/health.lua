local M = {}

local expected_plugins = {
  "lazy.nvim",
  "rose-pine",
  "noice.nvim",
  "nui.nvim",
  "lualine.nvim",
  "bufferline.nvim",
  "dashboard-nvim",
  "dressing.nvim",
  "nvim-web-devicons",
  "telescope.nvim",
  "telescope-fzf-native.nvim",
  "plenary.nvim",
  "neo-tree.nvim",
  "oil.nvim",
  "harpoon",
  "mason.nvim",
  "mason-lspconfig.nvim",
  "nvim-lspconfig",
  "blink.cmp",
  "friendly-snippets",
  "fidget.nvim",
  "lazydev.nvim",
  "render-markdown.nvim",
  "markdown-preview.nvim",
}

local expected_servers = {
  "lua_ls",
  "pyright",
  "ts_ls",
  "terraformls",
  "dockerls",
  "yamlls",
  "marksman",
}

local expected_keymaps = {
  { mode = "n", lhs = "gd" },
  { mode = "n", lhs = "gD" },
  { mode = "n", lhs = "K" },
  { mode = "n", lhs = " ff" },
  { mode = "n", lhs = " fg" },
  { mode = "n", lhs = " e" },
  { mode = "n", lhs = " bd" },
  { mode = "n", lhs = "?" },
}

function M.check()
  vim.health.start("User Config")

  vim.health.start("Plugins")
  local lazy_ok, lazy = pcall(require, "lazy")
  if not lazy_ok then
    vim.health.error("lazy.nvim not available")
    return
  end
  local installed = {}
  for _, plugin in ipairs(lazy.plugins()) do
    installed[plugin.name] = true
  end
  for _, name in ipairs(expected_plugins) do
    if installed[name] then
      vim.health.ok(name)
    else
      vim.health.error(name .. " not installed")
    end
  end

  vim.health.start("LSP Servers (Mason)")
  local mason_ok, registry = pcall(require, "mason-registry")
  if not mason_ok then
    vim.health.error("mason-registry not available")
  else
    for _, server in ipairs(expected_servers) do
      local mappings = require("mason-lspconfig.mappings")
      local all = mappings.get_all()
      local pkg_name = all.lspconfig_to_package[server]
      if pkg_name and registry.is_installed(pkg_name) then
        vim.health.ok(server .. " (" .. pkg_name .. ")")
      else
        vim.health.warn(server .. " not installed via Mason. Run :Mason to install.")
      end
    end
  end

  vim.health.start("Keymaps")
  for _, km in ipairs(expected_keymaps) do
    local maps = vim.api.nvim_get_keymap(km.mode)
    local found = false
    for _, m in ipairs(maps) do
      if m.lhs == km.lhs then
        found = true
        break
      end
    end
    if not found then
      local buf_maps = vim.api.nvim_buf_get_keymap(0, km.mode)
      for _, m in ipairs(buf_maps) do
        if m.lhs == km.lhs then
          found = true
          break
        end
      end
    end
    if found then
      vim.health.ok("[" .. km.mode .. "] " .. km.lhs)
    else
      vim.health.warn("[" .. km.mode .. "] " .. km.lhs .. " not registered (LSP may not be attached yet)")
    end
  end

  vim.health.start("LspAttach")
  local groups = vim.api.nvim_get_autocmds({ group = "user_lsp_keymaps" })
  if #groups > 0 then
    vim.health.ok("LspAttach autocmd registered")
  else
    vim.health.error("LspAttach autocmd NOT registered — on_attach will never fire")
  end
end

return M
