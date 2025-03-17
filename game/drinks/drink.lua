require 'Gimmedrinks.utils.math'

---@class Drink
---@field slot Slot
local Drink = {
  id = "",
  position = { x = 0, y = 0 },
  sparkling = false,
  carbonLeft = 100,
  rotation = 0,
  defaultQuad = love.graphics.newQuad(0, 0, 256, 512, 512, 512),
  stuckQuad = love.graphics.newQuad(256, 0, 256, 256, 512, 512),
  enabled = false,
  stuck = false,
  order = 0,
  velocity = { x = 0, y = 0 }
}
Drink.__index = Drink
---@return Drink
function Drink.new(x, y, id)
  local self = setmetatable({}, Drink)
  self.id = id
  self.position = {x = x, y = y}
  self.velocity = {x = 0, y = 0}
  return self
end

function Drink:update(dt)
  if self.enabled then
    if love.keyboard.isDown("left") then
      self.rotation = self.rotation - dt
    elseif love.keyboard.isDown("right") then
      self.rotation = self.rotation + dt
    end
    if love.keyboard.isDown('space') and self.carbonLeft > 0 then
      self.velocity.y = -20 * dt
      self.carbonLeft = self.carbonLeft - dt * 5
    end
    self.position.x = self.position.x + self.velocity.x
    self.position.y = self.position.y + self.velocity.y
    self.velocity.x = self.velocity.x - self.velocity.x * dt
    self.velocity.y = self.velocity.y + 9.8 * dt
  end
end

function Drink:draw()
  local color = LerpColor(Palette.white, {0.5, 0.5, 0.5, 1.0}, self.order / 3)
  love.graphics.setColor(color)
  local scale = Lerp(0.25, 0.20, self.order / 3)
  local x, y = self.position.x, self.position.y
  x = x - (scale - 0.25) * 72
  local texture = GameData.resources:getTexture(self.id)
  if texture == nil then
    return
  end
  if self.stuck then
    love.graphics.draw(texture, self.stuckQuad, x, y - 128, 0, scale, scale)
  else
    love.graphics.draw(texture, self.defaultQuad, x, y + 64, self.rotation, scale, scale)
  end

  love.graphics.setColor(Palette.darkRed)
  love.graphics.setLineWidth(3)
  if self.stuck then
    love.graphics.rectangle("line", x, y + 64, 64, 64)

  else
    love.graphics.rectangle("line", x, y + 64, 64, 128)
  end
  love.graphics.setColor(Palette.white)
end
return Drink

