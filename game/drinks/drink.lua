require 'Gimmedrinks.utils.math'
local collision = require 'gimmedrinks.utils.collisions'

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
  main = false,
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
  self.position = { x = x, y = y }
  self.velocity = { x = 0, y = 0 }
  return self
end

function Drink:update(dt)
  local x, y = self.position.x, self.position.y
  if self.enabled then
    if love.keyboard.isDown("left") then
      self.rotation = self.rotation - dt
    elseif love.keyboard.isDown("right") then
      self.rotation = self.rotation + dt
    end
    self.rotation = self.rotation % 360
    print(self.rotation)
    if love.keyboard.isDown('space') and self.carbonLeft > 0 then
      local dir = {
        x = math.cos(math.rad(self.rotation)),
        y = math.sin(math.rad(self.rotation)),
      }

      self.velocity.x = self.velocity.x + dir.x * 5 * dt
      self.velocity.y = self.velocity.y + dir.y * 5 * dt
      self.carbonLeft = self.carbonLeft - dt * 5
    end

    self.position.x = x + self.velocity.x
    self.position.y = y + self.velocity.y
    self.velocity.x = self.velocity.x - self.velocity.x * dt
    self.velocity.y = self.velocity.y + 9.8 * dt
  end

  if self.position.x < 16 and self.velocity.x < 0 then
    self.velocity.x = -self.velocity.x
  elseif self.position.x > MachineInnerSize.x - 16 and self.velocity.x > 0 then
    self.velocity.x = -self.velocity.x
  end
  self.rotation = self.rotation + self.velocity.x * 0.3 * dt
  if self.position.y > MachineInnerSize.y then
    GameData.score = GameData.score + 5
    if self.main then
      GetScene():mainFalled()
    end
    self:remove()
  end
  if self.enabled and not self.stuck then
    for _, drink in pairs(GameData.drinks) do
      if drink.stuck and collision.collisionCircleRectangle(drink.position.x, drink.position.y, 32, x, y, 128, 256) then
        self.velocity.y = -5
        self.velocity.x = -5
        drink.enabled = true
      end
    end
  end
end

function Drink:remove()
  if self.slot ~= nil then
    table.remove(self.slot.drinks, IndexOf(self.slot.drinks, self))
  end
  table.remove(GameData.drinks, IndexOf(GameData.drinks, self))
end

function Drink:draw()
  local color = LerpColor(Palette.white, { 0.5, 0.5, 0.5, 1.0 }, self.order / 3)
  love.graphics.setColor(color)
  local scale = Lerp(0.25, 0.20, self.order / 3)
  local x, y = self.position.x, self.position.y
  x = x - (scale - 0.25) * 72
  local texture = GameData.resources:getTexture(self.id)
  if texture == nil then
    return
  end
  if self.stuck then
    love.graphics.draw(texture, self.stuckQuad, x, y + 96, 0, scale, scale)
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
