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
  local isNotCosmetic = not scriptItem:isCosmetic()
  local isNotHidden = not scriptItem:isHidden()
  local isNotTransmog = scriptItem:getModuleName() ~= "TransmogRebuild"
  if (isClothing or isBackpack)
      and TransmogRebuild.hasTransmoggableBodylocation(scriptItem)
      and isNotTransmog
      and isWorldRender
      and isClothingItemAsset
      and isNotHidden
      and isNotCosmetic then
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

  spawnedItem:setName('Tmog - ' .. clothing:getName())

  local clothingVisual = clothing:getVisual()

  TransmogRebuild.setClothingColor(spawnedItem, clothingVisual:getTint())
  TransmogRebuild.setClothingTexture(spawnedItem, clothingVisual:getTextureChoice())

  spawnedItem:synchWithVisual()
end

TransmogRebuild.setClothingColor = function(item, color)
  local itemModData = item:getModData()
  itemModData["transmogColor"] = color
  item:getVisual():setTint(color)

  TmogPrint('setClothingColor'..tostring(color))
end

TransmogRebuild.getClothingColor = function(item)
  local itemModData = item:getModData()
  return itemModData["transmogColor"] or item:getVisual():getTint()
end

TransmogRebuild.setClothingTexture = function(item, textureIndex)
  local itemModData = item:getModData()
  itemModData["transmogTexture"] = textureIndex
  item:getVisual():setTextureChoice(textureIndex)

  TmogPrint('setClothingTexture'..tostring(textureIndex))
end

TransmogRebuild.getClothingTexture = function (item)
  local itemModData = item:getModData()
  return itemModData["transmogTexture"] or item:getVisual():getTextureChoice()
end