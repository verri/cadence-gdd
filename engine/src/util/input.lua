-- Keyboard mapping mirrors a gamepad layout for the GDD's controls.
--   Action / "A button"  -> X
--   Defend / "B button"  -> Z
--   Trigger / "R button" -> LShift
--   Confirm/menu select  -> Return / Space
local M = {
  action  = "x",
  defend  = "z",
  trigger = "lshift",
  up      = "up",
  down    = "down",
  left    = "left",
  right   = "right",
  confirm = "return",
  cancel  = "escape",
  reload  = "f5",
  debug   = "f1",
}

function M.label(name)
  return ({
    action="X", defend="Z", trigger="LShift", confirm="Enter", cancel="Esc",
    up="↑", down="↓", left="←", right="→",
  })[name] or name
end

return M
