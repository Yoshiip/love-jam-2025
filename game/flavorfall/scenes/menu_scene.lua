local Scene = require "flavorfall.scenes.scene"
local Button = require 'flavorfall.ui.button'

local MenuScene = {}
MenuScene.__index = MenuScene
setmetatable(MenuScene, { __index = Scene })

function MenuScene:new()
  return self
end

---@type Button|nil
local startButton


function MenuScene:start()
  startButton = Button.new(640, 400, 'Play', function()
    ChangeScene(Screens.game)
  end)
end

local i = 0.0

function MenuScene:update(dt)
  i = i + dt
  if startButton then startButton:update() end
end

function MenuScene:draw()
  love.graphics.setColor(Palette.white)
  local font = GameData.resources:setDefaultFont('outfit_title_bold')
  if font then
    CenteredText('FLAVORFALL', -1, -1, font, 0, -64)
  end
  local bold = GameData.resources:setDefaultFont('outfit_bold')
  if bold then
    CenteredText('LOVE Jam 2025', -1, love.graphics.getHeight() - 64, bold, 0, 0)
  end
  if startButton then startButton:draw() end
end

function MenuScene:mousepressed(x, y, button)

end

function MenuScene:mousereleased(x, y, button)
  if button == 1 then
  end
end

return MenuScene
