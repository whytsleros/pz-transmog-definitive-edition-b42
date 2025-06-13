--- @param scriptItem Item
--- @return boolean
local function isTransmoggable(scriptItem)
  if not scriptItem then return false end
  
  if scriptItem.getScriptItem then
    scriptItem = scriptItem:getScriptItem()
  end

  local typeString = scriptItem:getTypeString()
  local isClothing = typeString == 'Clothing'
  
  -- En B42 pueden haber cambiado cómo se manejan las mochilas
  local bodyLocation = scriptItem:getBodyLocation()
  local isBackpack = false
  
  -- Verificar si es una mochila/contenedor de manera más robusta
  if typeString == "Container" then
    isBackpack = bodyLocation and bodyLocation ~= ""
    if not isBackpack and scriptItem.InstanceItem and type(scriptItem.InstanceItem) == "function" then
      local instance = scriptItem:InstanceItem(nil)
      isBackpack = instance and instance.canBeEquipped and instance:canBeEquipped()
    end
  end

  return (isClothing or isBackpack)
end

return isTransmoggable