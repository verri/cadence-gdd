-- Combatant: a single fighter holding stats, HP/MP gauges, and Veil state.
-- Implements the two-gauge model and overflow rules from
-- battle/stats-and-resources.md.

local T = require("tunables")
local timing = require("src.util.timing")

local Combatant = {}
Combatant.__index = Combatant

function Combatant.new(spec)
  local self = setmetatable({}, Combatant)
  self.name = spec.name or "Unknown"
  self.vitality = spec.vitality or 100
  self.stamina  = spec.stamina  or 50
  self.magic    = spec.magic    or 50
  self.spirit   = spec.spirit   or 50
  self.agility  = spec.agility  or 50
  self.has_veil = spec.has_veil or false

  -- Reserve = current cap for Active. Death when hp_reserve or mp_reserve hits 0.
  self.hp_reserve = self.vitality
  self.mp_reserve = self.magic
  -- Active starts at half full per GDD spirit (refresh-on-turn brings it up).
  self.hp_active  = math.floor(self.vitality * 0.5)
  self.mp_active  = math.floor(self.magic   * 0.5)

  self.veil_active = false
  self.last_routing = nil  -- diagnostic trail
  return self
end

function Combatant:max_hp() return self.vitality end
function Combatant:max_mp() return self.magic end

function Combatant:is_dead()
  return self.hp_reserve <= 0 or self.mp_reserve <= 0
end

function Combatant:cause_of_death()
  if self.hp_reserve <= 0 then return "HP Reserve depleted" end
  if self.mp_reserve <= 0 then return "MP Reserve depleted" end
  return nil
end

-- Spend cost from a pool: Active first, overflow eats Reserve (which lowers cap).
local function spend_pool(active, reserve, max, cost)
  local from_active = math.min(active, cost)
  active = active - from_active
  local remainder = cost - from_active
  if remainder > 0 then
    reserve = math.max(0, reserve - remainder)
    -- Active is capped by reserve; if reserve dropped below active, clamp.
    if active > reserve then active = reserve end
  end
  return active, reserve
end

function Combatant:spend_hp(cost)
  self.hp_active, self.hp_reserve = spend_pool(
    self.hp_active, self.hp_reserve, self.vitality, cost)
end

function Combatant:spend_mp(cost)
  self.mp_active, self.mp_reserve = spend_pool(
    self.mp_active, self.mp_reserve, self.magic, cost)
end

-- Refund Active MP (e.g. on Fail cast). Capped by reserve.
function Combatant:refund_mp(amount)
  self.mp_active = math.min(self.mp_reserve, self.mp_active + amount)
end

-- Apply incoming damage of a given type. Returns a routing trace table.
-- damage_type: "physical" | "elemental" | "psychic"
-- defense_tier: "parry" | "guard" | "stagger" | "hit"  (already applied to amount)
function Combatant:take_damage(amount, damage_type, defense_tier)
  if amount <= 0 then
    self.last_routing = { amount=0, type=damage_type, tier=defense_tier, target="none" }
    return self.last_routing
  end

  -- Resolve target pool by routing rules.
  local target_pool  -- "hp" or "mp"
  if damage_type == "psychic" then
    target_pool = "mp"  -- always to MP, ignores Veil
  elseif self.veil_active and (damage_type == "physical" or damage_type == "elemental") then
    target_pool = "mp"
  else
    target_pool = "hp"
  end

  -- A successful Parry already nullified amount upstream; Guard is Active-only.
  local active_only = (defense_tier == "guard" or defense_tier == "parry")

  local before_active, before_reserve
  if target_pool == "hp" then
    before_active, before_reserve = self.hp_active, self.hp_reserve
    if active_only then
      self.hp_active = math.max(0, self.hp_active - amount)
    else
      self.hp_active, self.hp_reserve = spend_pool(
        self.hp_active, self.hp_reserve, self.vitality, amount)
    end
  else
    before_active, before_reserve = self.mp_active, self.mp_reserve
    if active_only then
      self.mp_active = math.max(0, self.mp_active - amount)
    else
      self.mp_active, self.mp_reserve = spend_pool(
        self.mp_active, self.mp_reserve, self.magic, amount)
    end
  end

  self.last_routing = {
    amount = amount, type = damage_type, tier = defense_tier,
    target = target_pool, active_only = active_only,
    before_active = before_active, before_reserve = before_reserve,
  }
  return self.last_routing
end

-- Start-of-turn Active refresh, with overflow into Reserve (capped at max).
function Combatant:on_turn_start()
  local hp_pct = timing.recovery_pct(self.stamina)
  local mp_pct = timing.recovery_pct(self.spirit)
  local hp_refill = math.floor(self.vitality * hp_pct + 0.5)
  local mp_refill = math.floor(self.magic    * mp_pct + 0.5)

  -- HP
  local hp_room = self.hp_reserve - self.hp_active
  local hp_to_active = math.min(hp_refill, hp_room)
  self.hp_active = self.hp_active + hp_to_active
  local hp_overflow = hp_refill - hp_to_active
  if hp_overflow > 0 then
    self.hp_reserve = math.min(self.vitality, self.hp_reserve + hp_overflow)
  end

  -- MP
  local mp_room = self.mp_reserve - self.mp_active
  local mp_to_active = math.min(mp_refill, mp_room)
  self.mp_active = self.mp_active + mp_to_active
  local mp_overflow = mp_refill - mp_to_active
  if mp_overflow > 0 then
    self.mp_reserve = math.min(self.magic, self.mp_reserve + mp_overflow)
  end

  return {
    hp_refill=hp_refill, hp_overflow=hp_overflow,
    mp_refill=mp_refill, mp_overflow=mp_overflow,
  }
end

function Combatant:rest()
  -- Rest: Reserve recovers at the same per-turn rate; no active spend.
  local hp_pct = timing.recovery_pct(self.stamina)
  local mp_pct = timing.recovery_pct(self.spirit)
  local hp_gain = math.floor(self.vitality * hp_pct + 0.5)
  local mp_gain = math.floor(self.magic    * mp_pct + 0.5)
  self.hp_reserve = math.min(self.vitality, self.hp_reserve + hp_gain)
  self.mp_reserve = math.min(self.magic,    self.mp_reserve + mp_gain)
  return { hp_gain=hp_gain, mp_gain=mp_gain }
end

function Combatant:toggle_veil()
  if not self.has_veil then return false end
  self.veil_active = not self.veil_active
  return self.veil_active
end

return Combatant
