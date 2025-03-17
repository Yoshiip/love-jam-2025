--- lerp between two values
---@param a number
---@param b number
---@param t number
---@return number
function Lerp(a, b, t)
  t = math.max(0, math.min(1, t))
  return a * (1 - t) + b * t
end

--- lerp between two colors
---@param color1 number[]
---@param color2 number[]
---@param t number
---@return number[]
function LerpColor(color1, color2, t)
  return {
      Lerp(color1[1], color2[1], t),
      Lerp(color1[2], color2[2], t),
      Lerp(color1[3], color2[3], t),
      Lerp(color1[4] or 1, color2[4] or 1, t)
  }
end
