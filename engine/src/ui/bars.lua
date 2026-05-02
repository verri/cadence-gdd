-- Two-gauge bars: Reserve as solid background, Active as bright foreground,
-- max as faint outline. The gap between Reserve and Max visualises overflow loss.

local M = {}

local PAD = 2

local function set(rgb, a)
  love.graphics.setColor(rgb[1], rgb[2], rgb[3], a or 1)
end

-- Colors
local C = {
  hp_max     = {0.18, 0.05, 0.05},
  hp_reserve = {0.55, 0.10, 0.12},
  hp_active  = {0.95, 0.30, 0.30},
  mp_max     = {0.05, 0.10, 0.20},
  mp_reserve = {0.20, 0.35, 0.70},
  mp_active  = {0.45, 0.75, 1.00},
  outline    = {0.85, 0.85, 0.85},
  text       = {1, 1, 1},
  veil       = {0.55, 0.95, 0.85},
}

local function draw_bar(x, y, w, h, max_val, reserve_val, active_val, max_color, reserve_color, active_color)
  -- Max (full width)
  set(max_color)
  love.graphics.rectangle("fill", x, y, w, h)
  -- Reserve
  if max_val > 0 then
    local rw = w * (reserve_val / max_val)
    set(reserve_color)
    love.graphics.rectangle("fill", x, y, rw, h)
    -- Active (clamped by reserve)
    local aw = w * (active_val / max_val)
    set(active_color)
    love.graphics.rectangle("fill", x, y, aw, h)
  end
  -- Outline
  set(C.outline, 0.9)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", x, y, w, h)
end

function M.draw_combatant(c, x, y, w, opts)
  opts = opts or {}
  local h = 18
  local label_h = 18
  local total_h = label_h + h * 2 + PAD * 2

  -- Name
  set(C.text)
  love.graphics.print(c.name, x, y)

  -- Veil indicator
  if c.has_veil then
    if c.veil_active then
      set(C.veil)
      love.graphics.print("[VEIL ON]", x + 200, y)
    else
      set(C.text, 0.4)
      love.graphics.print("[veil off]", x + 200, y)
    end
  end

  -- HP
  local hp_y = y + label_h
  draw_bar(x, hp_y, w, h, c:max_hp(), c.hp_reserve, c.hp_active,
           C.hp_max, C.hp_reserve, C.hp_active)
  set(C.text)
  love.graphics.print(
    string.format("HP %3d/%3d  Reserve %3d/%3d",
      c.hp_active, c:max_hp(), c.hp_reserve, c:max_hp()),
    x + 6, hp_y + 1)

  -- MP
  local mp_y = hp_y + h + PAD
  draw_bar(x, mp_y, w, h, c:max_mp(), c.mp_reserve, c.mp_active,
           C.mp_max, C.mp_reserve, C.mp_active)
  set(C.text)
  love.graphics.print(
    string.format("MP %3d/%3d  Reserve %3d/%3d",
      c.mp_active, c:max_mp(), c.mp_reserve, c:max_mp()),
    x + 6, mp_y + 1)

  return total_h
end

return M
