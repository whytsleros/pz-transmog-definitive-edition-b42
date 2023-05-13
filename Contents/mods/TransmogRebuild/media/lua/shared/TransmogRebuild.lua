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

TransmogRebuild.giveHideClothingItemToPlayer = function()
  local player = getPlayer();
  local spawnedItem = player:getInventory():AddItem('TransmogRebuild.Hide_Everything');
  player:setWornItem(spawnedItem:getBodyLocation(), spawnedItem)
end

TransmogRebuild.giveTransmogItemToPlayer = function(ogItem)
  local player = getPlayer();

  local transmogModData = TransmogRebuild.getTransmogModData()

  local transmogToName = TransmogRebuild.getItemTransmogModData(ogItem).transmogTo

  local tmogItemName = transmogModData.itemToTransmogMap[transmogToName]

  if not tmogItemName then
    return
  end

  local tmogItem = player:getInventory():AddItem(tmogItemName);

  -- For debug purpose
  tmogItem:setName('Tmog: ' .. ogItem:getName())

  TransmogRebuild.setClothingColorModdata(ogItem, TransmogRebuild.getClothingColor(ogItem))
  TransmogRebuild.setClothingColor(tmogItem, TransmogRebuild.getClothingColor(ogItem))

  TransmogRebuild.setClothingTexture(tmogItem, TransmogRebuild.getClothingTexture(ogItem))

  player:setWornItem(tmogItem:getBodyLocation(), tmogItem)

  TmogPrintTable(ogItem:getModData())
end

-- Item Specific Code

TransmogRebuild.getItemTransmogModData = function(item)
  local itemModData = item:getModData()
  itemModData['Transmog'] = itemModData['Transmog'] or {
    color = nil,
    texture = nil,
    transmogTo = item:getScriptItem():getFullName()
  }

  return itemModData['Transmog']
end

TransmogRebuild.setClothingColorModdata = function (item, color)
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
end

TransmogRebuild.setClothingColor = function(item, color)
  if color == nil then
    return
  end

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


TransmogRebuild.setClothingHidden = function(item)
  local moddata = TransmogRebuild.getItemTransmogModData(item)

  moddata.transmogTo = nil

  getPlayer():resetModelNextFrame();
end