---@param s string
function Capitalize(s)
  return s:sub(1, 1):upper() .. s:sub(2)
end

---@param text string
---@param x number
---@param y number
---@param font love.Font
---@param ox number
---@param oy number
function CenteredText(text, x, y, font, ox, oy)
  local cx, cy = x, y
  if x == -1 then
    cx = love.graphics.getWidth() / 2 - font:getWidth(text) / 2
  end
  if y == -1 then
    cy = love.graphics.getHeight() / 2 - font:getHeight() / 2
  end

  love.graphics.print(text, cx + ox, cy + oy)
end
