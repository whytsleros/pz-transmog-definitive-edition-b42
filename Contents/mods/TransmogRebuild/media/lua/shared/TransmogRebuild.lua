local scriptManager = getScriptManager();

local function hasTransmoggableBodylocation(item)
  local bodyLocation = item:getBodyLocation()

  return bodyLocation ~= "ZedDmg"
      and not string.find(bodyLocation, "MakeUp_")
      and not string.find(bodyLocation, "Transmog_")
      and not string.find(bodyLocation, "Hide_")
end

local function isItemTransmoggable(item)
  local typeString = item:getTypeString()
  local isClothing = typeString == 'Clothing'
  local isBackpack = false -- typeString == "Container" and item:getBodyLocation()
  local isClothingItemAsset = item:getClothingItemAsset() ~= nil
  local isWorldRender = item:isWorldRender()
  local isNotCosmetic = not item:isCosmetic()
  local isNotHidden = not item:isHidden()
  local isNotTransmog = item:getModuleName() ~= "TransmogV3"
  if (isClothing or isBackpack)
      and hasTransmoggableBodylocation(item)
      and isNotTransmog
      and isWorldRender
      and isClothingItemAsset
      and isNotHidden
      and isNotCosmetic then
    return true
  end
  return false
end

local BackupClothingItemAsset = {}

local function patchAllClothing()
  local allItems = scriptManager:getAllItems()
  local invisibleClothingItemAsset = scriptManager:FindItem("TransmogV3.Hide_Everything"):getClothingItemAsset()

  local validItemsCount = 0
  local size = allItems:size() - 1;
  for i = 0, size do
    local item = allItems:get(i);
    if isItemTransmoggable(item) then
      BackupClothingItemAsset[item:getFullName()] = item:getClothingItemAsset()
      -- item:setClothingItemAsset(invisibleClothingItemAsset)
      -- -- setClothingItemAsset makes the 3d obj invisible. By forcing it to have no static model, the item appears on the floor as an icon
      -- -- item:DoParam("ClothingItem = InvisibleItem")
      -- item:DoParam("WorldStaticModel = null")
      -- validItemsCount = validItemsCount + 1
    end
  end

  print('validItemsCount: ' .. tostring(validItemsCount))
  local player = getPlayer();
  player:resetModelNextFrame();
end


local function applyTransmogFromModData()
  print('TransmogV3:applyTransmogFromModData')
  local TransmogModData = ModData.getOrCreate("TransmogModData");
  local cloneToItemMap = TransmogModData.cloneToItemMap
  for cloneId, itemName in ipairs(cloneToItemMap) do
    print('TransmogV3:applyTransmogFromModData [cloneId,itemName]: '..cloneId..','..itemName)
    local cloneScriptItem = scriptManager:FindItem("TransmogV3.TransmogCosmetic_" .. cloneId)
    local sourceScriptItem = scriptManager:getItem(itemName)
    local sourceItemInstance = sourceScriptItem:InstanceItem(nil) 

    if cloneScriptItem and BackupClothingItemAsset[itemName] then
      local icon = sourceScriptItem:getIcon()
      if sourceScriptItem:getIconsForTexture() and not sourceScriptItem:getIconsForTexture():isEmpty() then
        icon = sourceScriptItem:getIconsForTexture():get(0)
      end

      cloneScriptItem:DoParam("Icon = " .. tostring(icon));
      cloneScriptItem:setDisplayName(sourceItemInstance:getName() .. '-Cosmetic')
      cloneScriptItem:setClothingItemAsset(BackupClothingItemAsset[itemName])
    end
  end
end

return {
  patchAllClothing = patchAllClothing,
  isItemTransmoggable = isItemTransmoggable,
  applyTransmogFromModData = applyTransmogFromModData
}
