require "ISUI/ISCollapsableWindowJoypad"

TexturePickerModal = ISCollapsableWindowJoypad:derive("TexturePickerModal")

function TexturePickerModal:createChildren()
	ISCollapsableWindowJoypad.createChildren(self)

	local titleBarHeight = self:titleBarHeight()

	local textureChoicesSize = self.textureChoices:size()
	local numColumns = 4
	local minNumRows = 4
	local numRows = math.ceil(textureChoicesSize / numColumns)

	local btnX = 0
	local btnH = 125

	local scrollPanelHeight = (minNumRows * btnH) + titleBarHeight
	local scrollPanelWidth = (numColumns * btnH) + 13

	self.scrollView = TmogScrollView:new(btnX, titleBarHeight, scrollPanelWidth, scrollPanelHeight)
	self.scrollView:initialise()
	self:addChild(self.scrollView)

	for row = 0, numRows - 1 do
		local rowElements = {}
		for col = 0, numColumns - 1 do
			local index = row * numColumns + col
			if index < textureChoicesSize then
				table.insert(rowElements, self.textureChoices:get(index))
				local textureChoice = getTexture('media/textures/' .. self.textureChoices:get(index) .. '.png')
				local button = ISButton:new(1 + btnX + (col * btnH), (row * btnH), btnH, btnH, "", self,
					TexturePickerModal.onTextureSelected)
				button.internal = index
				button:setImage(textureChoice)
				button:forceImageSize(btnH - 2, btnH - 2)
				button:setBorderRGBA(1, 1, 1, 0.6)
				self.scrollView:addScrollChild(button)
			else
				break
			end
		end
		-- print(table.concat(rowElements, "\t"))
	end

	self.scrollView:setScrollHeight(numRows * btnH)
	self:setWidth(scrollPanelWidth)
	self:setHeight(scrollPanelHeight + 16)
end

function TexturePickerModal:onTextureSelected(button)
	TransmogDE.setClothingTextureModdata(self.item, button.internal)
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
	local height = 180
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
