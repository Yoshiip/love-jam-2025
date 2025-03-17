---@class DrinkData
---@field name string
---@field sparkling boolean
---@field price number
---@field baseCarbon number?
---@field rarity number

---@type table<string, DrinkData>
local DRINKS_DATA = {
  stillWater = {
    name = "Still Water",
    sparkling = false,
    price = 2,
    rarity = 0,
  },
  sparklingWater = {
    name = "Sparkling Water",
    sparkling = true,
    price = 2,
    rarity = 0,
  },
  mintWater = {
    name = "Still Water",
    sparkling = false,
    price = 2,
    rarity = 0,
  },
  orangeWater = {
    name = "Still Water",
    sparkling = false,
    price = 2,
    rarity = 0,
  },
  orangeSoda = {
    name = "Orange Soda",
    sparkling = true,
    price = 2,
    rarity = 0,
  }
}

return DRINKS_DATA
