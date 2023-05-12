TransmogRebuild = TransmogRebuild or {}

TransmogRebuild.hasTransmoggableBodylocation = function(item)
  local bodyLocation = item:getBodyLocation()

  return bodyLocation ~= "ZedDmg"
      and not string.find(bodyLocation, "MakeUp_")
      and not string.find(bodyLocation, "Transmog_")
      and not string.find(bodyLocation, "Hide_")
end

TransmogRebuild.isItemTransmoggable = function(scriptItem)
  if scriptItem.getScriptItem then
    scriptItem = scriptItem:getScriptItem()
  end

  local typeString = scriptItem:getTypeString()
  local isClothing = typeString == 'Clothing'
  local isBackpack = false -- typeString == "Container" and item:getBodyLocation()
  local isClothingItemAsset = scriptItem:getClothingItemAsset() ~= nil
  local isWorldRender = scriptItem:isWorldRender()
  local isNotHidden = not scriptItem:isHidden()
  local isNotTransmog = scriptItem:getModuleName() ~= "TransmogRebuild"
  -- local isNotCosmetic = not scriptItem:isCosmetic()
  if (isClothing or isBackpack)
      and TransmogRebuild.hasTransmoggableBodylocation(scriptItem)
      -- and isNotCosmetic
      and isNotTransmog
      and isWorldRender
      and isClothingItemAsset
      and isNotHidden
      and isNotHidden then
    return true
  end
  return false
end

TransmogRebuild.isTransmogItem = function(scriptItem)
  if scriptItem.getScriptItem then
    scriptItem = scriptItem:getScriptItem()
  end

  return scriptItem:getModuleName() == "TransmogRebuild"
end

TransmogRebuild.getTransmogModData = function()
  local TransmogModData = ModData.get("TransmogModData");
  return TransmogModData or {
    itemToTransmogMap = {},
    transmogToItemMap = {},
  }
end

TransmogRebuild.giveTransmogItemToPlayer = function(clothing)
  local player = getPlayer();

  local transmogModData = TransmogRebuild.getTransmogModData()

  local tmogItemName = transmogModData.itemToTransmogMap[clothing:getScriptItem():getFullName()]

  local spawnedItem = player:getInventory():AddItem(tmogItemName);

  if not spawnedItem then
    return
  end

  spawnedItem:setName('Tmog - ' .. clothing:getName())

  TransmogRebuild.setClothingColor(spawnedItem, TransmogRebuild.getClothingColor(clothing))
  TransmogRebuild.setClothingTexture(spawnedItem, TransmogRebuild.getClothingTexture(clothing))

  player:setWornItem(spawnedItem:getBodyLocation(), spawnedItem)

  TmogPrintTable(spawnedItem:getModData())
end

-- Item Specific Code

TransmogRebuild.getItemTransmogModData = function(item)
  local itemModData = item:getModData()
  itemModData['Transmog'] = itemModData['Transmog'] or {
    color = nil,
    texture = nil,
  }

  return itemModData['Transmog']
end

TransmogRebuild.setClothingColor = function(item, color)
  if color == nil then
    return
  end

  local itemModData = TransmogRebuild.getItemTransmogModData(item)
  itemModData.color = {
    r = color:getRedFloat(),
    g = color:getGreenFloat(),
    b = color:getBlueFloat(),
    a = color:getAlphaFloat(),
  }
  item:getVisual():setTint(color)

  TmogPrint('setClothingColor: ' .. tostring(color))

  getPlayer():resetModelNextFrame();
end

TransmogRebuild.getClothingColor = function(item)
  local itemModData = TransmogRebuild.getItemTransmogModData(item)
  local parsedColor = itemModData.color and
  ImmutableColor.new(Color.new(itemModData.color.r, itemModData.color.g, itemModData.color.b, itemModData.color.a))
  return parsedColor or item:getVisual():getTint()
end

-- TODO: Differntiate betwen these two 
-- setBaseTexture
-- setTextureChoice
TransmogRebuild.setClothingTexture = function(item, textureIndex)
  if textureIndex < 0 or textureIndex == nil then
    return
  end
  local itemModData = TransmogRebuild.getItemTransmogModData(item)
  itemModData.texture = textureIndex
  item:getVisual():setTextureChoice(textureIndex)
  item:synchWithVisual();

  TmogPrint('setClothingTexture' .. tostring(textureIndex))

  getPlayer():resetModelNextFrame();
end

TransmogRebuild.getClothingTexture = function(item)
  local itemModData = item:getModData()
  return itemModData.texture or item:getVisual():getTextureChoice()
end
