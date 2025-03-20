local Slot = require('game.drinks.slot')
local DrinksData = require('Gimmedrinks.drinks_data')
local Button = require('game.gimmedrinks.ui.button')
local Scene = require("game.scenes.scene")

---@class GameScene: Scene
local GameScene = {
  totalDrinks = 0,
  drinksFalled = 0,
}
GameScene.__index = GameScene
setmetatable(GameScene, { __index = Scene })

local SLOT_DEFAULT_SIZE = { x = 128, y = 256 }
local MACHINE_CANVAS_SIZE = { x = 600, y = 600 }
MachineInnerSize = { x = 0, y = 0 }
local VendingMachinePadding = { left = 32, top = 32, right = 200, bottom = 128 }
local VendingMachineOffset = { x = 0, y = 0 }

function ScreenToMachineCanvas(x, y)
  local minScale = math.min(
    MACHINE_CANVAS_SIZE.x / MachineInnerSize.x,
    MACHINE_CANVAS_SIZE.y / MachineInnerSize.y
  )
  x = (x - VendingMachineOffset.x - VendingMachinePadding.left) / minScale
  y = (y - VendingMachineOffset.y - VendingMachinePadding.top) / minScale
  return x, y
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

local function calculateVendingMachineOffset()
  local screenW, screenH = love.graphics.getWidth(), love.graphics.getHeight()
  local w, h = MACHINE_CANVAS_SIZE.x + VendingMachinePadding.left + VendingMachinePadding.right,
      MACHINE_CANVAS_SIZE.y + VendingMachinePadding.top + VendingMachinePadding
      .bottom
  local scale = math.min(screenW / w, screenH / h) * 0.9
  VendingMachineOffset.x = (screenW - w * scale) / 2
  VendingMachineOffset.y = (screenH - h * scale) / 2
end

---@param rows number
---@param cols number
function GameScene:fillMachine(rows, cols)
  MachineInnerSize = {
    x = rows * SLOT_DEFAULT_SIZE.x,
    y = cols * SLOT_DEFAULT_SIZE.y
  }
  MachineCanvas = love.graphics.newCanvas(MachineInnerSize.x, MachineInnerSize.y)

  local keys = {}
  for key in pairs(DrinksData) do
    table.insert(keys, key)
  end


  for rx = 0, rows do
    for ry = 0, cols, 1 do
      local x = rx * SLOT_DEFAULT_SIZE.x
      local y = ry * SLOT_DEFAULT_SIZE.y
      if ry % 2 == 1 then
        x = x + SLOT_DEFAULT_SIZE.x / 2
      end
      local randomKey = keys[love.math.random(1, #keys)]
      local drinksCount = love.math.random(3, 5)
      self.totalDrinks = self.totalDrinks + 1
      local slot = Slot.new(x, y, randomKey, drinksCount, SLOT_DEFAULT_SIZE.x, SLOT_DEFAULT_SIZE.y)
      table.insert(GameData.slots, slot)
    end
  end

  calculateVendingMachineOffset()
end

function GameScene:restart()
  self:fillMachine(8, 6)


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

  if GameData.phase == Phase.BUY and startButton then
    startButton:update()
  end
end

---@param x number
---@param y number
local function drawLCDScreen(x, y)
  GameData.resources:setDefaultFont('lcd')

  love.graphics.setColor(Palette.darkTeal)
  love.graphics.rectangle("fill", x, y, 200, 60, 4, 4)
  love.graphics.setColor(Palette.limeGreen)
  love.graphics.print('Level 1', x + 16, y + 16)
end






local function drawVendingMachine()
  local w, h = MACHINE_CANVAS_SIZE.x + VendingMachinePadding.left + VendingMachinePadding.right,
      MACHINE_CANVAS_SIZE.y + VendingMachinePadding.top + VendingMachinePadding
      .bottom
  local x, y = VendingMachineOffset.x, VendingMachineOffset.y
  love.graphics.setColor(Palette.plumGray)
  love.graphics.rectangle("fill", x, y, w, h, 12, 12)
  drawLCDScreen(x + MACHINE_CANVAS_SIZE.x, y + VendingMachinePadding.top)

  love.graphics.setColor(1.0, 1.0, 1.0)
  local pushDecoration = GameData.resources:getTexture('pushDecoration')
  if pushDecoration then
    love.graphics.draw(pushDecoration, x, y + MACHINE_CANVAS_SIZE.y + 32)
  end

  return x + VendingMachinePadding.left, y + VendingMachinePadding.top
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

  for _, slot in ipairs(GameData.slots) do
    slot:drawLabel()
  end
end

local TOOLTIP_SIZE = { x = 240, y = 120 }


---@param x number
---@param y number
local function drawTooltip(x, y)
  if GameData.hoveredSlot then
    if GameData.hoveredSlot.drinkId == nil then
      return
    end
    GameData.resources:setDefaultFont("outfit_regular")
    love.graphics.setColor(ColorWithAlpha(Palette.darkMagenta, 0.3))
    love.graphics.rectangle("fill", x, y, TOOLTIP_SIZE.x, TOOLTIP_SIZE.y, 12, 12)
    love.graphics.setColor(Palette.white)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, y, TOOLTIP_SIZE.x, TOOLTIP_SIZE.y, 12, 12)
    local drinkData = DrinksData[GameData.hoveredSlot.drinkId]
    love.graphics.print(drinkData.name, x + 16, y + 16)
    love.graphics.print('x' .. #GameData.hoveredSlot.drinks, x + 16, y + 64)
    if drinkData.sparkling then
      love.graphics.print('Sparkling', x + 16, y + 96)
    end
  end
end

local function drawUI()
  local mx, my = love.mouse.getPosition()
  drawTooltip(mx + 12, my + 12)

  if GameData.phase == Phase.SELECT_DRINK then
    love.graphics.print('Select a drink...', 200, 300)
  end


  love.graphics.print(GameData.money .. "$", 4, 4)
  love.graphics.print(GameData.score, 4, 32)

  if GameData.phase == Phase.SIMULATION and GameData.mainDrink ~= nil then
    love.graphics.print('CARBONATE', 32, 500)

    love.graphics.print(math.floor(GameData.mainDrink.carbonLeft) .. '%', 32, 548)
  end




  if GameData.phase == Phase.BUY and startButton then
    startButton:draw()
  end
end



function GameScene:draw()
  local mx, my = drawVendingMachine()
  drawInside(mx, my)
  love.graphics.setCanvas()
  local minScale = math.min(
    MACHINE_CANVAS_SIZE.x / MachineInnerSize.x,
    MACHINE_CANVAS_SIZE.y / MachineInnerSize.y)
  love.graphics.draw(MachineCanvas, mx, my, 0,
    minScale, minScale)
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
