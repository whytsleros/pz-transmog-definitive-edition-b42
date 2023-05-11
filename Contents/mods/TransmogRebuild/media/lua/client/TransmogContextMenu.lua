local addGetTransmogOption = function(player, context, items)
  local testItem = nil
  local clothing = nil
  for _, v in ipairs(items) do
    testItem = v;
    if not instanceof(v, "InventoryItem") then
      testItem = v.items[1];
    end
    if TransmogRebuild.isItemTransmoggable(testItem) then
      clothing = testItem;
    end
  end

  if tostring(#items) == "1" and clothing then
    local getTrasmogOption = context:addOption("Get Transmog", clothing, TransmogRebuild.giveTransmogItemToPlayer);
    getTrasmogOption.iconTexture = getTexture("media/ui/TransmogIcon.png")
  end

  return context
end

local addEditTransmogItemOption = function(player, context, items)
  local playerObj = getSpecificPlayer(player)
  local testItem = nil
  local clothing = nil
  for _, v in ipairs(items) do
    testItem = v;
    if not instanceof(v, "InventoryItem") then
      testItem = v.items[1];
    end
    if TransmogRebuild.isTransmogItem(testItem) then
      clothing = testItem;
    end
  end

  if tostring(#items) == "1" and clothing then
    local clothingItem = clothing:getClothingItem()

    if clothingItem:getAllowRandomTint() then
      local colorOption = context:addOption("Change Color", clothing, function()
        local modal = ColorPickerModal:new(0, 0, 280, 180, "Change color of " .. clothing:getDisplayName(), 'None');
        modal:initialise();
        modal:addToUIManager();
        modal:setOnSelectionCallback(function(color)
          TransmogRebuild.setClothingColor(clothing, color)
        end)
      end);
      colorOption.iconTexture = getTexture("media/ui/TransmogIcon.png")
    end

    local textureChoices = clothingItem:hasModel() and clothingItem:getTextureChoices() or clothingItem:getBaseTextures()
    if textureChoices and (textureChoices:size() > 1) then
      local textureOption = context:addOption("Change Texture", testItem, function()
        local modal = TexturePickerModal:new(0, 0, 280, 180, "Change Texture of " .. testItem:getDisplayName(), 'None');
        modal:initialise();
        modal:addToUIManager();
        modal:setTextureChoices(clothingItem:getTextureChoices());
        modal:setOnSelectionCallback(function(textureIdx)
          TransmogRebuild.setClothingTexture(clothing, textureIdx)
        end)
      end);
      textureOption.iconTexture = getTexture("media/ui/TransmogIcon.png")
    end
  end

  -- DBG
  local hairStyles = getHairStylesInstance():getAllMaleStyles();
  if playerObj:isFemale() then
    hairStyles = getHairStylesInstance():getAllFemaleStyles();
  end

  for i = 1, hairStyles:size() do
    local hairStyle = hairStyles:get(i - 1)
    TmogPrint(tostring(hairStyle))
    local option = context:addOption(
      getText("ContextMenu_CutHairFor", getText("IGUI_Hair_" .. hairStyle:getName())),
      playerObj,
      function()
        playerObj:getHumanVisual():setHairModel(hairStyle:getName());
        playerObj:resetModel();
	      playerObj:resetHairGrowingTime();
      end,
      hairStyle:getName(),
      300
    );
  end

  return context
end


Events.OnFillInventoryObjectContextMenu.Add(addEditTransmogItemOption);
Events.OnFillInventoryObjectContextMenu.Add(addGetTransmogOption);
