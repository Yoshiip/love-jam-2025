function HexToRGBA(hex)
  hex = hex:gsub("#", "")
  local r, g, b, a = 255, 255, 255, 255

  if #hex == 6 then
      r, g, b = tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16)
  elseif #hex == 8 then
      r, g, b, a = tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16), tonumber(hex:sub(7,8), 16)
  else
      error("Format hex invalide. Utiliser #RRGGBB ou #RRGGBBAA")
  end

  return r / 255, g / 255, b / 255, a / 255
end
