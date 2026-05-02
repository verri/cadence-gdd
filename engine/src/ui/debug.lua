local T = require("tunables")
local timing = require("src.util.timing")

local Debug = { visible = false, last = {} }

function Debug.toggle() Debug.visible = not Debug.visible end

function Debug.set(key, value)
  Debug.last[key] = value
end

local function fmt_ms(seconds)
  return string.format("%.0f ms", seconds * 1000)
end

function Debug.draw(player, enemy)
  if not Debug.visible then return end
  local x, y = 16, 540
  love.graphics.setColor(0, 0, 0, 0.65)
  love.graphics.rectangle("fill", x - 6, y - 6, 520, 170)
  love.graphics.setColor(0.85, 0.95, 1, 1)
  love.graphics.print("[DEBUG] (F1 toggle, F5 reload tunables)", x, y)

  local dy = y + 18
  local diff = (player.agility or 0) - (enemy.agility or 0)
  love.graphics.print(
    string.format("Agility: player=%d  enemy=%d  diff=%+d", player.agility, enemy.agility, diff),
    x, dy)

  -- Show effective windows for both directions.
  local atk_chain = timing.window_radius(T.chain.demo.base_window, player.agility, enemy.agility)
  local def_base  = timing.window_radius(T.defense.base_window,    player.agility, enemy.agility)
  local cnt_base  = timing.window_radius(T.defense.counter.base_window, player.agility, enemy.agility)
  local rhythm_w  = timing.window_radius(T.rhythm.demo_spell.hit_window, player.agility, 0) -- spells don't have a defender
  dy = dy + 16
  love.graphics.print(string.format("Chain hit window:    %s (perfect %s)",
    fmt_ms(atk_chain), fmt_ms(T.chain.grades.perfect_radius)), x, dy)
  dy = dy + 16
  love.graphics.print(string.format("Defend window:       %s (parry %s, guard %s)",
    fmt_ms(def_base), fmt_ms(T.defense.parry_radius), fmt_ms(T.defense.guard_radius)), x, dy)
  dy = dy + 16
  love.graphics.print(string.format("Counter window:      %s (perfect %s)",
    fmt_ms(cnt_base), fmt_ms(T.defense.counter.perfect_radius)), x, dy)
  dy = dy + 16
  love.graphics.print(string.format("Rhythm note window:  %s", fmt_ms(rhythm_w)), x, dy)

  dy = dy + 18
  if Debug.last.timing then
    love.graphics.print("Last input:  " .. Debug.last.timing, x, dy)
  end
  dy = dy + 16
  if Debug.last.routing then
    love.graphics.print("Last damage: " .. Debug.last.routing, x, dy)
  end
end

return Debug
