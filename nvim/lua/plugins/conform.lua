return {
  "stevearc/conform.nvim",
  event = "BufWritePre",
  cmd = { "ConformInfo" },
  config = function()
    local conform = require("conform")
    local map = require("config.map")

    conform.setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "black", stop_after_first = true },
        rust = { "rustfmt" },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        terraform = { "terraform_fmt" },
        hcl = { "terraform_fmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        toml = { "taplo" },
        dockerfile = { "hadolint" },
      },
      format_on_save = {
        timeout_ms = 3000,
        lsp_format = "fallback",
      },
    })

    map("n", "<leader>F", function()
      local cwd = vim.fn.getcwd()
      vim.ui.select(
        { "Yes — format all", "No — cancel" },
        { prompt = "Format entire project at " .. cwd .. "?" },
        function(choice)
          if not choice or choice:match("^No") then
            return
          end

          local files = vim.fn.systemlist(
            "find "
              .. vim.fn.shellescape(cwd)
              .. " -type f \\( -name '*.lua' -o -name '*.py' -o -name '*.rs' -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.json' -o -name '*.yaml' -o -name '*.yml' -o -name '*.md' -o -name '*.sh' -o -name '*.toml' -o -name '*.tf' -o -name '*.css' -o -name '*.html' \\)"
              .. " -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/target/*' -not -path '*/__pycache__/*' -not -path '*/lazy/*'"
          )

          local formatted = {}
          local failed = {}

          for _, file in ipairs(files) do
            local buf = vim.fn.bufadd(file)
            vim.fn.bufload(buf)
            local formatters = conform.list_formatters_for_buffer(buf)

            if #formatters > 0 then
              local ok, err = pcall(conform.format, { bufnr = buf, async = false, quiet = true })
              if ok then
                if vim.bo[buf].modified then
                  vim.api.nvim_buf_call(buf, function()
                    vim.cmd("silent write")
                  end)
                  table.insert(formatted, vim.fn.fnamemodify(file, ":~:."))
                end
              else
                table.insert(failed, vim.fn.fnamemodify(file, ":~:.") .. ": " .. tostring(err))
              end
            end

            if not vim.api.nvim_buf_is_loaded(buf) or vim.fn.bufwinid(buf) == -1 then
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end

          local lines = {}
          if #formatted > 0 then
            table.insert(lines, "Formatted " .. #formatted .. " files:")
            for _, f in ipairs(formatted) do
              table.insert(lines, "  ✓ " .. f)
            end
          else
            table.insert(lines, "No files needed formatting.")
          end
          if #failed > 0 then
            table.insert(lines, "")
            table.insert(lines, "Failed:")
            for _, f in ipairs(failed) do
              table.insert(lines, "  ✘ " .. f)
            end
          end

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          vim.bo[buf].bufhidden = "wipe"
          local width = math.min(80, vim.o.columns - 10)
          local height = math.min(#lines + 2, vim.o.lines - 10)
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            border = "rounded",
            title = " Project Format Results ",
            title_pos = "center",
          })
          vim.keymap.set("n", "q", function()
            vim.api.nvim_win_close(win, true)
          end, { buffer = buf })
          vim.keymap.set("n", "<Esc>", function()
            vim.api.nvim_win_close(win, true)
          end, { buffer = buf })
        end
      )
    end, { desc = "Format entire project", group = "General", docs = "core-cheatsheet.md" })
  end,
}
