local M = {}

local challenges = require("config.tutorial.challenges")

local state = {
  current = 1,
  completed = {},
  guide_buf = nil,
  guide_win = nil,
  editor_win = nil,
  sandbox_dir = nil,
}

local function create_sandbox_files()
  local dir = vim.fn.tempname() .. "_tutorial"
  vim.fn.mkdir(dir, "p")
  vim.fn.mkdir(dir .. "/src", "p")

  vim.fn.writefile({
    "class Calculator:",
    "    def __init__(self):",
    "        self.history = []",
    "",
    "    def add(self, a: int, b: int) -> int:",
    '        """Add two numbers and store in history."""',
    "        result = a + b",
    "        self.history.append(result)",
    "        return result",
    "",
    "    def subtract(self, a: int, b: int) -> int:",
    "        result = a - b",
    "        self.history.append(result)",
    "        return result",
    "",
    "    def multiply(self, a: int, b: int) -> int:",
    "        result = a * b",
    "        self.history.append(result)",
    "        return result",
    "",
    "    # TODO: implement division with zero check",
    "    # FIXME: history should store the operation too",
    "",
    "    def get_history(self) -> list:",
    "        return self.history",
    "",
    "",
    "def make_calculator() -> Calculator:",
    "    return Calculator()",
    "",
    "",
    "def main():",
    "    calc = make_calculator()",
    "    print(calc.add(2, 3))",
    "    print(calc.subtract(10, 4))",
    "    print(calc.multiply(3, 7))",
    "    print(calc.get_history())",
    "",
    "",
    'if __name__ == "__main__":',
    "    main()",
  }, dir .. "/src/calculator.py")

  vim.fn.writefile({
    "from calculator import Calculator, make_calculator",
    "",
    "",
    "class AdvancedCalc(Calculator):",
    "    def power(self, base: int, exp: int) -> int:",
    "        result = base ** exp",
    "        self.history.append(result)",
    "        return result",
    "",
    "",
    "def run():",
    "    calc = make_calculator()",
    "    print(calc.add(10, 20))",
    "",
    "    adv = AdvancedCalc()",
    "    print(adv.power(2, 8))",
    "    print(adv.get_history())",
    "",
    "",
    'if __name__ == "__main__":',
    "    run()",
  }, dir .. "/src/advanced.py")

  vim.fn.writefile({
    "[project]",
    'name = "tutorial"',
    'version = "0.1.0"',
  }, dir .. "/pyproject.toml")

  return dir
end

local function render_guide()
  if not state.guide_buf or not vim.api.nvim_buf_is_valid(state.guide_buf) then
    return
  end

  local c = challenges[state.current]
  local total = #challenges
  local filled = math.floor((state.current / total) * 20)
  local bar = string.rep("█", filled) .. string.rep("░", 20 - filled)

  local lines = {
    string.format("Challenge %d/%d  [%s]", state.current, total, bar),
    "",
    "Category: " .. c.category,
    "",
    c.instruction,
    "",
  }
  if c.hint then
    table.insert(lines, "Hint: " .. c.hint)
    table.insert(lines, "")
  end
  table.insert(
    lines,
    "───────────────────────────────────────────"
  )
  table.insert(lines, "<leader>tn       next challenge")
  table.insert(lines, "<leader>tp       prev challenge")
  table.insert(lines, ":q               quit tutorial")

  vim.bo[state.guide_buf].modifiable = true
  vim.api.nvim_buf_set_lines(state.guide_buf, 0, -1, false, lines)
  vim.bo[state.guide_buf].modifiable = false
end

local function go_to_challenge(c)
  if c.file and state.sandbox_dir and state.editor_win and vim.api.nvim_win_is_valid(state.editor_win) then
    local f = state.sandbox_dir .. "/" .. c.file
    if vim.fn.filereadable(f) == 1 then
      vim.api.nvim_set_current_win(state.editor_win)
      vim.cmd("edit " .. f)
    end
  end
  if c.cursor and state.editor_win and vim.api.nvim_win_is_valid(state.editor_win) then
    vim.api.nvim_set_current_win(state.editor_win)
    pcall(vim.api.nvim_win_set_cursor, state.editor_win, c.cursor)
    vim.cmd("normal! zz")
  end
  render_guide()
  if state.editor_win and vim.api.nvim_win_is_valid(state.editor_win) then
    vim.api.nvim_set_current_win(state.editor_win)
  end
end

function M.next()
  if state.current < #challenges then
    table.insert(state.completed, state.current)
    state.current = state.current + 1
    go_to_challenge(challenges[state.current])
  else
    vim.notify(string.format("Tutorial complete! Finished all %d challenges.", #challenges), vim.log.levels.INFO)
  end
end

function M.prev()
  if state.current > 1 then
    state.current = state.current - 1
    go_to_challenge(challenges[state.current])
  end
end

function M.start()
  state.sandbox_dir = create_sandbox_files()
  state.current = 1
  state.completed = {}

  vim.cmd("edit " .. state.sandbox_dir .. "/src/calculator.py")
  state.editor_win = vim.api.nvim_get_current_win()

  vim.cmd("botright vsplit")
  state.guide_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(0, state.guide_buf)
  state.guide_win = vim.api.nvim_get_current_win()
  vim.cmd("vertical resize 50")
  vim.bo[state.guide_buf].buftype = "nofile"
  vim.bo[state.guide_buf].bufhidden = "wipe"
  vim.bo[state.guide_buf].swapfile = false
  vim.wo[state.guide_win].wrap = true
  vim.wo[state.guide_win].number = false
  vim.wo[state.guide_win].relativenumber = false
  vim.wo[state.guide_win].signcolumn = "no"

  local map = require("config.map")
  map("n", "<leader>tn", function()
    M.next()
  end, { desc = "Tutorial next", group = "General", docs = "core-cheatsheet.md" })
  map("n", "<leader>tp", function()
    M.prev()
  end, { desc = "Tutorial prev", group = "General", docs = "core-cheatsheet.md" })

  render_guide()
  vim.api.nvim_set_current_win(state.editor_win)
end

return M
