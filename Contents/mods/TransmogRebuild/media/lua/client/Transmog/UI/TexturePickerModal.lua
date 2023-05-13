TexturePickerModal = ColorPickerModal:derive("TexturePickerModal");

function TexturePickerModal:initialise()
    ColorPickerModal.initialise(self);

    self.textureSelect = ISComboBox:new(self.colorBtn:getX(), self.colorBtn:getY(), self.colorBtn:getWidth(),
        self.colorBtn:getHeight(), self, self.onSelectTexture)
    self.textureSelect:initialise()

    for i = 0, self.textureChoices:size() - 1 do
        local text = getText("UI_ClothingTextureType", i + 1)
        self.textureSelect:addOption(text)
    end

    self.textureSelect:initialise();

    self:addChild(self.textureSelect);
    self.colorBtn:setVisible(false);
end

-- Do before initialise
function TexturePickerModal:setTextureChoices(textureChoices)
    self.textureChoices = textureChoices
end

function TexturePickerModal:onSelectTexture()
    -- print(self.textureSelect.selected -1 )
    self.onSelectionCallback(self.textureSelect.selected - 1)
end

-- ISComboBox
