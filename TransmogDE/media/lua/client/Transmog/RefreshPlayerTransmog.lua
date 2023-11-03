require "Transmog/Utils/Debug"
local itemTransmogModData = require 'Transmog/Utils/itemTransmogModData'

---@param character IsoPlayer|IsoGameCharacter
local function refreshPlayerTransmog(character)
  TmogPrint('refreshPlayerTransmog')
  local charModData = character:getModData()

  local inVehicle = character:getVehicle()

  ---@type WornItems|ArrayList
  local wornItems = character:getWornItems()
  ---@type ItemVisuals|ArrayList
  local itemVisuals = ItemVisuals.new()
  ---@type WornItems|ArrayList
  local _wornItems = WornItems.new(wornItems)

  -- This goes through the existing worn items, check if they are supposed to be shown, and adds them to the list
  for i = 0, wornItems:size() - 1 do
    ---@type WornItem
    local wornItem = wornItems:get(i)
    if wornItem then
      local wornItemItem = wornItem:getItem()
      local moddata = itemTransmogModData.get(wornItemItem)
      local wornItemItemVisual = wornItemItem:getVisual()

      wornItemItemVisual:setInventoryItem(wornItemItem)

      wornItemItemVisual:setItemType(moddata.transmogTo)

      itemVisuals:add(wornItemItemVisual)
    end
  end

  wornItems:setFromItemVisuals(itemVisuals)
  wornItems:copyFrom(_wornItems)

  character:resetModel()
  sendVisual(character)
  sendClothing(character)
end

Events.OnClothingUpdated.Add(refreshPlayerTransmog)
Events.OnCreatePlayer.Add(function(_, character) refreshPlayerTransmog(character) end)

return refreshPlayerTransmog
