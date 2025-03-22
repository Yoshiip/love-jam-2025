require 'Gimmedrinks.utils.math'
local collision = require 'gimmedrinks.utils.collisions'
local vector = require 'gimmedrinks.utils.vector'

---@class Drink
---@field slot Slot
local Drink = {
  id = "",
  position = { x = 0, y = 0 },
  sparkling = false,
  carbonLeft = 100,
  rotation = 0,
  angularVelocity = 0,
  angularAcceleration = 0,
  defaultQuad = love.graphics.newQuad(0, 0, 128, 256, 256, 256),
  stuckQuad = love.graphics.newQuad(128, 0, 128, 128, 256, 256),
  main = false,
  enabled = false,
  stuck = false,
  order = 0,
  velocity = { x = 0, y = 0 }
}
Drink.__index = Drink

local GRAVITY = 7.0

---@return Drink
function Drink.new(x, y, id)
  local self = setmetatable({}, Drink)
  self.id = id
  self.position = { x = x, y = y }
  self.velocity = { x = 0, y = 0 }
  self.rotation = 0
  self.carbonLeft = 100
  self.angularVelocity = 0
  self.angularAcceleration = 0
  return self
end

local COLLISION_RADIUS = 80

---@return number, number
function Drink:center()
  if self.stuck then
    return self.position.x + 32, self.position.y + 128
  else
    return self.position.x + 32, self.position.y + 96
  end
end

function Drink:handleCollisions()
  if self.enabled and not self.stuck then
    local x, y = self:center()
    for _, drink in pairs(GameData.drinks) do
      local ox, oy = drink:center()
      if drink.stuck and not drink.enabled and collision.collisionCircleRectangle(ox, oy, COLLISION_RADIUS, x, y, 128, 128) then
        local impactX = x - ox
        local impactStrength = Clamp(impactX, -5, 5)
        self.velocity.y = -5
        self.velocity.x = impactStrength
        self.angularVelocity = self.angularVelocity + impactStrength * 0.1
        drink:detach()
      end
    end
  end
end

function Drink:detach()
  self.enabled = true
  self.slot:detached(self)
end

function Drink:update(dt)
  if self.enabled then
    local ANGULAR_ACCEL = 360
    if love.keyboard.isDown("left") then
      self.angularAcceleration = self.angularAcceleration - ANGULAR_ACCEL
    elseif love.keyboard.isDown("right") then
      self.angularAcceleration = self.angularAcceleration + ANGULAR_ACCEL
    end

    if love.keyboard.isDown('space') and self.carbonLeft > 0 then
      local propulsionAngle = math.rad(self.rotation + 90)
      local dir = {
        x = math.cos(propulsionAngle),
        y = math.sin(propulsionAngle)
      }
      local propulsionStrength = 18
      self.velocity.x = self.velocity.x + dir.x * propulsionStrength * dt
      self.velocity.y = self.velocity.y + dir.y * propulsionStrength * dt
      self.carbonLeft = self.carbonLeft - dt * 5
    end

    self.angularVelocity = self.angularVelocity + self.angularAcceleration * dt
    local ANGULAR_DAMPING = 1
    self.angularVelocity = self.angularVelocity * (1 - ANGULAR_DAMPING * dt)
    self.rotation = (self.rotation + self.angularVelocity * dt) % 360
    self.angularAcceleration = 0

    self.position.x = self.position.x + self.velocity.x
    self.position.y = self.position.y + self.velocity.y
    self.velocity.x = self.velocity.x - self.velocity.x * dt
    self.velocity.y = self.velocity.y + GRAVITY * dt
  end

  if self.position.x < 16 and self.velocity.x < 0 then
    self.velocity.x = -self.velocity.x
    self.angularVelocity = self.angularVelocity + 5
  elseif self.position.x > MachineInnerSize.x - 16 and self.velocity.x > 0 then
    self.velocity.x = -self.velocity.x
    self.angularVelocity = self.angularVelocity - 5
  end

  if self.position.y > MachineInnerSize.y + 200 then
    GetScene():drinkFalled(self)
    self:remove()
  end

  self:handleCollisions()
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
  local scale = Lerp(0.8, 0.50, self.order / 3)
  local x, y = self.position.x, self.position.y
  -- x = x - (scale - 0.25) * 72
  local texture = GameData.resources:getTexture(self.id)
  if texture == nil then
    return
  end
  local cx, cy = self:center()
  if self.stuck then
    love.graphics.draw(texture, self.stuckQuad, cx, cy, 0, scale, scale, 64, 64)
  else
    if self.enabled then
      love.graphics.setColor(Palette.white)
    elseif GameData.phase == Phase.SIMULATION then
      love.graphics.setColor(0.5, 0.5, 0.5)
    else
      love.graphics.setColor(0.7, 0.7, 0.7)
    end

    love.graphics.draw(texture, self.defaultQuad, cx, cy, math.rad(self.rotation), scale, scale, 64, 128)
    love.graphics.setColor(Palette.white)
  end

  love.graphics.setColor(Palette.darkRed)
  love.graphics.setLineWidth(3)
  if self.stuck then
    -- love.graphics.circle("fill", x + 32, y + 128, COLLISION_RADIUS)
  else
    love.graphics.rectangle("line", x, y + 64, 64, 128)
  end
  love.graphics.setColor(Palette.white)
end

return Drink
