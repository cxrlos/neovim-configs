return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local shared = require("config.shared")
    local map = require("config.map")
    local d = { group = "Git", docs = "git-cheatsheet.md" }

    require("gitsigns").setup({
      signs = {
        add = { text = shared.icons.git.add },
        change = { text = shared.icons.git.change },
        delete = { text = shared.icons.git.delete },
        topdelete = { text = shared.icons.git.delete },
        changedelete = { text = shared.icons.git.change },
      },
      current_line_blame = false,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 0,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "  <author>, <author_time:%Y-%m-%d> · <summary>",
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local o = { buffer = bufnr }

        map("n", "]h", function()
          gs.nav_hunk("next")
        end, vim.tbl_extend("force", d, o, { desc = "Next hunk" }))
        map("n", "[h", function()
          gs.nav_hunk("prev")
        end, vim.tbl_extend("force", d, o, { desc = "Prev hunk" }))
        map("n", "<leader>gs", gs.stage_hunk, vim.tbl_extend("force", d, o, { desc = "Stage hunk" }))
        map("n", "<leader>gr", gs.reset_hunk, vim.tbl_extend("force", d, o, { desc = "Reset hunk" }))
        map("n", "<leader>gS", gs.stage_buffer, vim.tbl_extend("force", d, o, { desc = "Stage buffer" }))
        map("n", "<leader>gu", gs.undo_stage_hunk, vim.tbl_extend("force", d, o, { desc = "Undo stage hunk" }))
        map("n", "<leader>gp", gs.preview_hunk, vim.tbl_extend("force", d, o, { desc = "Preview hunk" }))
        map("n", "<leader>gd", gs.diffthis, vim.tbl_extend("force", d, o, { desc = "Diff this file" }))

        local blame_ns = vim.api.nvim_create_namespace("user_full_blame")
        local blame_active = false

        vim.api.nvim_set_hl(0, "BlameAge1", { fg = "#e0def4", italic = true })
        vim.api.nvim_set_hl(0, "BlameAge2", { fg = "#b4b0ca", italic = true })
        vim.api.nvim_set_hl(0, "BlameAge3", { fg = "#908caa", italic = true })
        vim.api.nvim_set_hl(0, "BlameAge4", { fg = "#6e6a86", italic = true })
        vim.api.nvim_set_hl(0, "BlameAge5", { fg = "#56526e", italic = true })

        map("n", "<leader>gb", function()
          blame_active = not blame_active
          vim.api.nvim_buf_clear_namespace(bufnr, blame_ns, 0, -1)
          if not blame_active then
            return
          end

          local file = vim.api.nvim_buf_get_name(bufnr)
          local dir = vim.fn.fnamemodify(file, ":h")
          local output = vim.fn.systemlist(
            "git -C " .. vim.fn.shellescape(dir) .. " blame --date=short " .. vim.fn.shellescape(file) .. " 2>/dev/null"
          )

          local dates = {}
          local entries = {}

          for i, line in ipairs(output) do
            local hash, author, date = line:match("^%^?(%x+)%s+%((.-)%s+(%d%d%d%d%-%d%d%-%d%d)")
            if hash and author and date then
              local y, m, dd = date:match("(%d+)-(%d+)-(%d+)")
              local ts = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(dd) })
              table.insert(dates, ts)
              table.insert(entries, { line_idx = i - 1, author = author, date = date, ts = ts })
            end
          end

          if #dates == 0 then
            return
          end

          local sorted_ts = vim.deepcopy(dates)
          table.sort(sorted_ts)
          local buckets = { sorted_ts[1] }
          for i = 2, 4 do
            local idx = math.floor((i - 1) / 4 * #sorted_ts) + 1
            idx = math.min(idx, #sorted_ts)
            table.insert(buckets, sorted_ts[idx])
          end

          local function get_bucket(ts)
            for i = #buckets, 1, -1 do
              if ts >= buckets[i] then
                return i
              end
            end
            return 1
          end

          for _, e in ipairs(entries) do
            local bucket = get_bucket(e.ts)
            local text = "  " .. e.author .. ", " .. e.date
            vim.api.nvim_buf_set_extmark(bufnr, blame_ns, e.line_idx, 0, {
              virt_text = { { text, "BlameAge" .. (6 - bucket) } },
              virt_text_pos = "eol",
            })
          end
        end, vim.tbl_extend("force", d, o, { desc = "Toggle blame all lines" }))
        map("n", "<leader>gi", function()
          local file = vim.api.nvim_buf_get_name(bufnr)
          local dir = vim.fn.fnamemodify(file, ":h")
          local lnum = vim.api.nvim_win_get_cursor(0)[1]

          local hash = vim.fn
            .system(
              "git -C "
                .. vim.fn.shellescape(dir)
                .. " blame -L"
                .. lnum
                .. ","
                .. lnum
                .. " --porcelain "
                .. vim.fn.shellescape(file)
                .. " 2>/dev/null | head -1 | cut -d' ' -f1"
            )
            :gsub("\n", "")
            :gsub("^%^", "")
          if hash == "" or hash:match("^0+$") then
            vim.notify("No commit info for this line", vim.log.levels.INFO)
            return
          end

          local info = vim.fn.systemlist(
            "git -C "
              .. vim.fn.shellescape(dir)
              .. " log -1 --format='%H%n%an%n%ae%n%ad%n%s%n%b' "
              .. hash
              .. " 2>/dev/null"
          )
          local commit = info[1] or ""
          local author = info[2] or ""
          local email = info[3] or ""
          local date = info[4] or ""
          local subject = info[5] or ""
          local body = {}
          for i = 6, #info do
            table.insert(body, info[i])
          end

          local remote =
            vim.fn.system("git -C " .. vim.fn.shellescape(dir) .. " remote get-url origin 2>/dev/null"):gsub("\n", "")
          local gh_url = ""
          if remote ~= "" then
            gh_url = remote:gsub("git@github.com:", "https://github.com/"):gsub("%.git$", "") .. "/commit/" .. commit
          end

          local popup_width = math.min(90, vim.o.columns - 10)

          local function centered_header(label)
            local pad_total = popup_width - 2 - #label - 2
            local left = math.floor(pad_total / 2)
            local right = pad_total - left
            return string.rep("═", left) .. " " .. label .. " " .. string.rep("═", right)
          end

          local lines = {
            centered_header("Commit"),
            commit,
            "",
            centered_header("Author"),
            author .. " <" .. email .. ">",
            "",
            centered_header("Date"),
            date,
            "",
            centered_header("Message"),
            subject,
          }
          for _, l in ipairs(body) do
            if l ~= "" then
              table.insert(lines, l)
            end
          end
          if gh_url ~= "" then
            table.insert(lines, "")
            table.insert(lines, centered_header("GitHub"))
            table.insert(lines, gh_url)
          end

          local buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          vim.bo[buf].bufhidden = "wipe"
          local width = popup_width
          local height = math.min(#lines + 2, vim.o.lines - 10)
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = width,
            height = height,
            row = math.floor((vim.o.lines - height) / 2),
            col = math.floor((vim.o.columns - width) / 2),
            border = "rounded",
            title = " Commit Info  ·  yy to copy value ",
            title_pos = "center",
          })
          vim.keymap.set("n", "q", function()
            vim.api.nvim_win_close(win, true)
          end, { buffer = buf })
          vim.keymap.set("n", "<Esc>", function()
            vim.api.nvim_win_close(win, true)
          end, { buffer = buf })
        end, vim.tbl_extend("force", d, o, { desc = "Full commit info" }))
      end,
    })

    local function set_blame_colors()
      vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#6e6a86", italic = true })
    end
    set_blame_colors()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("user_blame_hl", { clear = true }),
      callback = set_blame_colors,
    })
  end,
}
