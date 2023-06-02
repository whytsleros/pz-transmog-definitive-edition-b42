require "ISUI/ISCollapsableWindowJoypad"

TexturePickerModal = ISCollapsableWindowJoypad:derive("TexturePickerModal")

function TexturePickerModal:createChildren()
	ISCollapsableWindowJoypad.createChildren(self)

	local titleBarHeight = self:titleBarHeight()

	self.textureSelectX = 16
	self.textureSelectY = titleBarHeight + self.textureSelectX
	self.textureSelect = ISComboBox:new(self.textureSelectX, self.textureSelectY, 228, 32, self, self.onTextureSelected)

	for i = 0, self.textureChoices:size() - 1 do
		local text = getText("UI_ClothingTextureType", i + 1)
		self.textureSelect:addOption(text)
	end

	self.textureSelect:initialise();

	self:addChild(self.textureSelect);
end

function TexturePickerModal:onTextureSelected()
	TransmogDE.setClothingTextureModdata(self.item, self.textureSelect.selected - 1)
	TransmogDE.forceUpdateClothing(self.item)
end

function TexturePickerModal:close()
	self:removeFromUIManager()
	if JoypadState.players[self.playerNum + 1] then
		setJoypadFocus(self.playerNum, self.prevFocus)
	end
end

function TexturePickerModal:new(item, character, textureChoices)
	local width = 260
	local height = 80
	local x = getCore():getScreenWidth() / 2 - (width / 2);
	local y = getCore():getScreenHeight() / 2 - (height / 2);
	local playerNum = character:getPlayerNum()
	local o = ISCollapsableWindowJoypad.new(self, x, y, width, height)
	o.character = character
	o.item = item
	o.textureChoices = textureChoices
	o.title = "Set texture of: " .. item:getName();
	o.desc = character:getDescriptor();
	o.playerNum = playerNum
	o:setResizable(false)
	return o
end
