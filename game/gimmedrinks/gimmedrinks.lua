local Slot = require('game.drinks.slot')
local vector = require('Gimmedrinks.utils.vector')
local ResourceManager = require('Gimmedrinks.utils.resource_manager')
local DrinksData = require('Gimmedrinks.drinks_data')
local Button = require('Gimmedrinks.ui.button')
require "Gimmedrinks.utils.color"
require "gimmedrinks.palette"
local Phase = {
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

---@type Button
local startButton

local SLOTS_COUNT = 32
local GRID_WIDTH = 6
local machineCanvasOffset = { x = 0, y = 0 }

MachineCanvas = love.graphics.newCanvas()

function ScreenToMachineCanvas(x, y)
  local vendingMachine = GameData.resources:getTexture('vendingMachine')
  if vendingMachine == nil then
    return 0, 0
  end
  return x - 311, y - 63
end

function LoadGame()
  local spacing = 128
  MachineCanvas = love.graphics.newCanvas(128 * 6, 128 * 6 * 2)
  GameData.resources = ResourceManager.new():loadAll()
  GameData.resources:setDefaultFont('outfit')

  local keys = {}
  for key in pairs(DrinksData) do
    table.insert(keys, key)
  end


  for i = 0, SLOTS_COUNT do
    local x, y = i % GRID_WIDTH * spacing, math.floor(i / GRID_WIDTH) * spacing * 2
    local randomKey = keys[love.math.random(1, #keys)]
    local slot = Slot.new(x, y, randomKey, 8, 128, 256)
    table.insert(GameData.slots, slot)
  end


  startButton = Button.new(32, 32, 'Start', function()
    GameData.phase = Phase.SELECT_DRINK
  end)
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

local function drawVendingMachine()
  local vendingMachine = GameData.resources:getTexture('vendingMachine')
  if vendingMachine == nil then
    return 0, 0
  end
  local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
  local imgW, imgH = vendingMachine:getWidth(), vendingMachine:getHeight()
  local scale = math.min(screenW / imgW, screenH / imgH) * 0.9
  local offsetX = (screenW - imgW * scale) / 2
  local offsetY = (screenH - imgH * scale) / 2
  love.graphics.draw(vendingMachine, offsetX, offsetY, 0, 0.29629629629, 0.29629629629)
  love.graphics.setColor(1.0, 0.0, 0.0);
  return offsetX, offsetY
end

local function drawInside(x, y)
  love.graphics.setCanvas(MachineCanvas)
  love.graphics.clear()
  for _, slot in ipairs(GameData.slots) do
    slot:draw()
  end


  table.sort(GameData.drinks, function(a, b)
    return a.order > b.order
  end)

  for _, drink in ipairs(GameData.drinks) do
    drink:draw()
  end
end


---@param x number
---@param y number
local function drawTooltip(x, y)
  if GameData.hoveredSlot then
    if GameData.hoveredSlot.drinkId == nil then
      return
    end
    love.graphics.setColor(ColorWithAlpha(Palette.darkMagenta, 0.3))
    love.graphics.rectangle("fill", x, y, 400, 300, 12, 12)
    love.graphics.setColor(Palette.white)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, y, 400, 300, 12, 12)
    local drinkData = DrinksData[GameData.hoveredSlot.drinkId]
    love.graphics.print('HOVERED SLOT: ' .. drinkData.name, x + 48, y + 48)
    if drinkData.sparkling then
      love.graphics.print('Sparkling', x + 48, y + 72)
    end
  end
end

local function drawUI()
  love.graphics.reset()
  drawTooltip(love.mouse.getPosition())

  if GameData.phase == Phase.SELECT_DRINK then
    love.graphics.print('Select a drink...', 200, 300)
  end


  love.graphics.print(GameData.money, 4, 4)
  love.graphics.print(GameData.score, 4, 32)


  startButton:draw()
end

function DrawGame()
  love.graphics.setBackgroundColor(HexToRGBA("#4D65B4"))
  drawBackground()
  local mx, my = drawVendingMachine()
  drawInside(mx, my)
  love.graphics.setCanvas()
  love.graphics.draw(MachineCanvas, mx, my, 0)
  drawUI()
  love.graphics.setCanvas()
end

function UpdateGame(dt)
  GameData.hoveredSlot = nil
  for _, slot in ipairs(GameData.slots) do
    slot:update(dt)
    if slot:isHovered() then
      GameData.hoveredSlot = slot
    end
  end

  for _, drink in ipairs(GameData.drinks) do
    drink:update(dt)
  end


  startButton:update()
end

function love.mousepressed(x, y, button)
  if GameData.phase == Phase.BUY then
    for _, slot in ipairs(GameData.slots) do
      if slot:isHovered() then
        local drinkData = DrinksData[slot.drinkId]
        if slot.stuck then
          GameData.money = GameData.money + drinkData.price
          slot:unstuck()
        else
          if GameData.money < drinkData.price then
            -- TODO: Add message
            return
          end
          GameData.money = GameData.money - drinkData.price
          slot:startStuck()
        end
      end
    end
  elseif GameData.phase == Phase.SELECT_DRINK then
    for _, slot in ipairs(GameData.slots) do
      if slot:isHovered() then
        local drinkData = DrinksData[slot.drinkId]
        if not slot.stuck then
          slot.drinks[1].enabled = true
          GameData.phase = Phase.SIMULATION
        end
      end
    end
  elseif GameData.phase == Phase.END then
    print("Fini!")
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
