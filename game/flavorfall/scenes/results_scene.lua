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
  love.graphics.print('Click to go to next day...', 32, 32)
end

function ResultsScene:mousepressed(x, y, button)
  if button == 1 then
    ChangeScene(Screens.game)
  end
end

function ResultsScene:mousereleased(x, y, button)
  if button == 1 then
  end
end

return ResultsScene
