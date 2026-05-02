local T = require("tunables")

local Log = { lines = {} }

function Log.push(text)
  table.insert(Log.lines, text)
  while #Log.lines > T.misc.log_lines do
    table.remove(Log.lines, 1)
  end
end

function Log.clear()
  Log.lines = {}
end

function Log.draw(x, y)
  love.graphics.setColor(1, 1, 1, 0.85)
  for i, line in ipairs(Log.lines) do
    local alpha = 0.4 + 0.6 * (i / #Log.lines)
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.print(line, x, y + (i - 1) * 16)
  end
end

return Log
