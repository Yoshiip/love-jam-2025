---@diagnostic disable: duplicate-set-field
https = nil
local overlayStats = require("lib.overlayStats")
local runtimeLoader = require("runtime.loader")
local gimmedrinks = require("gimmedrinks.gimmedrinks")

function love.load()
  https = runtimeLoader.loadHTTPS()
  gimmedrinks.load()
  overlayStats.load() -- Should always be called last
end

function love.draw()
  gimmedrinks.draw()
  overlayStats.draw() -- Should always be called last
end

function love.update(dt)
  gimmedrinks.update(dt)
  overlayStats.update(dt) -- Should always be called last
end

function love.keypressed(key)
  if key == "escape" and love.system.getOS() ~= "Web" then
    love.event.quit()
  else
    overlayStats.handleKeyboard(key) -- Should always be called last
  end
end

function love.touchpressed(id, x, y, dx, dy, pressure)
  overlayStats.handleTouch(id, x, y, dx, dy, pressure) -- Should always be called last
end
