require "ISUI/ISCollapsableWindowJoypad"

ColorPickerModal = ISCollapsableWindowJoypad:derive("ColorPickerModal")

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
	self.colorPicker.pickedFunc = self.onColorSelected

	self:setWidth(paddingUnitDouble + self.colorPicker:getWidth())
	self:setHeight(self:titleBarHeight() + self.colorPicker:getHeight() + paddingUnitDouble)

	self:addChild(self.colorPicker)
end

function ColorPickerModal:onColorSelected(color)
	local immutableColor = ImmutableColor.new(Color.new(color.r, color.g, color.b, 1))
	TransmogDE.setClothingColorModdata(self.item, immutableColor)
	TransmogDE.forceUpdateClothing(self.item)
end

function ColorPickerModal:close()
	self:removeFromUIManager()
	if JoypadState.players[self.playerNum + 1] then
		setJoypadFocus(self.playerNum, self.prevFocus)
	end
end

function ColorPickerModal:new(item, character)
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
	o:setResizable(false)
	return o
end
