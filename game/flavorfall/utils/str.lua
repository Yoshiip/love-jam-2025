---@param s string
function Capitalize(s)
  return s:sub(1, 1):upper() .. s:sub(2)
end
