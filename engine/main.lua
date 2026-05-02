-- Cadence of the Fallen — Battle PoC entry point.
-- Run from this folder:  love .

-- Lua 5.1-style require path (Love2D). The default already includes ?.lua,
-- but we add src/ for nicer module names like require("src.systems.chain").
package.path = package.path .. ";./?.lua;./?/init.lua"

local Battle

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.math.setRandomSeed(os.time())
  Battle = require("src.state.battle").new()
end

function love.update(dt)
  Battle:update(dt)
end

function love.keypressed(key)
  Battle:keypressed(key)
end

function love.draw()
  Battle:draw()
  love.graphics.setColor(0.6, 0.6, 0.7, 0.8)
  love.graphics.print(
    "Cadence PoC v0   F1 debug   F5 reload tunables   Esc quit",
    16, love.graphics.getHeight() - 20)
end
