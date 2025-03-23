local Slot = require('flavorfall.drinks.slot')
local DrinksData = require('flavorfall.drinks_data')
local Button = require('flavorfall.ui.button')
local Scene = require("flavorfall.scenes.scene")
require "flavorfall.utils.str"

---@class GameScene: Scene
local GameScene = {
  totalDrinks = 0,
  drinksFalled = 0,
}



---@class Particle
---@field x number
---@field y number
---@field angle number?
---@field color string?
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
local trauma = 0

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
  for key, value in pairs(DrinksData) do
    local minLevel = 1
    if value.minLevel then
      minLevel = value.minLevel
    end
    if GameData.level >= minLevel then
      table.insert(keys, key)
    end
  end


  for ry = 0, cols - 1, 1 do
    local rows_count = rows
    if ry % 2 == 1 then
      rows_count = rows_count - 1
    end
    for rx = 0, rows_count - 1 do
      local x = rx * SLOT_DEFAULT_SIZE.x
      local y = ry * SLOT_DEFAULT_SIZE.y
      if ry % 2 == 1 then
        x = x + SLOT_DEFAULT_SIZE.x / 2
      end

      local randomKey = ''
      if love.math.random(5) > 1 then
        randomKey = keys[love.math.random(1, #keys)]
      end
      local drinksCount = love.math.random(3, 5)
      self.totalDrinks = self.totalDrinks + 1
      local slot = Slot.new(x, y, randomKey, drinksCount, SLOT_DEFAULT_SIZE.x, SLOT_DEFAULT_SIZE.y)
      table.insert(GameData.slots, slot)
    end
  end

  calculateVendingMachineOffset()
end

function GameScene:update(dt)
  trauma = Lerp(trauma, 0, dt * 10.0)

  GameData.hoveredSlot = nil
  for _, slot in ipairs(GameData.slots) do
    slot:update(dt)
    if #slot.drinks > 0 and slot:isHovered() then
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

  for i = #Particles.explosion, 1, -1 do
    local particle = Particles.explosion[i]
    particle.x = particle.x + math.cos(math.rad(particle.angle)) * 5 * dt
    particle.y = particle.y + math.sin(math.rad(particle.angle)) * 5 * dt
    particle.time = particle.time - dt
    if particle.time < 0 then
      table.remove(Particles.explosion, i)
    end
  end
end

---@param x number
---@param y number
local function drawLCDScreen(x, y)
  GameData.resources:setDefaultFont("lcd_small")
  love.graphics.setColor(Palette.limeGreen)
  love.graphics.print('Score       ' .. GameData.score, x + 24, y + 8)
  love.graphics.print('Objective ' .. SCORE_OBJECTIVES[GameData.level], x + 24, y + 32)
  -- if GameData.phase == Phase.BUY then
  --   if GameData.hoveredSlot then
  --     local drinkData = DrinksData[GameData.hoveredSlot.drinkId]
  --     love.graphics.print(drinkData.name, x + 16, y + 16)
  --     love.graphics.print('Price: ' .. drinkData.price, x + 16, y + 54)
  --   end
  -- else
  --   love.graphics.print('Score ' .. GameData.score, x + 16, y + 16)
  --   love.graphics.print('Objective ' .. SCORE_OBJECTIVES[GameData.level], x + 16, y + 54)
  -- end
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
    love.graphics.draw(rightDecoration, x + w - 240, y + 16, 0, 0.7, 0.7)
  end
  GameData.resources:setDefaultFont('outfit_bold')
  love.graphics.print('Level ' .. GameData.level .. '/6', 32, 32)
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

  for _, particle in ipairs(Particles.explosion) do
    love.graphics.setColor(ColorWithAlpha(Palette[particle.color], particle.time))
    love.graphics.circle("fill", particle.x, particle.y, 30 * particle.time)
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


local TOOLTIP_SIZE = { x = 280, y = 160 }


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
    love.graphics.setColor(ColorWithAlpha(Palette.darkMagenta, 0.6))
    love.graphics.rectangle("fill", x, ty, TOOLTIP_SIZE.x, TOOLTIP_SIZE.y, 12, 12)
    love.graphics.setColor(Palette.white)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle('line', x, ty, TOOLTIP_SIZE.x, TOOLTIP_SIZE.y, 12, 12)
    local drinkData = DrinksData[GameData.hoveredSlot.drinkId]
    ty = ty + 16
    love.graphics.print(drinkData.name, x + 16, ty)
    ty = ty + 32
    if GameData.money >= drinkData.price then
      love.graphics.print('Click to jam (' .. drinkData.price .. '$)', x + 16, ty)
    else
      love.graphics.setColor(ColorWithAlpha(Palette.white, 0.8))
      love.graphics.print('Not enough money! (' .. drinkData.price .. '$)', x + 16, ty)
    end
    love.graphics.setColor(Palette.white)
    ty = ty + 32

    love.graphics.print('Value: ' .. drinkData.baseScore .. 'points', x + 16, ty)
    ---@type table<DrinkType, string>
    drawBadge('x' .. #GameData.hoveredSlot.drinks .. ' left', x + 180, y - 16, 'white', 'darkPurpleBlack')
    ty = ty + 56
    drawBadge(Capitalize(drinkData.type), x + 16, ty, DrinkTypeColors[drinkData.type], 'white')
    if drinkData.type == 'sparkling' then
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

local function drawUI()
  if GameData.phase < 3 then
    drawTooltip(tooltip_position.x + 12, tooltip_position.y + 12)
  end
  love.graphics.setColor(Palette.white)

  local title = GameData.resources:setDefaultFont('outfit_title_bold')
  if title then
    if GameData.phase == Phase.SELECT_DRINK then
      CenteredText('Select a drink...', -1, 200, title, 0, 0)
    elseif GameData.phase == Phase.END then
      love.graphics.setColor(ColorWithAlpha(Palette.darkPurpleBlack, 0.5))
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
      love.graphics.setColor(Palette.white)
      CenteredText('Click to continue...', -1, 200, title, 0, 0)
    end
  end
  local font = GameData.resources:setDefaultFont('outfit_regular')


  if font then
    CenteredText('Money: ' .. GameData.money .. "$", -1, 16, font, 0, 0)
  end

  if GameData.phase == Phase.SIMULATION and GameData.mainDrink ~= nil then
    GameData.resources:setDefaultFont('outfit_medium')
    love.graphics.print('Fuel Left', 32, 500)
    GameData.resources:setDefaultFont('outfit_title_bold')
    love.graphics.print(math.floor(GameData.mainDrink.fuelLeft) .. '%', 32, 548)
  end

  drawCombos(32, 200)

  if GameData.phase == Phase.BUY and startButton then
    startButton:draw()
  end
end





function GameScene:draw()
  love.graphics.translate(
    love.math.random(-trauma, trauma),
    love.math.random(-trauma, trauma)
  )
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
      if #slot.drinks > 0 and slot:isHovered() then
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
          trauma = 5
          GameData.resources:playAudio('coin')
        end
      end
    end
  elseif GameData.phase == Phase.SELECT_DRINK then
    for _, slot in ipairs(GameData.slots) do
      if #slot.drinks > 0 and slot:isHovered() then
        local drinkData = DrinksData[slot.drinkId]
        if not slot.stuck then
          local drink = slot.drinks[1]
          drink.slot:detached(drink)
          drink.enabled = true
          drink.main = true
          GameData.mainDrink = drink
          GameData.resources:stopMusic('buy')
          GameData.resources:playMusic('ingame')
          GameData.phase = Phase.SIMULATION
        end
      end
    end
  elseif GameData.phase == Phase.END then
    GameData.resources:stopMusic('ingame')
    if GameData.score > SCORE_OBJECTIVES[GameData.level] then
      GameData.level = GameData.level + 1
      self:restart()
    else
      self:restart()
      -- local font = GameData.resources:setDefaultFont('outfit_title_bold')
      -- if font then
      --   CenteredText('You did not reach the objective.', -1, -1, font, 0, -64)
      -- end
    end
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
function AddToCombo(comboId)
  if GameData.combos[comboId].timeLeft < 0 then
    GameData.combos[comboId].value = 0
  end
  GameData.combos[comboId].value = GameData.combos[comboId].value + 1
  GameData.combos[comboId].timeLeft = GameData.combos[comboId].maxTimeLeft
end

---@param drinkData DrinkData
local function updateCombos(drinkData)
  AddToCombo('default')


  if drinkData.color == GameData.lastDrinkColor then
    AddToCombo('sameColor')
  else
    clearCombo('sameColor')
  end
  if drinkData.type == GameData.lastDrinkType then
    AddToCombo('sameType')
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
    GameData.mainDrink = nil
    GameData.phase = Phase.END
    resetCombos()
  end
end

function GameScene:restart()
  GameData.phase = Phase.BUY
  GameData.score = 0
  GameData.money = 25 + GameData.level * 5
  GameData.drinks = {}
  GameData.slots = {}
  GameData.phase = Phase.BUY
  GameData.drinks = {}
  GameData.lastDrinkColor = nil
  GameData.lastDrinkType = nil
  resetCombos()
  if GameData.level > 3 then
    self:fillMachine(10, 7)
  else
    self:fillMachine(8, 6)
  end

  GameData.resources:playMusic('buy')


  startButton = Button.new(480, 670, 'Start simulation!', function()
    GameData.phase = Phase.SELECT_DRINK
  end)
end

return GameScene
