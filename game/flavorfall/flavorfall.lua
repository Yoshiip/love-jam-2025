require "flavorfall.utils.color"
require "flavorfall.palette"
local vector = require "flavorfall.utils.vector"

Phase = {
  BUY = 1,
  SELECT_DRINK = 2,
  SIMULATION = 3,
  END = 4
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
  level = 1,
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
    bounce = {
      label = 'Bounce',
      strength = 0.4,
      maxTimeLeft = 8,
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

local BACKGROUND_COLORS = {
  Palette.turquoise,
  Palette.cornflowerBlue,
  Palette.orange,
  Palette.brightOrange,
  Palette.hotPinkBright,
  Palette.dustyRose,
  Palette.darkPurple,
}

SCORE_OBJECTIVES = {
  100,
  300,
  500,
  1000,
  2500,
  5000
}

local bgColor = BACKGROUND_COLORS[1]


local ResourceManager = require('flavorfall.utils.resource_manager')
local MenuScene = require("flavorfall.scenes.menu_scene")
local GameScene = require("flavorfall.scenes.game_scene")
local EndScene = require("flavorfall.scenes.end_scene")

local CurrentScreen = 1

local mouseVelocity = { x = 0, y = 0 }

Screens = {
  menu = 1,
  game = 2,
  gameEnd = 3,
}

---@type Scene[]
local Scenes = {
  MenuScene:new(),
  GameScene:new(),
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
  ChangeScene(Screens.menu)
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
  love.graphics.setColor(bgColor)
  love.graphics.draw(bg, offsetX, offsetY, 0, scale, scale)

  love.graphics.setColor(ColorWithAlpha(Palette.darkPurpleBlack, 0.3))
  local radius = vector.length(mouseVelocity.x, mouseVelocity.y) * 3.0
  for x = -2, math.ceil(love.graphics.getWidth() / SQUARE_SIZE), 1 do
    for y = -2, math.ceil(love.graphics.getHeight() / SQUARE_SIZE), 1 do
      if x % 2 == y % 2 then
        love.graphics.rectangle("fill", x * SQUARE_SIZE + squareBg.x, y * SQUARE_SIZE + squareBg.y, SQUARE_SIZE,
          SQUARE_SIZE, radius, radius)
      end
    end
  end
end
function DrawGame()
  love.graphics.setBackgroundColor(HexToRGBA("#4D65B4"))
  drawBackground()

  GetScene():draw()
end

local lastMouse = { x = 0, y = 0 }

function UpdateGame(dt)
  GetScene():update(dt)
  bgColor = LerpColor(bgColor, BACKGROUND_COLORS[GameData.level], dt)

  mouseVelocity.x = mouseVelocity.x + (love.mouse.getX() - lastMouse.x) * dt
  mouseVelocity.y = mouseVelocity.y + (love.mouse.getY() - lastMouse.y) * dt
  lastMouse.x, lastMouse.y = love.mouse.getPosition()

  if GameData.mainDrink ~= nil then
    mouseVelocity.x = mouseVelocity.x + GameData.mainDrink.velocity.x * 2 * dt
    mouseVelocity.y = mouseVelocity.y + GameData.mainDrink.velocity.y * 2 * dt
  end
  mouseVelocity.x = Lerp(mouseVelocity.x, 0, dt)
  mouseVelocity.y = Lerp(mouseVelocity.y, 0, dt)


  squareBg.x = (squareBg.x + mouseVelocity.x * 0.2) + dt * 4
  squareBg.y = (squareBg.y + mouseVelocity.y * 0.2) + dt * 4
  squareBg.x = squareBg.x % (SQUARE_SIZE * 2)
  squareBg.y = squareBg.y % (SQUARE_SIZE * 2)
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
