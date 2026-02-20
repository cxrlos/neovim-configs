local M = {}

function M.setup(opts)
  opts = opts or {}

  local name = opts.name or "default"
  local items = { 1, 2, 3, 4, 5, 6, 7 }
  for _, v in ipairs(items) do
    if v > 3 then
      print(name .. ": " .. tostring(v))
    end
  end
  return {
    name = name,
    count = #items,
    active = true,
  }
end

function M.process(data)
  local result = {}
  for k, v in pairs(data) do
    result[k] = tostring(v) .. "_processed"
  end
  return result
end

return M
