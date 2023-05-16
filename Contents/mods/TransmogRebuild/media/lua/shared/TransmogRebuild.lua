TransmogRebuild = TransmogRebuild or {}

TransmogRebuild.ImmersiveModeMap = {}

TransmogRebuild.GenerateTransmogGlobalModData = function()
  TmogPrint('Server TransmogModData')
  local scriptManager = getScriptManager();
  local allItems = scriptManager:getAllItems()
  local transmogModData = TransmogRebuild.getTransmogModData()
  local itemToTransmogMap = transmogModData.itemToTransmogMap or {}
  local transmogToItemMap = transmogModData.transmogToItemMap or {}

  local serverTransmoggedItemCount = 0
  local size = allItems:size() - 1;
  for i = 0, size do
      local item = allItems:get(i);
      if TransmogRebuild.isTransmoggable(item) then
          local fullName = item:getFullName()
          serverTransmoggedItemCount = serverTransmoggedItemCount + 1
          if not itemToTransmogMap[fullName] then
              table.insert(transmogToItemMap, fullName)
              itemToTransmogMap[fullName] = 'TransmogRebuild.TransmogItem_' .. #transmogToItemMap
          end
          TmogPrint(fullName..' -> '..tostring(itemToTransmogMap[fullName]))
      end
  end

  if #transmogToItemMap >= 5000 then
      TmogPrint("ERROR: Reached limit of transmoggable items")
  end

  ModData.add("TransmogModData", transmogModData)
  ModData.transmit("TransmogModData")

  TmogPrint('Transmogged items count: ' .. tostring(serverTransmoggedItemCount))

  return transmogModData
end

TransmogRebuild.patchAllItemsFromModData = function(modData)
  for originalItemName, tmogItemName in pairs(modData.itemToTransmogMap) do
    local originalScriptItem = ScriptManager.instance:getItem(originalItemName)
    local originalClothingItemAsset = originalScriptItem:getClothingItemAsset()

    local tmogScriptItem = ScriptManager.instance:getItem(tmogItemName)
    local tmogClothingItemAsset = tmogScriptItem:getClothingItemAsset()
    tmogScriptItem:setClothingItemAsset(originalClothingItemAsset)

    if originalClothingItemAsset:isHat() or originalClothingItemAsset:isMask() then
      -- Hide hats to avoid having the hair being compressed if wearning an helmet or something similiar
      originalScriptItem:setClothingItemAsset(tmogClothingItemAsset)
    end
  end

  -- Must be triggered after items are patched
  triggerEvent("OnClothingUpdated", getPlayer())
end

TransmogRebuild.triggerUpdate = function()
  triggerEvent("OnClothingUpdated", getPlayer())
end

TransmogRebuild.hasTransmoggableBodylocation = function(item)
  local bodyLocation = item:getBodyLocation()

  return bodyLocation ~= "ZedDmg"
      and not string.find(bodyLocation, "MakeUp_")
      and not string.find(bodyLocation, "Transmog_")
      and not string.find(bodyLocation, "Hide_")
end

TransmogRebuild.isTransmoggable = function(scriptItem)
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

TransmogRebuild.setClothingColorModdata = function(item, color)
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
end

TransmogRebuild.getClothingTexture = function(item)
  local itemModData = item:getModData()
  return itemModData.texture or item:getVisual():getTextureChoice()
end

TransmogRebuild.setItemTransmog = function(itemToTmog, scriptItem)
  local moddata = TransmogRebuild.getItemTransmogModData(itemToTmog)

  if scriptItem.getScriptItem then
    scriptItem = scriptItem:getScriptItem()
  end

  moddata.transmogTo = scriptItem:getFullName()
end

TransmogRebuild.setItemToDefault = function(item)
  local moddata = TransmogRebuild.getItemTransmogModData(item)

  moddata.transmogTo = item:getScriptItem():getFullName()
end

TransmogRebuild.setClothingHidden = function(item)
  local moddata = TransmogRebuild.getItemTransmogModData(item)

  moddata.transmogTo = nil
end

-- Immersive mode code

TransmogRebuild.getImmersiveModeData = function()
  return ModData.getOrCreate('TransmogImmersiveModeData')
end

TransmogRebuild.immersiveModeItemCheck = function(item)
  if SandboxVars.TransmogRebuild.ImmersiveModeToggle ~= true then
    return true
  end
  return TransmogRebuild.getImmersiveModeData()[item:getFullName()] == true
end
