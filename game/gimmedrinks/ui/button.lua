---@class Button
---@field gText? love.Text
---@field onClick function?
local Button = {
  position = { x = 0, y = 0 },
  size = { x = 0, y = 0 },
  hovered = false,
  pressed = false,
  onClick = nil,
  text = '',
}


Button.__index = Button

function Button.new(x, y, text, onClickCallback)
  local self = setmetatable({}, Button)
  self.position = { x = x, y = y }
  self.onClick = onClickCallback or function() end
  local font = GameData.resources:getFont('outfit_medium')
  if font == nil then
    return
  end
  self.text = text
  love.graphics.setFont(font)
  self.gText = love.graphics.newText(font, text)
  self.size = {
    x = self.gText:getWidth() + 8,
    y = self.gText:getHeight() + 8
  }
  return self
end

function Button:draw()
  local x, y = self.position.x, self.position.y
  if self.pressed then
    love.graphics.setColor(Palette.skyBlue)
  elseif self.hovered then
    love.graphics.setColor(Palette.navyBlue)
  else
    love.graphics.setColor(Palette.white)
  end

  love.graphics.rectangle("fill", x, y, self.size.x, self.size.y, 4, 4)
  if self.hovered then
    love.graphics.setColor(Palette.cornflowerBlue)
  else
    love.graphics.setColor(Palette.darkPurpleBlack)
  end
  love.graphics.draw(self.gText, x + 4, y + 4)
end

function Button:update()
  local x, y = self.position.x, self.position.y
  local mx, my = love.mouse.getPosition()
  local width, height = self.gText:getDimensions()
  local hoveredNow = mx >= x and mx <= x + width and my >= y and my <= y + height

  self.hovered = hoveredNow

  if hoveredNow and love.mouse.isDown(1) and not self.pressed then
    self.pressed = true
    self.onClick()
  elseif not love.mouse.isDown(1) then
    self.pressed = false
  end
end

return Button
