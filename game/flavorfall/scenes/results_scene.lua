local Scene = require "flavorfall.scenes.scene"

local ResultsScene = {}
ResultsScene.__index = ResultsScene
setmetatable(ResultsScene, { __index = Scene })

function ResultsScene:new()
  return self
end

function ResultsScene:update()

end

function ResultsScene:draw()
  love.graphics.setColor(Palette.darkPurpleBlack)
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  local font = GameData.resources:setDefaultFont('outfit_title_bold')
  if font then
    love.graphics.setColor(Palette.white)
    if GameData.level == 6 then
      CenteredText('Congratulations!', -1, -1, font, 0, 0)
    else
      CenteredText('Click to go to next day...', -1, -1, font, 0, 0)
    end
  end
end

function ResultsScene:mousepressed(x, y, button)
  if button == 1 then
    if GameData.level < 6 then
      GameData.level = GameData.level + 1
      ChangeScene(Screens.game)
    end
  end
end

function ResultsScene:mousereleased(x, y, button)
  if button == 1 then
  end
end

return ResultsScene
