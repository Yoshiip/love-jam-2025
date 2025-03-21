---@class ResourceManager
---@field resources table
---@field loadErrors table
local ResourceManager = {}
ResourceManager.__index = ResourceManager


local RESOURCE_PATHS = {
  textures = {
    background = 'Gimmedrinks/images/background.jpg',
    vendingMachine = 'Gimmedrinks/images/vending_machine.png',
    slot = 'Gimmedrinks/images/slot.png',
    -- DRINKS
    drinkWater = 'Gimmedrinks/images/drinks/drink.png',
    orangeSoda = 'Gimmedrinks/images/drinks/drink.png',
    orangeWater = 'Gimmedrinks/images/drinks/drink.png',
    sparklingWater = 'Gimmedrinks/images/drinks/drink.png',
    stillWater = 'Gimmedrinks/images/drinks/drink.png',

  },
  fonts = {
    outfit = {
      path = 'Gimmedrinks/fonts/Outfit-VariableFont_wght.ttf',
      size = 32,
    },
  }
}

---Creates a new ResourceManager
function ResourceManager.new()
  local self = setmetatable({}, ResourceManager)
  self.resources = {
    textures = {},
    fonts = {}
  }
  self.loadErrors = {}
  return self
end

---Loads a texture from path with error handling
---@param name string Resource name
---@param path string Path to the texture file
---@return love.Image|nil texture The loaded texture or nil if loading failed
local function loadTexture(name, path)
  local success, result = pcall(function()
      return love.graphics.newImage(path)
  end)

  if success then
    return result
  else
    print("Error loading texture '" .. name .. "': " .. tostring(result))
    return nil
  end
end

function ResourceManager:loadTextures()
    local textures = {}
    for name, path in pairs(RESOURCE_PATHS.textures) do
      textures[name] = loadTexture(name, path)
    end

    self.resources.textures = textures
    return textures
end

---Loads all fonts defined in RESOURCE_PATHS.fonts
---@return table<string, love.Font> The loaded fonts
function ResourceManager:loadFonts()
  local fonts = {}

  for name, config in pairs(RESOURCE_PATHS.fonts) do
    local success, result = pcall(function()
      return love.graphics.newFont(config.path, config.size)
    end)

    if success then
      fonts[name] = result
    else
      print("Error loading font '" .. name .. "': " .. tostring(result))
      fonts[name] = love.graphics.getFont() -- Use default font as fallback
    end
  end

  self.resources.fonts = fonts
  return fonts
end

function ResourceManager:loadAll()
  self:loadTextures()
  self:loadFonts()
  return self
end

---Gets a loaded texture resource by name
---@param name string Name of the texture
---@return love.Image|nil texture The requested texture or nil if not found
function ResourceManager:getTexture(name)
  return self.resources.textures[name]
end

---Gets a loaded font resource by name
---@param name string Name of the font
---@return love.Font|nil font The requested font or nil if not found
function ResourceManager:getFont(name)
  return self.resources.fonts[name]
end

---Sets the default font to the specified font
---@param name string Name of the font to set as default
function ResourceManager:setDefaultFont(name)
  local font = self:getFont(name)
  if font then
    love.graphics.setFont(font)
  end
end

return ResourceManager
