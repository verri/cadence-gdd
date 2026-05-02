-- Battle state. Drives the round/turn loop, dispatches to minigames,
-- handles enemy AI (just one telegraphed strike for v0).

local T = require("tunables")
local Combatant = require("src.entities.combatant")
local Menu      = require("src.state.menu")
local Chain     = require("src.systems.chain")
local Defense   = require("src.systems.defense")
local Rhythm    = require("src.systems.rhythm")
local Bars      = require("src.ui.bars")
local Log       = require("src.ui.log")
local Debug     = require("src.ui.debug")
local input     = require("src.util.input")

local Battle = {}
Battle.__index = Battle

function Battle.new()
  local self = setmetatable({}, Battle)
  self:reset()
  return self
end

function Battle:reset()
  self.player = Combatant.new(T.player)
  self.enemy  = Combatant.new(T.enemy)
  self.round = 0

  -- Random initial turn order (just two combatants for v0).
  if love.math.random() < 0.5 then
    self.order = { self.player, self.enemy }
  else
    self.order = { self.enemy, self.player }
  end
  self.turn_idx = 0
  self.menu = Menu.new()
  self.minigame = nil
  self.minigame_kind = nil
  self.phase = "intro"
  self.intro_timer = 0.6
  Log.clear()
  Log.push(string.format("Battle starts. Order: %s -> %s",
    self.order[1].name, self.order[2].name))
end

local function fmt_routing(r)
  if not r or r.amount == 0 then return "no damage" end
  return string.format("%s %s -> %s%s  (%d dmg)",
    r.tier, r.type, r.target,
    r.active_only and " [Active only]" or " [overflow allowed]",
    r.amount)
end

function Battle:_advance_turn()
  -- Resolve any pending death.
  if self.player:is_dead() or self.enemy:is_dead() then
    self.phase = "over"
    return
  end

  self.turn_idx = self.turn_idx + 1
  if self.turn_idx > #self.order then
    self.turn_idx = 1
    self.round = self.round + 1
    Log.push(string.format("--- Round %d ---", self.round))
  end

  local actor = self.order[self.turn_idx]
  local r = actor:on_turn_start()
  Log.push(string.format("%s refresh: HP +%d (overflow %d), MP +%d (overflow %d)",
    actor.name, r.hp_refill - r.hp_overflow, r.hp_overflow,
    r.mp_refill - r.mp_overflow, r.mp_overflow))

  if actor == self.player then
    self.phase = "player_menu"
  else
    self.phase = "enemy_telegraph"
    self.minigame = Defense.new(self.enemy, self.player)
    self.minigame_kind = "defense"
  end
end

function Battle:_chose(cmd)
  if cmd == "attack" then
    self.minigame = Chain.new(self.player, self.enemy)
    self.minigame:start()
    self.minigame_kind = "chain"
    self.phase = "player_chain"
    Log.push(string.format("%s begins %s", self.player.name, self.minigame.move.name))
  elseif cmd == "magic" then
    if self.player.mp_active <= 0 and self.player.mp_reserve < T.rhythm.demo_spell.cost_active_mp then
      Log.push("Not enough MP to cast.")
      return
    end
    self.minigame = Rhythm.new(self.player, self.enemy)
    self.minigame:start()
    self.minigame_kind = "rhythm"
    self.phase = "player_rhythm"
    Log.push(string.format("%s casts %s", self.player.name, self.minigame.spell.name))
  elseif cmd == "veil" then
    local now = self.player:toggle_veil()
    Log.push(string.format("Mana Veil %s", now and "RAISED" or "lowered"))
    self:_advance_turn()
  elseif cmd == "rest" then
    local g = self.player:rest()
    Log.push(string.format("%s rests. HP Reserve +%d, MP Reserve +%d",
      self.player.name, g.hp_gain, g.mp_gain))
    self:_advance_turn()
  elseif cmd == "pass" then
    Log.push(string.format("%s passes.", self.player.name))
    self:_advance_turn()
  end
end

function Battle:update(dt)
  if self.phase == "intro" then
    self.intro_timer = self.intro_timer - dt
    if self.intro_timer <= 0 then self:_advance_turn() end
    return
  end

  if self.phase == "player_chain" then
    self.minigame:update(dt)
    if self.minigame.done then
      self.minigame:apply_damage()
      Log.push(string.format("Chain ends — completed=%s, damage %d. Routing: %s",
        tostring(self.minigame.completed), self.minigame.total_damage,
        fmt_routing(self.enemy.last_routing)))
      Debug.set("routing", fmt_routing(self.enemy.last_routing))
      self.minigame = nil
      self:_advance_turn()
    end
  elseif self.phase == "player_rhythm" then
    self.minigame:update(dt)
    if self.minigame.done then
      self.minigame:apply_damage()
      local s = self.minigame.summary
      Log.push(string.format("Cast result: rank %s, %d dmg. Routing: %s",
        string.upper(s.rank), s.damage, fmt_routing(self.enemy.last_routing)))
      Debug.set("routing", fmt_routing(self.enemy.last_routing))
      self.minigame = nil
      self:_advance_turn()
    end
  elseif self.phase == "enemy_telegraph" then
    local counter_held = love.keyboard.isDown(input.trigger)
    self.minigame:update(dt, counter_held)
    if self.minigame.done then
      local r = self.minigame.result
      local desc
      if r.counter_intent and r.counter_landed then
        desc = string.format("COUNTER landed on %s. Routing: %s",
          self.enemy.name, fmt_routing(self.enemy.last_routing))
      else
        desc = string.format("Defense: %s. Routing: %s",
          tostring(r.tier), fmt_routing(self.player.last_routing))
      end
      Log.push(desc)
      Debug.set("timing", string.format("offset %+.0f ms", (r.offset or 0) * 1000))
      Debug.set("routing", fmt_routing(self.player.last_routing or self.enemy.last_routing))
      self.minigame = nil
      self:_advance_turn()
    end
  end
end

function Battle:keypressed(key)
  if key == input.cancel then love.event.quit() end
  if key == input.debug then Debug.toggle() end
  if key == input.reload then self:_reload_tunables() end

  if self.phase == "over" then
    if key == input.confirm or key == input.action then self:reset() end
    return
  end

  if self.phase == "player_menu" then
    local cmd = self.menu:keypressed(key)
    if cmd then self:_chose(cmd) end
  elseif self.phase == "player_chain" then
    if key == input.action then self.minigame:press_action() end
  elseif self.phase == "player_rhythm" then
    if key == input.action then self.minigame:press_action() end
  elseif self.phase == "enemy_telegraph" then
    if key == input.defend then
      local counter_held = love.keyboard.isDown(input.trigger)
      self.minigame:press_defend(counter_held)
    end
  end
end

function Battle:_reload_tunables()
  package.loaded["tunables"] = nil
  T = require("tunables")
  Log.push("tunables.lua reloaded")
end

function Battle:draw()
  local W, H = love.graphics.getDimensions()
  love.graphics.clear(0.07, 0.07, 0.10)

  -- Player bars (bottom-left)
  Bars.draw_combatant(self.player, 32, H - 110, 460)

  -- Enemy bars (top-left)
  Bars.draw_combatant(self.enemy, 32, 32, 460)

  -- Center stage
  local cx, cy = W / 2, H / 2 - 30

  if self.phase == "intro" then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Battle Begin", cx - 200, cy - 20, 400, "center")
  elseif self.phase == "player_menu" then
    self.menu:draw(W - 360, H - 220)
  elseif self.minigame then
    self.minigame:draw(cx, cy)
  elseif self.phase == "over" then
    love.graphics.setColor(1, 1, 1, 1)
    local winner = self.player:is_dead() and self.enemy.name or self.player.name
    local loser  = self.player:is_dead() and self.player or self.enemy
    love.graphics.printf(
      string.format("%s wins.\n%s — %s\n[Enter] to restart",
        winner, loser.name, loser:cause_of_death() or "down"),
      cx - 240, cy - 30, 480, "center")
  end

  -- Log (bottom-right)
  Log.draw(W - 560, H - 220)

  Debug.draw(self.player, self.enemy)
end

return Battle
