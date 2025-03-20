local Drink = require "game.drinks.drink"

---@class Slot
---@field drinks Drink[]
local Slot = {
  position = { x = 0, y = 0 },
  size = { x = 0, y = 0 },
  stuck = false,
  hovered = false,
  drinkId = '',
  count = 0,
}


Slot.__index = Slot


function Slot.new(x, y, drinkId, count, width, height)
  local self = setmetatable({}, Slot)
  self.drinks = {}
  self.position = { x = x, y = y }
  self.size = { x = width, y = height }
  self.drinkId = drinkId
  self.count = count


  local spacing = 12

  for i = 0, count, 1 do
    local drink = Drink.new(x + 32, y - i * spacing + 48, drinkId)
    drink.order = i
    drink.slot = self
    table.insert(GameData.drinks, drink)
    table.insert(self.drinks, drink)
  end
  return self
end

function Slot:update(dt)
end

function Slot:draw()
  local x, y = self.position.x, self.position.y
  local slotTexture = GameData.resources:getTexture('slot')
  if slotTexture == nil then
    return
  end
  love.graphics.setColor(Palette.white)
  love.graphics.draw(slotTexture, x, y)
  love.graphics.setColor(Palette.white)
  if self.hovered then
    love.graphics.setColor(Palette.white)
    love.graphics.setLineWidth(6)
    love.graphics.rectangle("line", x, y, 128 - 6, 256 - 6)
  end
end

function Slot:drawLabel()
  local x, y = self.position.x, self.position.y
  love.graphics.setColor(Palette.paleMint)
  love.graphics.rectangle("fill", x + 32, y + 160, 64, 32)
  love.graphics.setColor(Palette.darkPurpleBlack)
  love.graphics.print(self.count, x + 32, y + 160)
  love.graphics.setColor(Palette.white)
end

function Slot:isHovered()
  local px, py = self.position.x, self.position.y
  local cx, cy = ScreenToMachineCanvas(love.mouse.getX(), love.mouse.getY())
  local sx, sy = self.size.x, self.size.y

  local inside_x = cx >= px and cx <= px + sx
  local inside_y = cy >= py and cy <= py + sy

  local hovered = inside_x and inside_y
  self.hovered = hovered
  return hovered
end

function Slot:startStuck()
  self.stuck = true
  self.drinks[1].stuck = true
end

function Slot:unstuck()
  self.stuck = false
  self.drinks[1].stuck = false
end

return Slot
