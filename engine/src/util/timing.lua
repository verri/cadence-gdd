local M = {}

local T = require("tunables")

-- Map a stat 0..100 onto recovery percent of pool.
function M.recovery_pct(stat)
  local r = T.recovery
  local span = r.max_stat - r.min_stat
  local frac = math.max(0, math.min(1, (stat - r.min_stat) / span))
  return r.min_pct + frac * (r.max_pct - r.min_pct)
end

-- Final timing-window radius given a base window and an Agility differential.
function M.window_radius(base, attacker_agi, defender_agi)
  local diff = (attacker_agi or 0) - (defender_agi or 0)
  local scaled = base * (1 + T.agility.k * diff / 100)
  if scaled < T.agility.min_window then scaled = T.agility.min_window end
  if scaled > T.agility.max_window then scaled = T.agility.max_window end
  return scaled
end

-- Classify timing offset (seconds away from center) given a window radius.
-- Returns "perfect" | "good" | "miss".
function M.classify(offset, window_radius, perfect_radius)
  local a = math.abs(offset)
  if a <= perfect_radius then return "perfect" end
  if a <= window_radius then return "good" end
  return "miss"
end

return M
