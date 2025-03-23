---@class ResourceManager
---@field resources table
---@field loadErrors table
local ResourceManager = {}
ResourceManager.__index = ResourceManager

---@alias FontName
---| '"outfit_title_bold"'
---| '"outfit_bold"'
---| '"outfit_medium"'
---| '"outfit_regular"'
---| '"lcd"'

local RESOURCE_PATHS = {
  textures = {
    background = 'flavorfall/images/background.jpg',
    vendingMachine = 'flavorfall/images/vending_machine.png',
    pushDecoration = 'flavorfall/images/push_decoration.png',
    rightDecoration = 'flavorfall/images/right_decoration.png',
    slot = 'flavorfall/images/slot.png',
    -- DRINKS
    hibiscusWater = 'flavorfall/images/drinks/hibiscusWater.png',
    mintWater = 'flavorfall/images/drinks/mintWater.png',
    orangeSoda = 'flavorfall/images/drinks/orangeSoda.png',
    orangeWater = 'flavorfall/images/drinks/orangeWater.png',
    stillWater = 'flavorfall/images/drinks/stillWater.png',
    sparklingApple = 'flavorfall/images/drinks/sparklingApple.png',
    sparklingOrange = 'flavorfall/images/drinks/sparklingOrange.png',
    sparklingRaspberry = 'flavorfall/images/drinks/sparklingRaspberry.png',
    sparklingWater = 'flavorfall/images/drinks/sparklingWater.png',
  },
  musics = {
    ingame = 'flavorfall/musics/music.mp3'
  },
  sounds = {
    fuel = 'flavorfall/sfx/fuel.mp3',
    coin = 'flavorfall/sfx/coin.mp3',
    impact_metal = 'flavorfall/sfx/impact_metal.mp3',
  },
  fonts = {
    outfit_title_bold = {
      path = 'flavorfall/fonts/outfit_bold.ttf',
      size = 48,
    },
    outfit_bold = {
      path = 'flavorfall/fonts/outfit_bold.ttf',
      size = 32,
    },
    outfit_medium = {
      path = 'flavorfall/fonts/outfit_medium.ttf',
      size = 28,
    },
    outfit_regular = {
      path = 'flavorfall/fonts/outfit_regular.ttf',
      size = 24,
    },
    lcd = {
      path = 'flavorfall/fonts/lcd.otf',
      size = 32,
    }

  }
}

---Creates a new ResourceManager
function ResourceManager.new()
  local self = setmetatable({}, ResourceManager)
  self.resources = {
    textures = {},
    fonts = {},
    audios = {},
    musics = {}
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

---@return table<string, love.Source> The loaded audio
function ResourceManager:loadAudios()
  local audios = {}

  for name, path in pairs(RESOURCE_PATHS.sounds) do
    local success, result = pcall(function()
      return love.audio.newSource(path, "static")
    end)


    if success then
      audios[name] = result
    else
      print("Error loading audio '" .. name .. "': " .. tostring(result))
    end
  end

  self.resources.audios = audios
  return audios
end

---@return table<string, love.Source> The loaded audio
function ResourceManager:loadMusics()
  local musics = {}

  for name, path in pairs(RESOURCE_PATHS.musics) do
    local success, result = pcall(function()
      return love.audio.newSource(path, "stream")
    end)


    if success then
      musics[name] = result
    else
      print("Error loading audio '" .. name .. "': " .. tostring(result))
    end
  end

  self.resources.musics = musics
  return musics
end

function ResourceManager:loadAll()
  self:loadTextures()
  self:loadAudios()
  self:loadMusics()
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
---@param name FontName Name of the font
---@return love.Font|nil font The requested font or nil if not found
function ResourceManager:getFont(name)
  return self.resources.fonts[name]
end

---@return love.Source|nil audio
function ResourceManager:getAudio(name)
  return self.resources.audios[name]
end

---@return love.Source|nil audio
function ResourceManager:getMusic(name)
  return self.resources.musics[name]
end

---Sets the default font to the specified font
---@param name FontName Name of the font to set as default
---@return love.Font|nil font The requested font or nil if not found
function ResourceManager:setDefaultFont(name)
  local font = self:getFont(name)
  if font then
    love.graphics.setFont(font)
  end
  return font
end

function ResourceManager:playAudio(name)
  local source = GameData.resources:getAudio(name)
  if source then
    love.audio.play(source)
  end
end

return ResourceManager
