---@alias DrinkType "plain" | "sparkling" | "soda" | "smoothie"
---@alias DrinkColor "clear" | "orange" | "green" | "red"

---@class DrinkData
---@field name string
---@field type DrinkType
---@field color DrinkColor
---@field price number
---@field baseScore number
---@field fuel number
---@field speed number
---@field minLevel? number

---@type table<string, DrinkData>
local DRINKS_DATA = {
  -- WATERS
  stillWater = {
    name = "Still Water",
    type = 'plain',
    color = 'clear',
    baseScore = 10,
    speed = 2,
    fuel = 0,
    price = 2,
  },
  mintWater = {
    name = "Mint Water",
    type = 'plain',
    color = 'green',
    baseScore = 12,
    fuel = 0,
    price = 3,
    speed = 2,
  },
  orangeWater = {
    name = "Orange Water",
    type = 'plain',
    color = 'orange',
    baseScore = 15,
    fuel = 0,
    price = 3,
    speed = 2,
  },
  hibiscusWater = {
    name = "Hibiscus",
    type = 'plain',
    color = 'red',
    baseScore = 25,
    fuel = 0,
    price = 4,
    speed = 3,
    minLevel = 2
  },
  -- SPARKLINGS
  sparklingWater = {
    name = "Sparkling Water",
    type = 'sparkling',
    color = 'clear',
    baseScore = 20,
    fuel = 50,
    price = 3,
    speed = 4,
  },
  sparklingApple = {
    name = "Apple Sparkling",
    type = 'sparkling',
    color = 'green',
    baseScore = 25,
    fuel = 60,
    price = 4,
    speed = 4,
  },
  sparklingOrange = {
    name = "Sparkling Orange",
    type = 'sparkling',
    color = 'orange',
    baseScore = 30,
    fuel = 65,
    price = 4,
    speed = 4,
    minLevel = 2,
  },
  sparklingRaspberry = {
    name = "Sparkling Raspberry",
    type = 'sparkling',
    color = 'red',
    baseScore = 50,
    fuel = 75,
    price = 5,
    speed = 4,
    minLevel = 3
  },
  -- SMOOTHIES
  cocoSmoothie = {
    name = "Coco Smoothie",
    type = 'smoothie',
    color = 'clear',
    baseScore = 50,
    fuel = 0,
    price = 5,
    speed = 6,
    minLevel = 3,
  },
  mangoSmoothie = {
    name = "Mango Smoothie",
    type = 'smoothie',
    color = 'orange',
    baseScore = 60,
    fuel = 0,
    price = 5,
    speed = 6,
    minLevel = 3,
  },
  kiwiSmoothie = {
    name = "Kiwi Smoothie",
    type = 'smoothie',
    color = 'green',
    baseScore = 70,
    fuel = 0,
    price = 6,
    speed = 6,
    minLevel = 4,
  },
  berrySmoothie = {
    name = "Berry Smoothie",
    type = 'smoothie',
    color = 'red',
    fuel = 0,
    baseScore = 100,
    price = 7,
    speed = 6,
    minLevel = 5
  },

  -- SODAS
  -- crystalSoda = {
  --   name = "Sparkling Water",
  --   type = 'sparkling',
  --   color = 'clear',
  --   baseScore = 20,
  --   fuel = 10,
  --   price = 2,
  --   speed = 0,
  -- },
  -- citrusSoda = {
  --   name = "Citrus Soda",
  --   type = 'soda',
  --   color = 'orange',
  --   baseScore = 15,
  --   fuel = 0,
  --   price = 2,
  --   speed = 0,
  -- },
  -- mintSoda = {
  --   name = "Mint Soda",
  --   type = 'soda',
  --   color = 'green',
  --   baseScore = 15,
  --   fuel = 0,
  --   price = 2,
  --   speed = 0,
  -- },
  -- pomegranateSoda = {
  --   name = "Pomegranate Soda",
  --   type = 'soda',
  --   color = 'red',
  --   baseScore = 15,
  --   fuel = 75,
  --   price = 5,
  --   speed = 3,
  --   minLevel = 2
  -- },
}

return DRINKS_DATA
