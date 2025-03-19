local Scene = require "game.scenes.scene"
local Button = require('game.gimmedrinks.ui.button')

local MenuScene = {}
MenuScene.__index = MenuScene
setmetatable(MenuScene, { __index = Scene })

function MenuScene:new()
  return self
end

---@type Button|nil
local startButton


function MenuScene:start()
  startButton = Button.new(64, 64, 'New game', function()
    ChangeScene(Screens.game)
  end)
end

function MenuScene:update()
  if startButton then startButton:update() end
end

function MenuScene:draw()
  love.graphics.print('SUPER GAME', 32, 32)
  love.graphics.print('LOVE Jam 2025', 32, love.graphics.getHeight() - 32)
  if startButton then startButton:draw() end
end

function MenuScene:mousepressed(x, y, button)

end

function MenuScene:mousereleased(x, y, button)
  if button == 1 then
  end
end

return MenuScene
