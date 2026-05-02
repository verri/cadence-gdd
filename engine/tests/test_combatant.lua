-- Headless sanity check for the two-gauge resource model.
-- Run with:  cd engine && lua5.1 tests/test_combatant.lua

package.path = package.path .. ";./?.lua;./?/init.lua"

local Combatant = require("src.entities.combatant")

local pass, fail = 0, 0
local function eq(name, got, want)
  if got == want then
    pass = pass + 1
  else
    fail = fail + 1
    io.stderr:write(string.format("FAIL %s: got %s want %s\n",
      name, tostring(got), tostring(want)))
  end
end

-- GDD worked example (battle/stats-and-resources.md):
-- Vitality 150, Active HP starts at 60.
-- After 50-cost Chain: Active 60->10, Reserve 150.
-- After refresh to ~30 then another 50 cost: Active->0, 20 overflow,
-- Reserve 150->130.
-- Then 50 dmg fail-defense (full hit): Active 0 already, all 50 to Reserve,
-- Reserve 130->80.
local c = Combatant.new({
  name="Test", vitality=150, stamina=50, magic=50, spirit=50, agility=50,
})
c.hp_active = 60
c.hp_reserve = 150

c:spend_hp(50)
eq("after first chain hp_active", c.hp_active, 10)
eq("after first chain hp_reserve", c.hp_reserve, 150)

-- Manually set Active to 30 (simulating the per-turn refresh).
c.hp_active = 30
c:spend_hp(50)
eq("after second chain hp_active",  c.hp_active, 0)
eq("after second chain hp_reserve", c.hp_reserve, 130)

c:take_damage(50, "physical", "hit")
eq("after hit hp_active",  c.hp_active, 0)
eq("after hit hp_reserve", c.hp_reserve, 80)

-- Mana Veil routing: physical hit while Veil up routes to MP.
local mage = Combatant.new({
  name="M", vitality=100, stamina=50, magic=120, spirit=50, agility=50, has_veil=true,
})
mage.hp_active, mage.hp_reserve = 50, 100
mage.mp_active, mage.mp_reserve = 60, 120
mage:toggle_veil()
mage:take_damage(40, "physical", "hit")
eq("veil routes phys to mp_active", mage.mp_active, 20)
eq("veil leaves hp_active intact",   mage.hp_active, 50)

-- Psychic always to MP, ignores Veil up or down.
mage:take_damage(30, "psychic", "hit")
eq("psychic to mp_active", mage.mp_active, 0)
eq("psychic overflow to mp_reserve", mage.mp_reserve, 110)

-- Active is capped by Reserve. Drain Reserve below current Active.
local cap = Combatant.new({
  name="Cap", vitality=100, stamina=50, magic=50, spirit=50, agility=50,
})
cap.hp_active, cap.hp_reserve = 90, 100
cap:spend_hp(50)  -- 90 active absorbs 50, no overflow
eq("partial spend hp_active",  cap.hp_active, 40)
eq("partial spend hp_reserve", cap.hp_reserve, 100)
cap.hp_active = 90  -- restore active to 90
cap.hp_reserve = 100
cap:spend_hp(150)  -- 90 active + 60 overflow
eq("big spend hp_active clamped",  cap.hp_active, 0)
eq("big spend hp_reserve",         cap.hp_reserve, 40)

-- on_turn_start overflow into Reserve when Active is full.
local r = Combatant.new({
  name="R", vitality=100, stamina=50, magic=50, spirit=50, agility=50,
})
-- Drain reserve a bit, max active.
r.hp_reserve = 80
r.hp_active  = 80   -- already capped at reserve
r:on_turn_start()
-- 50-stamina refresh = 15% of 100 = 15. Active room = 0, all overflow to reserve.
eq("overflow turn hp_active",  r.hp_active, 80)
eq("overflow turn hp_reserve", r.hp_reserve, 95)

-- Recovery cap: cannot exceed vitality.
r.hp_reserve = 95
r.hp_active = 95
r:on_turn_start()
eq("reserve capped at vitality", r.hp_reserve, 100)

-- Death conditions.
local d = Combatant.new({
  name="D", vitality=50, stamina=50, magic=50, spirit=50, agility=50,
})
d:spend_hp(999)
eq("hp drained = dead", d:is_dead(), true)
local d2 = Combatant.new({
  name="D2", vitality=50, stamina=50, magic=50, spirit=50, agility=50,
})
d2:spend_mp(999)
eq("mp drained = dead", d2:is_dead(), true)

print(string.format("Results: %d passed, %d failed", pass, fail))
os.exit(fail == 0 and 0 or 1)
