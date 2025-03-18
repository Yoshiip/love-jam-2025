local function collisionRectangleRectangle()
  -- etc...
end

local function collisionCircleRectangle(cx, cy, r, rx, ry, rw, rh)
  local testX = cx;
  local testY = cy;

  if (cx < rx) then
    testX = rx
  elseif (cx > rx + rw) then
    testX = rx + rw
  end
  if (cy < ry) then
    testY = ry
  elseif (cy > ry + rh) then
    testY = ry + rh
  end

  local distX = cx - testX;
  local distY = cy - testY;
  local distance = math.sqrt((distX * distX) + (distY * distY));

  if distance <= r then
    return true;
  end
  return false;
end

---@type table<function, function>
local collision = {
  collisionCircleRectangle = collisionCircleRectangle,
}

return collision
