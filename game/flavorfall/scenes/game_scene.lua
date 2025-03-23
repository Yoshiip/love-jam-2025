local Slot = require('flavorfall.drinks.slot')
local DrinksData = require('flavorfall.drinks_data')
local Button = require('flavorfall.ui.button')
local Scene = require("flavorfall.scenes.scene")

---@class GameScene: Scene
local GameScene = {
  totalDrinks = 0,
  drinksFalled = 0,
}



---@class Particle
---@field x number
---@field y number
---@field time number

---@class Particles
---@field explosion Particle[]
---@field fuel Particle[]
Particles = {
  explosion = {},
  fuel = {},
}

GameScene.__index = GameScene
setmetatable(GameScene, { __index = Scene })

local SLOT_DEFAULT_SIZE = { x = 128, y = 256 }
local MACHINE_CANVAS_SIZE = { x = 450, y = 600 }
MachineInnerSize = { x = 0, y = 0 }
local VendingMachinePadding = { left = 32, top = 32, right = 200, bottom = 128 }
local VendingMachineOffset = { x = 0, y = 0 }

local tooltip_position = { x = 0, y = 0 }


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
  GameData.money = 40
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


  for ry = 0, cols, 1 do
    local rows_count = rows
    if ry % 2 == 1 then
      rows_count = rows_count - 2
    end
    for rx = 0, rows_count do
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

  for _, combo in pairs(GameData.combos) do
    if combo.timeLeft > 0 then
      combo.timeLeft = combo.timeLeft - dt
    end
  end


  local mx, my = love.mouse.getPosition()
  tooltip_position.x = Lerp(tooltip_position.x, mx, 10.0 * dt)
  tooltip_position.y = Lerp(tooltip_position.y, my, 10.0 * dt)

  for i = #Particles.fuel, 1, -1 do
    local particle = Particles.fuel[i]
    particle.y = particle.y + 5 * dt
    particle.time = particle.time - dt
    if particle.time < 0 then
      table.remove(Particles.fuel, i)
    end
  end
end

---@param x number
---@param y number
local function drawLCDScreen(x, y)
  GameData.resources:setDefaultFont('lcd')
  love.graphics.setColor(Palette.limeGreen)
  if GameData.phase == Phase.BUY then
    if GameData.hoveredSlot then
      local drinkData = DrinksData[GameData.hoveredSlot.drinkId]
      love.graphics.print(drinkData.name, x + 16, y + 16)
      love.graphics.print('Price: ' .. drinkData.price, x + 16, y + 54)
    end
  else
    love.graphics.print('Score ' .. GameData.score, x + 16, y + 16)
    love.graphics.print('Objective ' .. GameData.objective, x + 16, y + 54)
  end
end


local function drawVendingMachine()
  local w, h = MACHINE_CANVAS_SIZE.x + VendingMachinePadding.left + VendingMachinePadding.right,
      MACHINE_CANVAS_SIZE.y + VendingMachinePadding.top + VendingMachinePadding
      .bottom
  local x, y = VendingMachineOffset.x, VendingMachineOffset.y
  love.graphics.setColor(Palette.plumGray)
  love.graphics.rectangle("fill", x, y, w, h, 12, 12)
  local rightDecoration = GameData.resources:getTexture('rightDecoration')
  if rightDecoration then
    love.graphics.setColor(Palette.white)
    love.graphics.draw(rightDecoration, x + w - 240, y + 16, 0, 0.6, 0.6)
  end
  drawLCDScreen(x + MACHINE_CANVAS_SIZE.x, y + VendingMachinePadding.top)


  love.graphics.setColor(1.0, 1.0, 1.0)
  local pushDecoration = GameData.resources:getTexture('pushDecoration')
  if pushDecoration then
    love.graphics.draw(pushDecoration, x, y + MACHINE_CANVAS_SIZE.y + 32)
  end

  return x + VendingMachinePadding.left, y + VendingMachinePadding.top
end

local function drawParticles()
  for _, particle in ipairs(Particles.fuel) do
    love.graphics.setColor(ColorWithAlpha(Palette.white, particle.time))
    love.graphics.circle("fill", particle.x, particle.y, 20 * particle.time)
  end
  love.graphics.setColor(Palette.white)
end

local function drawInside()
  love.graphics.setCanvas(MachineCanvas)
  love.graphics.clear()
  love.graphics.setColor(Palette.darkPurpleBlack)
  love.graphics.rectangle("fill", 0, 0, MachineInnerSize.x, MachineInnerSize.y)
  for _, slot in ipairs(GameData.slots) do
    slot:draw()
  end


  table.sort(GameData.drinks, function(a, b)
    if a.enabled ~= b.enabled then
      return a.enabled and not b.enabled
    end
    return b.order > a.order
  end)

  for i = 1, math.floor(#GameData.drinks / 2) do
    local j = #GameData.drinks - i + 1
    GameData.drinks[i], GameData.drinks[j] = GameData.drinks[j], GameData.drinks[i]
  end


  for _, drink in ipairs(GameData.drinks) do
    drink:draw()
  end

  for _, slot in ipairs(GameData.slots) do
    slot:drawLabel()
  end

  drawParticles()
end


local TOOLTIP_SIZE = { x = 240, y = 120 }


---@param x number
---@param y number
local function drawTooltip(x, y)
  if GameData.hoveredSlot then
    if GameData.hoveredSlot.drinkId == nil then
      return
    end

    local function drawBadge(text, bx, by, bgColor, textColor)
      local font = GameData.resources:setDefaultFont('outfit_regular')
      if font then
        local h = font:getHeight()
        love.graphics.setColor(Palette[bgColor])
        love.graphics.rectangle("fill", bx, by, font:getWidth(text) + 8, h, h / 2, h / 2)
        love.graphics.setColor(Palette[textColor])
        love.graphics.print(text, bx + 4, by)
      end
    end
    GameData.resources:setDefaultFont("outfit_regular")
    local ty = y
    love.graphics.setColor(ColorWithAlpha(Palette.darkMagenta, 0.3))
    love.graphics.rectangle("fill", x, ty, TOOLTIP_SIZE.x, TOOLTIP_SIZE.y, 12, 12)
    love.graphics.setColor(Palette.white)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, ty, TOOLTIP_SIZE.x, TOOLTIP_SIZE.y, 12, 12)
    local drinkData = DrinksData[GameData.hoveredSlot.drinkId]
    love.graphics.print(drinkData.name, x + 16, ty + 16)
    ty = ty + 48
    love.graphics.print('Value: ' .. drinkData.baseScore, x + 16, ty)
    drawBadge(drinkData.type, x + 16, y - 16, 'white', 'darkPurpleBlack')
    drawBadge('x' .. #GameData.hoveredSlot.drinks .. ' left', x + 128, y - 16, 'white', 'darkPurpleBlack')
    ty = ty + 56
    if drinkData.type == 'sparkling' then
      drawBadge('Sparkling', x + 16, ty, 'goldenrod', 'white')
      drawBadge('Fuel: ' .. drinkData.fuel .. '%', x + 140, ty, 'goldenrod', 'white')
    end
  end
end



---@param x number
---@param y number
local function drawCombos(x, y)
  local oy = y
  local width = 200
  for _, combo in pairs(GameData.combos) do
    if combo.timeLeft > 0 then
      love.graphics.setColor(Palette.white)
      GameData.resources:setDefaultFont("outfit_regular")
      love.graphics.print(combo.label, x, oy)
      GameData.resources:setDefaultFont("outfit_title_bold")
      local tx = GameData.resources:getFont('outfit_title_bold'):getWidth(combo.value .. 'x')
      love.graphics.print(combo.value .. 'x', x + width - tx, oy - 16)
      love.graphics.setColor(Palette.darkPurpleBlack)
      love.graphics.rectangle("fill", x, oy + 40, width, 8)
      love.graphics.setColor(Palette.white)
      love.graphics.rectangle("fill", x, oy + 40, width * (combo.timeLeft / combo.maxTimeLeft), 8)

      oy = oy + 56
    end
  end
end

---@param text string
---@param x number
---@param y number
---@param font love.Font
---@param ox number
---@param oy number
local function centeredText(text, x, y, font, ox, oy)
  local cx, cy = x, y
  if x == -1 then
    cx = love.graphics.getWidth() / 2 - font:getWidth(text)
  end
  if y == -1 then
    cy = love.graphics.getHeight() / 2 - font:getHeight()
  end

  love.graphics.print(text, cx + ox, cy + ox)
end

local function drawUI()
  drawTooltip(tooltip_position.x + 12, tooltip_position.y + 12)
  love.graphics.setColor(Palette.white)

  local title = GameData.resources:setDefaultFont('outfit_title_bold')
  if title then
    if GameData.phase == Phase.SELECT_DRINK then
      centeredText('Select a drink...', -1, 200, title, 0, 0)
    elseif GameData.phase == Phase.END then
      centeredText('Click to continue...', -1, 200, title, 0, 0)
    end
  end
  GameData.resources:setDefaultFont('outfit_regular')

  love.graphics.print(GameData.money .. "$", 4, 4)

  if GameData.phase == Phase.SIMULATION and GameData.mainDrink ~= nil then
    GameData.resources:setDefaultFont('outfit_medium')
    love.graphics.print('Fuel Left', 32, 500)
    GameData.resources:setDefaultFont('outfit_title_bold')
    love.graphics.print(math.floor(GameData.mainDrink.fuelLeft) .. '%', 32, 548)
  end

  drawCombos(32, 200)


  GameData.resources:setDefaultFont('outfit_title_bold')
  love.graphics.print(GameData.score, 1020, 32)
  GameData.resources:setDefaultFont('outfit_medium')
  love.graphics.print('Objective: ' .. GameData.objective, 960, 90)



  if GameData.phase == Phase.BUY and startButton then
    startButton:draw()
  end
end





function GameScene:draw()
  local mx, my = drawVendingMachine()
  drawInside()
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
          GameData.resources:playAudio('coin')
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

function GameScene:keypressed(key)
  if key == 'space' and GameData.mainDrink ~= nil and GameData.mainDrink.fuelLeft > 0 then
    GameData.resources:playAudio('fuel')
  end
end

function GameScene:mousereleased(x, y, button)
end

---@return number
local function getCombo()
  local total = 0
  for _, c in pairs(GameData.combos) do
    if c.timeLeft > 0 then
      total = total + c.value * c.strength
    end
  end
  return total
end


local function clearCombo(id)
  GameData.combos[id].timeLeft = 0
  GameData.combos[id].value = 0
end

---@param comboId string
local function addToCombo(comboId)
  if GameData.combos[comboId].timeLeft < 0 then
    GameData.combos[comboId].value = 0
  end
  GameData.combos[comboId].value = GameData.combos[comboId].value + 1
  GameData.combos[comboId].timeLeft = GameData.combos[comboId].maxTimeLeft
end


---@param drinkData DrinkData
local function updateCombos(drinkData)
  addToCombo('default')


  if drinkData.color == GameData.lastDrinkColor then
    addToCombo('sameColor')
  else
    clearCombo('sameColor')
  end
  if drinkData.type == GameData.lastDrinkType then
    addToCombo('sameType')
  else
    clearCombo('sameType')
  end
end

local function resetCombos()
  for key, _ in pairs(GameData.combos) do
    GameData.combos[key].value = 0
    GameData.combos[key].timeLeft = 0
  end
end


---@param drink Drink
function GameScene:drinkFalled(drink)
  ---@type DrinkData
  local drinkData = DrinksData[drink.id]
  updateCombos(drinkData)

  local multiplier = 1 + getCombo() / 10
  GameData.score = GameData.score + math.floor(drinkData.baseScore * multiplier)
  GameData.lastDrinkColor = drinkData.color
  GameData.lastDrinkType = drinkData.type
  if drink.main then
    print("Main est failé")
    GameData.phase = Phase.END
    resetCombos()
  end
end

return GameScene
