-- Import B42 compatibility module
local TransmogB42 = require "TransmogB42Compatibility"

--- @param scriptItem Item
--- @return boolean
local function isTransmoggable(scriptItem)
  if not scriptItem then return false end
  
  -- Handle both script items and inventory items
  local actualScriptItem = scriptItem
  if scriptItem.getScriptItem then
    actualScriptItem = scriptItem:getScriptItem()
  end
  
  if not actualScriptItem then return false end

  local typeString = actualScriptItem:getTypeString()
  
  -- B42 compatible clothing check
  local isClothing = typeString == 'Clothing'
  
  -- Enhanced backpack/container detection for B42
  local bodyLocation = actualScriptItem:getBodyLocation()
  local isBackpack = false
  
  -- Check if it's a wearable container
  if typeString == "Container" then
    isBackpack = bodyLocation and bodyLocation ~= ""
    
    -- B42 enhanced container checks
    if not isBackpack and TransmogB42.IS_BUILD_42 then
      -- Additional B42 specific checks for containers
      if actualScriptItem.isWearable and actualScriptItem:isWearable() then
        isBackpack = true
      elseif actualScriptItem.getCanBeEquipped and actualScriptItem:getCanBeEquipped() then
        isBackpack = true
      end
    end
      -- Fallback instance check
    if not isBackpack and actualScriptItem.InstanceItem then
      local instance = actualScriptItem:InstanceItem(nil)
      isBackpack = instance and instance.canBeEquipped and instance:canBeEquipped()
    end
  end
  
  -- Additional B42 checks for new item types
  local isTransmoggableType = isClothing or isBackpack
  
  if TransmogB42.IS_BUILD_42 then
    -- B42 might have new equipment types or categories
    local category = actualScriptItem:getCategory()
    if category then
      local categoryStr = tostring(category)
      -- Check for new B42 equipment categories
      if categoryStr:find("Clothing") or categoryStr:find("Armor") or categoryStr:find("Equipment") then
        isTransmoggableType = true
      end
    end
    
    -- Check if item has visual properties in B42
    if actualScriptItem.hasVisual and actualScriptItem:hasVisual() then
      isTransmoggableType = true
    end
  end

  TransmogB42.debugPrint("Item " .. tostring(actualScriptItem:getName()) .. " is transmoggable: " .. tostring(isTransmoggableType))
  
  return isTransmoggableType
end

return isTransmoggable