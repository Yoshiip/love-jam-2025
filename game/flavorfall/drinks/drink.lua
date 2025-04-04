require('flavorfall.utils.math')
local collision = require('flavorfall.utils.collisions')
local DrinksData = require('flavorfall.drinks_data')
local vector = require('flavorfall.utils.vector')

---@class Drink
---@field slot Slot
local Drink = {
  id = "",
  position = { x = 0, y = 0 },
  sparkling = false,
  fuelLeft = 100,
  rotation = 0,
  angularVelocity = 0,
  angularAcceleration = 0,
  defaultQuad = love.graphics.newQuad(0, 0, 128, 256, 256, 256),
  stuckQuad = love.graphics.newQuad(128, 0, 128, 128, 256, 256),
  flying = false,
  main = false,
  enabled = false,
  bounceTimer = 0.0,
  stuck = false,
  order = 0,
  velocity = { x = 0, y = 0 }
}
Drink.__index = Drink

local maxParticleTimer = 0.03
local particleTimer = maxParticleTimer
local GRAVITY = 7.0

---@return Drink
function Drink.new(x, y, id)
  local self = setmetatable({}, Drink)
  self.id = id
  self.position = { x = x, y = y }
  self.velocity = { x = 0, y = 0 }
  self.rotation = 0
  self.fuelLeft = DrinksData[id].fuel
  self.angularVelocity = 0
  self.angularAcceleration = 0
  return self
end

local COLLISION_RADIUS = 32

---@return number, number
function Drink:center()
  if self.stuck then
    return self.position.x + 32, self.position.y + 128
  else
    return self.position.x + 32, self.position.y + 96
  end
end

function Drink:handleCollisions()
  if not self.flying and self.enabled and not self.stuck then
    local x, y = self:center()
    for _, drink in pairs(GameData.drinks) do
      local ox, oy = drink:center()
      if drink.stuck and not drink.enabled and collision.collisionCircleRectangle(ox, oy, COLLISION_RADIUS, x - 64, y, 128, 128) then
        local impactX = x - ox
        local impactStrength = Clamp(impactX, -5, 5)
        self.velocity.y = -5
        self.velocity.x = impactStrength
        self.angularVelocity = self.angularVelocity + impactStrength * 0.1
        GameData.resources:playAudio('impact')
        drink:detach()
      end
    end
  end
end

function Drink:detach()
  self.enabled = true
  if self.fuelLeft ~= nil then
    self.stuck = false
    self.flying = true
  end
  if DrinksData[self.id].type == 'smoothie' then
    self:explode()
  end
  self.slot:detached(self)
end

local EXPLOSION_RADIUS = 300

function Drink:explode()
  local cx, cy = self:center()
  GameData.resources:playAudio('smoothie')

  for _, slot in ipairs(GameData.slots) do
    local sx, sy = slot:center()
    if #slot.drinks > 0 and vector.distance(cx, cy, sx, sy) < EXPLOSION_RADIUS then
      slot:exploded()
    end
  end
  for i = 1, 16, 1 do
    table.insert(Particles.explosion, {
      x = cx + love.math.random(-8, 8),
      y = cy + love.math.random(-8, 8),
      time = 3,
      angle = love.math.random(0, 360),
      color = DrinkColorPalette[DrinksData[self.id].color]
    })
  end
  self:remove()
end

function Drink:bounced()
  if self.enabled and not self.flying and self.main and self.bounceTimer < 0.0 then
    AddToCombo('bounce')
    self.bounceTimer = 0.5
  end
end

function Drink:update(dt)
  if self.enabled then
    if self.main then
      local ANGULAR_ACCEL = 360
      if love.keyboard.isDown("left") then
        self.angularAcceleration = self.angularAcceleration - ANGULAR_ACCEL
      elseif love.keyboard.isDown("right") then
        self.angularAcceleration = self.angularAcceleration + ANGULAR_ACCEL
      end

      if love.keyboard.isDown('space') and self.fuelLeft > 0 then
        local propulsionAngle = math.rad(self.rotation + 90)
        local dir = {
          x = math.cos(propulsionAngle),
          y = math.sin(propulsionAngle)
        }
        local propulsionStrength = 18
        particleTimer = particleTimer - dt
        if particleTimer < 0.0 then
          local cx, cy = self:center()
          table.insert(Particles.fuel, {
            x = cx,
            y = cy,
            time = 1,
          })
          particleTimer = maxParticleTimer
        end
        self.velocity.x = self.velocity.x + dir.x * propulsionStrength * dt
        self.velocity.y = self.velocity.y + dir.y * propulsionStrength * dt
        self.fuelLeft = self.fuelLeft - dt * 10
      end
      -- elseif self.flying then
      --   if self.fuelLeft > 0 then
      --     self.velocity.y = self.velocity.y - 10 * dt
      --     self.fuelLeft = self.fuelLeft - dt * 15
      --   else
      --     self:explode()
      --   end
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

  if self.position.y < 0 then
    self.position.y = 0
    self.velocity.y = 0
  end

  self.bounceTimer = self.bounceTimer - dt
  if self.position.x < 16 and self.velocity.x < 0 then
    GameData.resources:playAudio('impact_metal')
    self.velocity.x = -self.velocity.x
    self:bounced()
    self.angularVelocity = self.angularVelocity + 5
  elseif self.position.x > MachineInnerSize.x - 16 and self.velocity.x > 0 then
    GameData.resources:playAudio('impact_metal')
    self:bounced()
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

  -- love.graphics.setColor(Palette.darkRed)
  -- love.graphics.setLineWidth(3)
  -- if self.stuck then
  --   -- love.graphics.circle("fill", x + 32, y + 128, COLLISION_RADIUS)
  -- else
  --   love.graphics.rectangle("line", x, y + 64, 64, 128)
  -- end
  love.graphics.setColor(Palette.white)
end

return Drink
