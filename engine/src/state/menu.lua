-- Top-level command menu shown on the player's turn.

local input = require("src.util.input")

local Menu = {}
Menu.__index = Menu

local OPTIONS = {
  { id = "attack", label = "Attack (Chain Strike)" },
  { id = "magic",  label = "Magic (Rhythm)" },
  { id = "veil",   label = "Toggle Mana Veil" },
  { id = "rest",   label = "Rest (recover Reserve)" },
  { id = "pass",   label = "Pass turn" },
}

function Menu.new()
  local self = setmetatable({}, Menu)
  self.cursor = 1
  return self
end

function Menu:keypressed(key)
  if key == input.up then
    self.cursor = self.cursor - 1
    if self.cursor < 1 then self.cursor = #OPTIONS end
  elseif key == input.down then
    self.cursor = self.cursor + 1
    if self.cursor > #OPTIONS then self.cursor = 1 end
  elseif key == input.confirm or key == input.action then
    return OPTIONS[self.cursor].id
  end
  return nil
end

function Menu:draw(x, y)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("YOUR TURN — choose a command", x, y)
  for i, opt in ipairs(OPTIONS) do
    local oy = y + 22 + (i - 1) * 18
    if i == self.cursor then
      love.graphics.setColor(1, 0.9, 0.4, 1)
      love.graphics.print("> " .. opt.label, x, oy)
    else
      love.graphics.setColor(0.85, 0.85, 0.85, 1)
      love.graphics.print("  " .. opt.label, x, oy)
    end
  end
  love.graphics.setColor(0.7, 0.7, 0.7, 1)
  love.graphics.print("↑/↓ navigate, Enter or X confirm", x, y + 22 + #OPTIONS * 18 + 8)
end

return Menu
