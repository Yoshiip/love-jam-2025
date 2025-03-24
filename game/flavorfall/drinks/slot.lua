local Drink = require("flavorfall.drinks.drink")
local DRinksData = require('flavorfall.drinks_data')
---@class Slot
---@field drinks Drink[]
local Slot = {
  position = { x = 0, y = 0 },
  size = { x = 0, y = 0 },
  stuck = false,
  move = false,
  hovered = false,
  drinkId = '',
}


Slot.__index = Slot


function Slot.new(x, y, drinkId, count, width, height)
  local self = setmetatable({}, Slot)
  self.drinks = {}
  self.position = { x = x, y = y }
  self.size = { x = width, y = height }
  self.drinkId = drinkId


  local spacing = 12

  if drinkId ~= '' then
    for i = 0, count, 1 do
      local drink = Drink.new(x + 32, y - i * spacing + 48, drinkId)
      drink.order = i
      drink.slot = self
      table.insert(GameData.drinks, drink)
      table.insert(self.drinks, drink)
    end
  end
  return self
end

function Slot:update(dt)
  if #self.drinks > 0 and self.stuck and self.move then
    for _, d in ipairs(self.drinks) do
      d.order = d.order - dt / DRinksData[self.drinkId].speed
    end
    if self.drinks[1].order < 0 then
      self.drinks[1].stuck = true
      self.move = false
    end
  end
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

function Slot:center()
  return self.position.x + 64, self.position.y + 128
end

function Slot:drawLabel()
  local x, y = self.position.x, self.position.y
  if #self.drinks == 0 then
    love.graphics.setColor(ColorWithAlpha(Palette.brightRed, 0.5))
  else
    love.graphics.setColor(Palette.paleMint)
  end
  love.graphics.rectangle("fill", x + 16, y + 32, 96, 32)
  love.graphics.setColor(Palette.darkPurpleBlack)
  love.graphics.print('x' .. #self.drinks, x + 48, y + 32)
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

function Slot:exploded()
  if #self.drinks > 0 then
    local drink = self.drinks[1]
    drink.stuck = false
    drink.flying = true
    drink.velocity.y = love.math.random(-2, -4)
    drink.velocity.x = love.math.random(-4, 4)
    drink.enabled = true
    self:detached(drink)
  end
end

function Slot:startStuck()
  self.stuck = true
  self.drinks[1].stuck = true
end

function Slot:unstuck()
  self.stuck = false
  self.drinks[1].stuck = false
end

---@param drink Drink
function Slot:detached(drink)
  table.remove(self.drinks, IndexOf(self.drinks, drink))
  self.move = true
end

return Slot
