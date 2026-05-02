-- Chain Strike minigame.
-- One demo move (Triple Cut). State machine: idle -> running -> done.
-- A shrinking ring telegraphs each impact; the player presses Action at impact.

local T = require("tunables")
local timing = require("src.util.timing")
local input = require("src.util.input")

local Chain = {}
Chain.__index = Chain

function Chain.new(attacker, defender)
  local self = setmetatable({}, Chain)
  self.attacker = attacker
  self.defender = defender
  self.move = T.chain.demo
  self.state = "idle"
  self.t = 0
  self.hit_index = 1
  self.results = {}            -- per-hit grade
  self.window_radius = timing.window_radius(
    self.move.base_window, attacker.agility, defender.agility)
  self.done = false
  self.total_damage = 0
  self.completed = false       -- all hits at least Good = chain completes
  self.consumed_input = false  -- one press per hit
  return self
end

function Chain:start()
  self.state = "running"
  self.t = 0
  self.hit_index = 1
  self.consumed_input = false
  -- Pay base cost up front (matches GDD: cost is per Chain Strike).
  self.attacker:spend_hp(self.move.cost_active_hp)
end

local function hit_time(i, move)
  return i * move.hit_interval
end

function Chain:current_target_time()
  return hit_time(self.hit_index, self.move)
end

-- Score and advance to next hit (or end).
function Chain:_resolve_hit(grade, offset)
  table.insert(self.results, { grade = grade, offset = offset })
  local g = T.chain.grades
  local mult = (grade == "perfect" and g.perfect_mult)
            or (grade == "good"    and g.good_mult)
            or g.miss_mult
  local dmg = math.floor(self.move.base_damage_per_hit * mult + 0.5)
  self.total_damage = self.total_damage + dmg

  if grade == "miss" then
    -- Chain ends on miss; remaining hits are dropped.
    self.state = "ending"
    self.end_timer = 0.4
    self.completed = false
    return
  end

  self.hit_index = self.hit_index + 1
  self.consumed_input = false
  if self.hit_index > self.move.hits then
    self.completed = true
    self.state = "ending"
    self.end_timer = 0.4
  end
end

function Chain:press_action()
  if self.state ~= "running" then return end
  if self.consumed_input then return end
  self.consumed_input = true
  local target = self:current_target_time()
  local offset = self.t - target
  local g = T.chain.grades
  local grade = timing.classify(offset, self.window_radius, g.perfect_radius)
  self:_resolve_hit(grade, offset)
end

function Chain:update(dt)
  if self.state == "running" then
    self.t = self.t + dt
    -- Auto-miss if player let the window close past this hit.
    local target = self:current_target_time()
    if not self.consumed_input and (self.t - target) > self.window_radius then
      self:_resolve_hit("miss", self.t - target)
    end
  elseif self.state == "ending" then
    self.end_timer = self.end_timer - dt
    if self.end_timer <= 0 then
      self.state = "done"
      self.done = true
    end
  end
end

-- Apply this Chain's damage to defender. Caller decides damage type (physical).
function Chain:apply_damage()
  if self.total_damage <= 0 then return end
  self.defender:take_damage(self.total_damage, "physical", "hit")
end

function Chain:draw(cx, cy)
  if self.state == "idle" then return end
  -- Banner
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(self.move.name, cx - 200, cy - 140, 400, "center")
  love.graphics.printf(
    string.format("Hit %d / %d   press [%s]", self.hit_index, self.move.hits, input.label("action")),
    cx - 200, cy - 120, 400, "center")

  if self.state == "running" then
    local target = self:current_target_time()
    local dt = target - self.t
    -- Ring shrinks from R_outer at -window_radius to a fixed inner radius at impact.
    local R_inner = 40
    local R_outer = 120
    local progress
    if dt > self.window_radius then
      progress = 0  -- not yet visible inside the ring
    elseif dt < -self.window_radius then
      progress = 1
    else
      progress = (self.window_radius - dt) / (self.window_radius * 2)
    end
    local r = R_outer + (R_inner - R_outer) * progress

    -- Static target ring at impact size
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", cx, cy, R_inner)

    -- Approaching ring
    if math.abs(dt) <= self.window_radius * 1.2 then
      local color = {1, 0.85, 0.3, 1}
      if math.abs(dt) <= T.chain.grades.perfect_radius then
        color = {0.4, 1.0, 0.6, 1}
      end
      love.graphics.setColor(color)
      love.graphics.setLineWidth(3)
      love.graphics.circle("line", cx, cy, r)
    end
  end

  -- Result strip
  love.graphics.setColor(1, 1, 1, 1)
  local sx = cx - (self.move.hits * 30) / 2
  for i = 1, self.move.hits do
    local r = self.results[i]
    local color
    if not r then
      color = {0.3, 0.3, 0.3, 1}
    elseif r.grade == "perfect" then
      color = {0.4, 1.0, 0.6, 1}
    elseif r.grade == "good" then
      color = {1.0, 0.85, 0.3, 1}
    else
      color = {1.0, 0.3, 0.3, 1}
    end
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", sx + (i - 1) * 30, cy + 100, 24, 12)
  end
end

return Chain
