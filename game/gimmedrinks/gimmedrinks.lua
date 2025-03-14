local Drink = require('game.drinks.drink')
local vector = require('gimmedrinks.utils.vector')

local gimmedrinks = {
  drinks = {},
  resources = nil
}

local DRINKS_COUNT = 48
local GRID_WIDTH = 6

function gimmedrinks.load()
  local spacing = 100
  for i = 0, DRINKS_COUNT, 1 do
    local drink = Drink.new(i%GRID_WIDTH * spacing, math.floor(i/GRID_WIDTH) * spacing)
    table.insert(gimmedrinks.drinks, drink)
  end
end

function gimmedrinks.draw()
  love.graphics.setColor(1.0, 0.0, 0.0);

  for _, drink in ipairs(gimmedrinks.drinks) do
    drink:draw()
  end

end

function gimmedrinks.update(dt)
  for _, drink in ipairs(gimmedrinks.drinks) do
    drink:update(dt)
  end
end

function love.mousepressed(x, y, button)
  for _, drink in ipairs(gimmedrinks.drinks) do
    if vector.distance(x, y, drink.position.x, drink.position.y) < 30 then
      drink.velocity.x = love.math.random(-10, 10)
      drink.velocity.y = -10
      drink.enabled = true
    end
  end
end

return gimmedrinks
