local ModDataColor = require "Transmog/utils/modDataColor"

--- @class TransmogModData
--- @field transmogTo string
--- @field color ModDataColor
--- @field texture number

local itemTransmogModData = {}

--- @param item InventoryItem
--- @return TransmogModData
function itemTransmogModData.get(item)
  local modData = item:getModData()['transmog'] or itemTransmogModData.getDefault(item)

  return modData
end

--- @param item InventoryItem
--- @return TransmogModData
function itemTransmogModData.reset(item)
  item:getModData()['transmog'] = itemTransmogModData.getDefault(item)

  return item:getModData()['transmog']
end

--- @param item InventoryItem
--- @return TransmogModData
function itemTransmogModData.getDefault(item)
  local itemVisual = item:getVisual()
  local clothingItem = itemVisual:getClothingItem()
  local texture = clothingItem and clothingItem:hasModel() and itemVisual:getTextureChoice() or itemVisual:getBaseTexture()

  return {
    ['transmogTo'] = item:getFullType(),
    ['color'] = ModDataColor.colorToModDataColor(itemVisual:getTint()),
    ['texture'] = texture,
  }
end

return itemTransmogModData
