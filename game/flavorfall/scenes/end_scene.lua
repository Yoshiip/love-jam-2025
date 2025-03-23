local Scene = require("flavorfall.scenes.scene")

local EndScene = {}
EndScene.__index = EndScene
setmetatable(EndScene, { __index = Scene })

function EndScene:new()
  return self
end

function EndScene:update()

end

function EndScene:draw()
end

function EndScene:mousepressed(x, y, button)

end

function EndScene:mousereleased(x, y, button)
  if button == 1 then
  end
end

return EndScene
