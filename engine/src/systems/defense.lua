-- Defense + Counter minigame.
-- Telegraph plays, then a strike "lands" at a known time. Player presses
-- Defend (Z) for Parry/Guard/Stagger/Hit tiers. Holding Trigger (LShift)
-- through the strike commits to Counter: only Perfect lands a counter,
-- anything else is a full hit.

local T = require("tunables")
local timing = require("src.util.timing")
local input = require("src.util.input")

local Defense = {}
Defense.__index = Defense

function Defense.new(attacker, defender)
  local self = setmetatable({}, Defense)
  self.attacker = attacker
  self.defender = defender
  self.cfg = T.defense
  self.t = 0
  self.state = "telegraph"  -- telegraph -> ending -> done
  self.strike_at = self.cfg.telegraph_time
  self.consumed_input = false
  self.def_window = timing.window_radius(self.cfg.base_window, attacker.agility, defender.agility)
  self.cnt_window = timing.window_radius(self.cfg.counter.base_window, defender.agility, attacker.agility)
  self.result = nil
  self.done = false
  return self
end

function Defense:_resolve(tier, offset, counter_intent, counter_perfect)
  local cfg = self.cfg
  local enemy_dmg = cfg.enemy_basic.damage
  local dmg_type = cfg.enemy_basic.type

  local routing
  local outcome = { tier = tier, offset = offset, counter_intent = counter_intent }

  if counter_intent then
    if counter_perfect then
      outcome.counter_landed = true
      -- No damage to defender; counter-attack on attacker.
      local cost = cfg.counter.counter_attack_cost_hp
      self.defender:spend_hp(cost)
      self.attacker:take_damage(cfg.counter.counter_attack_damage, "physical", "hit")
      routing = self.attacker.last_routing
    else
      -- Counter declared but missed → full hit.
      routing = self.defender:take_damage(enemy_dmg, dmg_type, "hit")
      outcome.tier = "hit (counter miss)"
    end
  else
    if tier == "parry" then
      -- No damage at all.
      routing = self.defender:take_damage(0, dmg_type, "parry")
    elseif tier == "guard" then
      local dmg = math.floor(enemy_dmg * cfg.guard_damage_pct + 0.5)
      routing = self.defender:take_damage(dmg, dmg_type, "guard")
    elseif tier == "stagger" then
      local dmg = math.floor(enemy_dmg * cfg.stagger_damage_pct + 0.5)
      routing = self.defender:take_damage(dmg, dmg_type, "stagger")
    else  -- hit
      routing = self.defender:take_damage(enemy_dmg, dmg_type, "hit")
    end
  end

  outcome.routing = routing
  self.result = outcome
  self.state = "ending"
  self.end_timer = 0.6
end

function Defense:press_defend(counter_held)
  if self.state ~= "telegraph" then return end
  if self.consumed_input then return end
  self.consumed_input = true
  local offset = self.t - self.strike_at
  local cfg = self.cfg

  if counter_held then
    -- Counter rules: Perfect or Hit, no in-between.
    local cnt_perfect_radius = cfg.counter.perfect_radius
    if math.abs(offset) <= cnt_perfect_radius then
      self:_resolve("counter", offset, true, true)
    else
      self:_resolve("hit", offset, true, false)
    end
    return
  end

  -- Defend tiers: parry inside parry_radius, guard inside guard_radius,
  -- stagger inside (def_window + stagger_extra), else hit.
  local a = math.abs(offset)
  if a <= cfg.parry_radius then
    self:_resolve("parry", offset)
  elseif a <= cfg.guard_radius then
    self:_resolve("guard", offset)
  elseif a <= self.def_window + cfg.stagger_extra then
    self:_resolve("stagger", offset)
  else
    self:_resolve("hit", offset)
  end
end

function Defense:update(dt, counter_held)
  if self.state == "telegraph" then
    self.t = self.t + dt
    -- If player never pressed and the strike is past the late-band, auto-resolve.
    if not self.consumed_input then
      local offset = self.t - self.strike_at
      if offset > self.cfg.base_window + self.cfg.stagger_extra then
        if counter_held then
          self:_resolve("hit", offset, true, false)
        else
          self:_resolve("hit", offset)
        end
      end
    end
  elseif self.state == "ending" then
    self.end_timer = self.end_timer - dt
    if self.end_timer <= 0 then
      self.state = "done"
      self.done = true
    end
  end
end

function Defense:draw(cx, cy)
  -- Telegraph countdown bar.
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.printf(
    string.format("%s attacks!  [%s] defend   hold [%s]+[%s] counter",
      self.attacker.name, input.label("defend"), input.label("trigger"), input.label("defend")),
    cx - 320, cy - 140, 640, "center")

  -- Visualise window: a horizontal bar, marker travels left-to-right; impact at center.
  local W = 460
  local x0, y0 = cx - W/2, cy
  local impact_x = cx
  -- Window bands (Defend mode shown).
  local function band(radius, color)
    local px = (radius / self.cfg.base_window) * (W / 2)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", impact_x - px, y0 - 12, px * 2, 24)
  end
  band(self.def_window + self.cfg.stagger_extra, {0.4, 0.4, 0.4, 0.5})  -- stagger band
  band(self.def_window,                          {0.6, 0.6, 0.2, 0.6})  -- guard band visual proxy
  band(self.cfg.guard_radius,                    {0.2, 0.7, 0.7, 0.7})  -- guard
  band(self.cfg.parry_radius,                    {0.4, 1.0, 0.6, 0.9})  -- parry
  -- Frame
  love.graphics.setColor(1, 1, 1, 0.8)
  love.graphics.rectangle("line", x0, y0 - 12, W, 24)
  -- Impact line
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.line(impact_x, y0 - 18, impact_x, y0 + 18)

  -- Approaching marker travels from x0 to impact_x as t goes from 0 to strike_at.
  local frac = math.max(0, math.min(1, self.t / self.strike_at))
  local mx = x0 + frac * (W / 2)
  love.graphics.setColor(1, 0.9, 0.3, 1)
  love.graphics.circle("fill", mx, y0, 8)

  -- Show counter-window bracket if user is holding trigger.
  if love.keyboard.isDown(input.trigger) and self.state == "telegraph" then
    local px = (self.cfg.counter.perfect_radius / self.cfg.base_window) * (W / 2)
    love.graphics.setColor(1, 0.4, 0.8, 0.9)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", impact_x - px, y0 - 26, px * 2, 52)
    love.graphics.print("COUNTER", impact_x + px + 6, y0 - 6)
  end

  -- Result text after resolution.
  if self.result then
    love.graphics.setColor(1, 1, 1, 1)
    local txt
    if self.result.counter_intent and self.result.counter_landed then
      txt = "COUNTER!  free counter-attack lands"
    elseif self.result.counter_intent then
      txt = "Counter missed — full hit"
    else
      txt = string.upper(self.result.tier)
    end
    love.graphics.printf(txt, cx - 200, y0 + 30, 400, "center")
  end
end

return Defense
