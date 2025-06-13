local debug = require "Transmog/utils/debug"
local itemTransmogModData = require 'Transmog/utils/itemTransmogModData'
local ModDataColor = require "Transmog/utils/modDataColor"

---@param character IsoPlayer|IsoGameCharacter
local function refreshPlayerTransmog(character)
  debug.print('refreshPlayerTransmog')
  local charModData = character:getModData()

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

      -- Set transmog
      wornItemItemVisual:setItemType(moddata.transmogTo)
      -- Set color
      wornItemItemVisual:setTint(ModDataColor.modDataColorToImmutableColor(moddata.color))
      -- Set Texture Choice
      wornItemItemVisual:setTextureChoice(moddata.texture)

      itemVisuals:add(wornItemItemVisual)
    end
  end

  wornItems:setFromItemVisuals(itemVisuals)
  wornItems:copyFrom(_wornItems)

  character:resetModel()
  sendVisual(character)
  sendClothing(character)
end

local function _refreshPlayerTransmog(index, character) refreshPlayerTransmog(character) end
Events.OnClothingUpdated.Add(refreshPlayerTransmog)
Events.OnCreatePlayer.Add(_refreshPlayerTransmog)

return refreshPlayerTransmog
