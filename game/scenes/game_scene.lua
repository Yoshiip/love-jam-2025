local Slot = require('game.drinks.slot')
local DrinksData = require('Gimmedrinks.drinks_data')
local Button = require('game.gimmedrinks.ui.button')
local Scene = require("game.scenes.scene")

local GameScene = {}
GameScene.__index = GameScene
setmetatable(GameScene, { __index = Scene })

local SLOTS_COUNT = 32
local GRID_WIDTH = 6
local machineCanvasOffset = { x = 0, y = 0 }

---@type Button
local startButton

function GameScene:new()
  return self
end

function GameScene:start()
  self:restart()
end

function GameScene:restart()
  local spacing = 128
  MachineCanvas = love.graphics.newCanvas(128 * 6, 128 * 6 * 2)

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


  startButton:update()
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
  drawTooltip(love.mouse.getPosition())

  if GameData.phase == Phase.SELECT_DRINK then
    love.graphics.print('Select a drink...', 200, 300)
  end


  love.graphics.print(GameData.money, 4, 4)
  love.graphics.print(GameData.score, 4, 32)


  startButton:draw()
end


function GameScene:draw()
  local mx, my = drawVendingMachine()
  drawInside(mx, my)
  love.graphics.setCanvas()
  love.graphics.draw(MachineCanvas, mx, my, 0)
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
          slot.drinks[1].enabled = true
          GameData.phase = Phase.SIMULATION
        end
      end
    end
  elseif GameData.phase == Phase.END then
    print("Fini!")
  end
end

function GameScene:mousereleased(x, y, button)
  if button == 1 then
  end
end

return GameScene
