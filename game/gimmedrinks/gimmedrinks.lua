require "Gimmedrinks.utils.color"
require "gimmedrinks.palette"

Phase = {
  BUY = 1,
  SELECT_DRINK = 2,
  SIMULATION = 3,
  END = 3
}

---@class GameData
---@field drinks Drink[]
---@field slots Slot[]
---@field hoveredSlot Slot?
---@field resources ResourceManager?
GameData = {
  slots = {},
  drinks = {},
  phase = Phase.BUY,
  level = 0,
  score = 0,
  combo = 0,
  money = 10,
  hoveredSlot = nil,
  resources = nil
}

local ResourceManager = require('Gimmedrinks.utils.resource_manager')
local MenuScene = require "game.scenes.menu_scene"
local GameScene = require "game.scenes.game_scene"
local EndScene = require "game.scenes.end_scene"

local CurrentScreen = 1

Screens = {
  menu = 1,
  game = 2,
  results = 3,
  gameOver = 4,
}

---@type Scene[]
local Scenes = {
  MenuScene:new(),
  GameScene:new(),
  EndScene:new()
}



local function getScene()
  return Scenes[CurrentScreen]
end



---@param scene_id number
function ChangeScene(scene_id)
  CurrentScreen = scene_id
  getScene():start()
end

MachineCanvas = love.graphics.newCanvas()

function ScreenToMachineCanvas(x, y)
  local vendingMachine = GameData.resources:getTexture('vendingMachine')
  if vendingMachine == nil then
    return 0, 0
  end
  return x - 311, y - 63
end

function LoadGame()
  GameData.resources = ResourceManager.new():loadAll()
  GameData.resources:setDefaultFont('outfit_medium')
  ChangeScene(Screens.menu)
end

local function drawBackground()
  love.graphics.setColor(1.0, 1.0, 1.0)
  local bg = GameData.resources:getTexture('background')
  if bg == nil then
    return
  end

  local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
  local imgW, imgH = bg:getWidth(), bg:getHeight()
  local scale = math.max(screenW / imgW, screenH / imgH)
  local offsetX = (screenW - imgW * scale) / 2
  local offsetY = (screenH - imgH * scale) / 2
  love.graphics.draw(bg, offsetX, offsetY, 0, scale, scale)
end
function DrawGame()
  love.graphics.setBackgroundColor(HexToRGBA("#4D65B4"))
  drawBackground()

  getScene():draw()
end

function UpdateGame(dt)
  getScene():update(dt)
end

--- get index of item in list
---@generic T
---@param array T[]
---@param value T
---@return integer|nil
function IndexOf(array, value)
  for i, v in ipairs(array) do
    if v == value then
      return i
    end
  end
  return nil
end

function love.mousereleased(x, y, button)
  getScene():mousereleased(x, y, button)
end

function love.mousepressed(x, y, button)
  getScene():mousepressed(x, y, button)
end
