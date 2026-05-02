function love.conf(t)
  t.identity = "cadence-poc"
  t.version = "11.5"
  t.console = false
  t.window.title = "Cadence of the Fallen — Battle PoC"
  t.window.width = 1280
  t.window.height = 720
  t.window.resizable = false
  t.window.vsync = 1
  t.window.msaa = 4
  t.modules.audio = true
  t.modules.joystick = true
  t.modules.physics = false
end
