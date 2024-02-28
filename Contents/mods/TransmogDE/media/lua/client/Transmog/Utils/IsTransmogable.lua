--- @param scriptItem Item
--- @return boolean
local function isTransmoggable(scriptItem)
  if scriptItem.getScriptItem then
    scriptItem = scriptItem:getScriptItem()
  end

  local typeString = scriptItem:getTypeString()
  local isClothing = typeString == 'Clothing'
  local bodyLocation = scriptItem:getBodyLocation()
  local isBackpack = typeString == "Container" and (bodyLocation or scriptItem:InstanceItem(nil):canBeEquipped())

  if (isClothing or isBackpack) then
    return true
  end
  return false
end

return isTransmoggable
