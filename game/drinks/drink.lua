local Drink = {}
Drink.__index = Drink


function Drink.new(x, y)
  local self = setmetatable({}, Drink)
  self.position = {x = x, y = y}
  self.enabled = false
  self.velocity = {x = 0, y = 0}
  return self
end

function Drink:update(dt)
  if self.enabled then
    self.position.x = self.position.x + self.velocity.x
    self.position.y = self.position.y + self.velocity.y
    self.velocity.x = self.velocity.x - self.velocity.x * dt
    self.velocity.y = self.velocity.y + 9.8 * dt
  end
end

function Drink:draw()
  love.graphics.circle("fill", self.position.x, self.position.y, 32)
end

return Drink
