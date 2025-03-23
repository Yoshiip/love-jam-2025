require "flavorfall.utils.color"
require "flavorfall.palette"

Phase = {
  BUY = 1,
  SELECT_DRINK = 2,
  SIMULATION = 3,
  END = 3
}

---@class Combo
---@field value number
---@field timeLeft number
---@field maxTimeLeft number
---@field strength number
---@field label string

---@class GameData
---@field drinks Drink[]
---@field slots Slot[]
---@field hoveredSlot Slot?
---@field mainDrink Drink?
---@field resources ResourceManager?
---@field lastDrinkColor DrinkColor
---@field lastDrinkType DrinkType
---@field combos table<string, Combo>
GameData = {
  slots = {},
  drinks = {},
  phase = Phase.SELECT_DRINK,
  level = 0,
  objective = 100,
  combos = {
    default = {
      label = 'Default',
      maxTimeLeft = 6,
      strength = 0.2,
      timeLeft = 0,
      value = 0,
    },
    sameColor = {
      label = 'Same Color',
      maxTimeLeft = 10,
      strength = 0.3,
      timeLeft = 0,
      value = 0,
    },
    sameType = {
      label = 'Same Type',
      maxTimeLeft = 10,
      strength = 0.5,
      timeLeft = 0,
      value = 0,
    },
    turn = {
      label = '360',
      strength = 5,
      maxTimeLeft = 10,
      timeLeft = 0,
      value = 0,
    },
    bounce = {
      label = 'Bounce',
      strength = 5,
      maxTimeLeft = 10,
      timeLeft = 0,
      value = 0,
    },
  },
  score = 0,
  money = 0,
  hoveredSlot = nil,
  mainDrink = nil,
  resources = nil
}

local ResourceManager = require('flavorfall.utils.resource_manager')
local MenuScene = require("flavorfall.scenes.menu_scene")
local GameScene = require("flavorfall.scenes.game_scene")
local ResultsScene = require("flavorfall.scenes.results_scene")
local EndScene = require("flavorfall.scenes.end_scene")

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
  ResultsScene:new(),
  EndScene:new()
}



---@return Scene | GameScene
function GetScene()
  return Scenes[CurrentScreen]
end

---@param scene_id number
function ChangeScene(scene_id)
  CurrentScreen = scene_id
  GetScene():start()
end

MachineCanvas = love.graphics.newCanvas()



function LoadGame()
  GameData.resources = ResourceManager.new():loadAll()
  GameData.resources:setDefaultFont('outfit_medium')
  ChangeScene(Screens.game)
end

local squareBg = { x = 0, y = 0 }
local SQUARE_SIZE = 80

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

  love.graphics.setColor(ColorWithAlpha(Palette.darkPurpleBlack, 0.3))
  for x = -2, math.ceil(love.graphics.getWidth() / SQUARE_SIZE), 1 do
    for y = -2, math.ceil(love.graphics.getHeight() / SQUARE_SIZE), 1 do
      if x % 2 == y % 2 then
        love.graphics.rectangle("fill", x * SQUARE_SIZE + squareBg.x, y * SQUARE_SIZE + squareBg.y, SQUARE_SIZE,
          SQUARE_SIZE)
      end
    end
  end
end
function DrawGame()
  love.graphics.setBackgroundColor(HexToRGBA("#4D65B4"))
  drawBackground()

  GetScene():draw()
end

function UpdateGame(dt)
  GetScene():update(dt)

  squareBg.x = squareBg.x + dt * 4
  squareBg.y = squareBg.y + dt * 4
  if squareBg.x > SQUARE_SIZE then
    squareBg = { x = 0, y = 0 }
  end
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
  GetScene():mousereleased(x, y, button)
end

function love.mousepressed(x, y, button)
  GetScene():mousepressed(x, y, button)
end

function Keypressed(key)
  GetScene():keypressed(key)
end
