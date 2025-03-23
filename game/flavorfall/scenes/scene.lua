---@class Scene
local Scene = {}
Scene.__index = Scene


function Scene:new()
  setmetatable({}, Scene)
  return self
end

function Scene:start()
end

function Scene:draw()
end

---@param dt number
function Scene:update(dt)
end

---@param key string
function Scene:keypressed(key)
end

---@param x number
---@param y number
---@param key string
function Scene:mousepressed(x, y, key)
end

---@param x number
---@param y number
---@param key string
function Scene:mousereleased(x, y, key) end

return Scene
