local Slot = require('game.drinks.slot')
local DrinksData = require('Gimmedrinks.drinks_data')
local Button = require('game.gimmedrinks.ui.button')
local Scene = require("game.scenes.scene")

---@class GameScene: Scene
local GameScene = {}
GameScene.__index = GameScene
setmetatable(GameScene, { __index = Scene })


local SLOT_DEFAULT_SIZE = { x = 128, y = 256 }
MachineInnerSize = { x = 0, y = 0 }
local MACHINE_CANVAS_SIZE = { x = 600, y = 600 }

function ScreenToMachineCanvas(x, y)
  x = x * MachineInnerSize.x / MACHINE_CANVAS_SIZE.x
  y = y * MachineInnerSize.y / MACHINE_CANVAS_SIZE.y
  return x - 312, y - 36
end

---@type Button|nil
local startButton

function GameScene:new()
  return self
end

function GameScene:start()
  GameData.phase = Phase.BUY
  GameData.score = 0
  GameData.money = 10
  GameData.drinks = {}
  GameData.slots = {}
  self:restart()
end

---@param rows number
---@param cols number
local function fillMachine(rows, cols)
  MachineInnerSize = {
    x = rows * SLOT_DEFAULT_SIZE.x,
    y = cols * SLOT_DEFAULT_SIZE.y
  }
  MachineCanvas = love.graphics.newCanvas(MachineInnerSize.x, MachineInnerSize.y)

  local keys = {}
  for key in pairs(DrinksData) do
    table.insert(keys, key)
  end


  for i = 0, rows * cols do
    local x = i % rows * SLOT_DEFAULT_SIZE.x
    local y = math.floor(i / rows) * SLOT_DEFAULT_SIZE.y
    local randomKey = keys[love.math.random(1, #keys)]
    local slot = Slot.new(x, y, randomKey, 8, SLOT_DEFAULT_SIZE.x, SLOT_DEFAULT_SIZE.y)
    table.insert(GameData.slots, slot)
  end
end

function GameScene:restart()
  fillMachine(6, 8)


  startButton = Button.new(32, 32, 'Start', function()
    GameData.phase = Phase.SELECT_DRINK
  end)
end

function GameScene:update(dt)
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

  if startButton then
    startButton:update()
  end
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
  love.graphics.draw(vendingMachine, offsetX, offsetY, 0, 0.2, 0.2)
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
    love.graphics.rectangle("fill", x, y, 400, 200, 12, 12)
    love.graphics.setColor(Palette.white)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, y, 400, 200, 12, 12)
    local drinkData = DrinksData[GameData.hoveredSlot.drinkId]
    love.graphics.print('HOVERED SLOT: ' .. drinkData.name, x + 48, y + 48)
    love.graphics.print('Drinks left: ' .. #GameData.hoveredSlot.drinks, x + 48, y + 96)
    if drinkData.sparkling then
      love.graphics.print('Sparkling', x + 48, y + 144)
    end
  end
end

local function drawUI()
  drawTooltip(love.mouse.getPosition())

  if GameData.phase == Phase.SELECT_DRINK then
    love.graphics.print('Select a drink...', 200, 300)
  end


  love.graphics.print(GameData.money .. "$", 4, 4)
  love.graphics.print(GameData.score, 4, 32)

  if GameData.phase == Phase.SIMULATION and GameData.mainDrink ~= nil then
    love.graphics.print('CARBONATE', 32, 500)

    love.graphics.print(math.floor(GameData.mainDrink.carbonLeft) .. '%', 32, 548)
  end


  if startButton then
    startButton:draw()
  end
end


function GameScene:draw()
  local mx, my = drawVendingMachine()
  drawInside(mx, my)
  love.graphics.setCanvas()
  love.graphics.draw(MachineCanvas, mx, my, 0,
    MACHINE_CANVAS_SIZE.x / MachineInnerSize.x,
    MACHINE_CANVAS_SIZE.y / MachineInnerSize.y)
  drawUI()
  love.graphics.setCanvas()
end

function GameScene:mousepressed(x, y, button)
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
          local drink = slot.drinks[1]
          drink.enabled = true
          drink.main = true
          GameData.mainDrink = drink
          GameData.phase = Phase.SIMULATION
        end
      end
    end
  elseif GameData.phase == Phase.END then
    ChangeScene(Screens.results)
  end
end

function GameScene:mousereleased(x, y, button)
  if button == 1 then
  end
end

function GameScene:mainFalled()
  GameData.phase = Phase.END
end

return GameScene
