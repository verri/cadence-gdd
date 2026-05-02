-- Rhythm Magic minigame.
-- Notes scroll right-to-left along a track. The player hits Action when each
-- note crosses the strike line. Performance graded S/A/B/C/Fail.

local T = require("tunables")
local timing = require("src.util.timing")
local input = require("src.util.input")

local Rhythm = {}
Rhythm.__index = Rhythm

function Rhythm.new(caster, target)
  local self = setmetatable({}, Rhythm)
  self.caster = caster
  self.target = target
  self.spell = T.rhythm.demo_spell
  self.t = 0
  self.state = "running"  -- running -> ending -> done

  -- Build note schedule.
  local interval = 60 / self.spell.bpm
  self.notes = {}
  for i = 1, self.spell.notes do
    table.insert(self.notes, {
      time = self.spell.lead_in + (i - 1) * interval,
      hit = false,
      grade = nil,
      offset = nil,
    })
  end
  self.song_length = self.spell.lead_in + (self.spell.notes - 1) * interval + 0.6

  self.window_radius = timing.window_radius(self.spell.hit_window, caster.agility, 0)
  self.scroll_speed = 360  -- pixels per second, visual only
  self.done = false
  return self
end

function Rhythm:start()
  -- Pay MP cost up front.
  self.caster:spend_mp(self.spell.cost_active_mp)
end

function Rhythm:press_action()
  if self.state ~= "running" then return end
  -- Match the closest unhit note within window.
  local best = nil
  local best_abs = math.huge
  for _, n in ipairs(self.notes) do
    if not n.hit then
      local a = math.abs(self.t - n.time)
      if a < best_abs then
        best_abs = a
        best = n
      end
    end
  end
  if not best then return end
  if best_abs > self.window_radius then
    -- Outside window: counts as a wasted press; mark as miss against the soonest.
    return
  end
  best.hit = true
  best.offset = self.t - best.time
  -- Inside window: classify Perfect (within hit_window/3) vs Good.
  if best_abs <= self.window_radius / 3 then
    best.grade = "perfect"
  else
    best.grade = "good"
  end
end

function Rhythm:update(dt)
  if self.state == "running" then
    self.t = self.t + dt
    -- Mark any note whose window has fully passed as miss.
    for _, n in ipairs(self.notes) do
      if not n.hit and (self.t - n.time) > self.window_radius then
        n.hit = true
        n.grade = "miss"
        n.offset = self.t - n.time
      end
    end
    if self.t >= self.song_length then
      self.state = "ending"
      self.end_timer = 0.6
      self:_finalize()
    end
  elseif self.state == "ending" then
    self.end_timer = self.end_timer - dt
    if self.end_timer <= 0 then
      self.state = "done"
      self.done = true
    end
  end
end

function Rhythm:_finalize()
  local perfects, goods, misses = 0, 0, 0
  for _, n in ipairs(self.notes) do
    if n.grade == "perfect" then perfects = perfects + 1
    elseif n.grade == "good" then goods = goods + 1
    else misses = misses + 1 end
  end
  -- Score = (perfects + 0.6 * goods) / total
  local score = (perfects + 0.6 * goods) / #self.notes
  local g = T.rhythm.grades
  local rank
  if misses >= math.floor(#self.notes / 2) then
    rank = "fail"
  elseif score >= g.s then rank = "s"
  elseif score >= g.a then rank = "a"
  elseif score >= g.b then rank = "b"
  elseif score >= g.c then rank = "c"
  else rank = "fail"
  end

  local mult = g.mult[rank] or 0
  local dmg = math.floor(self.spell.base_damage * mult + 0.5)
  if rank == "fail" then
    -- Partial Active MP refund
    self.caster:refund_mp(math.floor(self.spell.cost_active_mp * g.fail_refund_pct + 0.5))
  end
  self.summary = {
    rank = rank, perfects = perfects, goods = goods, misses = misses,
    damage = dmg, score = score,
  }
end

function Rhythm:apply_damage()
  if not self.summary or self.summary.damage <= 0 then return end
  self.target:take_damage(self.summary.damage, self.spell.damage_type, "hit")
end

function Rhythm:draw(cx, cy)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(
    string.format("%s — press [%s] on the beat", self.spell.name, input.label("action")),
    cx - 320, cy - 160, 640, "center")

  -- Track
  local tx, ty = cx - 360, cy
  local TW = 720
  love.graphics.setColor(0.15, 0.15, 0.25, 1)
  love.graphics.rectangle("fill", tx, ty - 20, TW, 40)
  love.graphics.setColor(1, 1, 1, 0.8)
  love.graphics.rectangle("line", tx, ty - 20, TW, 40)

  -- Strike line near left side.
  local strike_x = tx + 120
  love.graphics.setColor(1, 0.8, 0.2, 1)
  love.graphics.setLineWidth(3)
  love.graphics.line(strike_x, ty - 30, strike_x, ty + 30)

  -- Notes scroll right-to-left toward strike line.
  for _, n in ipairs(self.notes) do
    local nx = strike_x + (n.time - self.t) * self.scroll_speed
    if nx >= tx and nx <= tx + TW then
      if not n.hit then
        love.graphics.setColor(0.95, 0.95, 0.95, 1)
        love.graphics.circle("fill", nx, ty, 10)
      else
        if n.grade == "perfect" then
          love.graphics.setColor(0.4, 1.0, 0.6, 0.6)
        elseif n.grade == "good" then
          love.graphics.setColor(1.0, 0.85, 0.3, 0.6)
        else
          love.graphics.setColor(1.0, 0.3, 0.3, 0.6)
        end
        love.graphics.circle("fill", nx, ty, 8)
      end
    end
  end

  -- Window radius hint around strike line.
  local px = self.window_radius * self.scroll_speed
  love.graphics.setColor(1, 1, 1, 0.15)
  love.graphics.rectangle("fill", strike_x - px, ty - 20, px * 2, 40)

  -- Summary
  if self.summary then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(
      string.format("RANK %s   P:%d G:%d M:%d   damage %d",
        string.upper(self.summary.rank),
        self.summary.perfects, self.summary.goods, self.summary.misses,
        self.summary.damage),
      cx - 300, ty + 40, 600, "center")
  end
end

return Rhythm
