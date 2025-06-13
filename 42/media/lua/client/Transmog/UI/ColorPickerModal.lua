require "ISUI/ISCollapsableWindowJoypad"
ColorPickerModal = ISCollapsableWindowJoypad:derive("ColorPickerModal")

local ModDataColor = require "Transmog/utils/modDataColor"

function ColorPickerModal:createChildren()
  ISCollapsableWindowJoypad.createChildren(self)

  local titleBarHeight = self:titleBarHeight()

  local paddingUnit = 16                   -- eg: only left, or only right, or only top etc etc
  local paddingUnitDouble = paddingUnit * 2 -- eg: left and right or top and bottom

  self.colorPickerX = 16
  self.colorPickerY = titleBarHeight + self.colorPickerX
  self.colorPicker = ISColorPicker:new(self.colorPickerX, self.colorPickerY)
  self.colorPicker:initialise()
  self.colorPicker.pickedTarget = self;
  self.colorPicker.resetFocusTo = self;
  self.colorPicker.keepOnScreen = true
  -- Disable removeSelf for this component, otherwise it auto closes on click
  self.colorPicker.removeSelf = function() end
  self.colorPicker.pickedFunc = function (self, color)
    color.a = 1
    self.onColorSelected(color)
  end

  self:setWidth(paddingUnitDouble + self.colorPicker:getWidth())
  self:setHeight(self:titleBarHeight() + self.colorPicker:getHeight() + paddingUnitDouble)

  self:addChild(self.colorPicker)
end

function ColorPickerModal:close()
  self:removeFromUIManager()
  if JoypadState.players[self.playerNum + 1] then
    setJoypadFocus(self.playerNum, self.prevFocus)
  end
end

---@param item InventoryItem
---@param character IsoPlayer
---@param onColorSelected fun(color: ModDataColor):any
function ColorPickerModal:new(item, character, onColorSelected)
  local width = 550
  local height = 200
  local x = getCore():getScreenWidth() / 2 - (width / 2);
  local y = getCore():getScreenHeight() / 2 - (height / 2);
  local playerNum = character:getPlayerNum()
  local o = ISCollapsableWindowJoypad.new(self, x, y, width, height)
  o.character = character
  o.item = item
  o.title = "Set color of: " .. item:getName();
  o.desc = character:getDescriptor();
  o.playerNum = playerNum
  o.onColorSelected = onColorSelected
  o:setResizable(false)
  return o
end
