local M = {}

function M.clamp(x, lo, hi)
  if x < lo then return lo end
  if x > hi then return hi end
  return x
end

function M.lerp(a, b, t)
  return a + (b - a) * t
end

function M.ease_out_quad(t)
  return 1 - (1 - t) * (1 - t)
end

return M
