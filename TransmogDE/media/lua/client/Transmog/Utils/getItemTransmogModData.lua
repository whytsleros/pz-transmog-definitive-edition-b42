--- @class TransmogModData
--- @field transmogTo string
--- @field color string
--- @field texture number
TransmogModData = {}

--- @param item InventoryItem
--- @return TransmogModData
local function getItemTransmogModData(item)
  local modData = item:getModData()['transmog'] or {}

  local clothingItem = item:getVisual():getClothingItem()
  local texture = clothingItem and clothingItem:hasModel() and item:getVisual():getTextureChoice() or item:getVisual():getBaseTexture()

  item:getModData()['transmog'] = {
    ['transmogTo'] = modData.transmogTo or item:getFullType(),
    ['color'] = modData.color or item:getVisual():getTint(),
    ['texture'] = modData.texture or texture,
  }

  return item:getModData()['transmog']
end

return getItemTransmogModData
