local ModDataColor = require "Transmog/utils/modDataColor"

--- @class TransmogModData
--- @field transmogTo string
--- @field color ModDataColor
--- @field texture number

local itemTransmogModData = {}
local modDataKey = 'transmogDE'

--- @param item InventoryItem
--- @return TransmogModData
function itemTransmogModData.get(item)
  -- Remeber to re-assign the reference otherwise values will NOT update!
  item:getModData()[modDataKey] = item:getModData()[modDataKey] or itemTransmogModData.getDefault(item)

  return item:getModData()[modDataKey]
end

--- @param item InventoryItem
--- @return TransmogModData
function itemTransmogModData.reset(item)
  item:getModData()[modDataKey] = itemTransmogModData.getDefault(item)

  return item:getModData()[modDataKey]
end

--- @param itemVisual ItemVisual|nil
local function getTextureValue(itemVisual)
  if not itemVisual then
    return 0
  end
  local clothingItem = itemVisual:getClothingItem()
  if not clothingItem then
    return 0
  end
  if clothingItem:hasModel() then
    return itemVisual:getTextureChoice()
  end

  return itemVisual:getBaseTexture()
end

--- @param item InventoryItem
--- @return TransmogModData
function itemTransmogModData.getDefault(item)
  local itemVisual = item:getVisual()
  local texture = getTextureValue(itemVisual)

  return {
    ['transmogTo'] = item:getFullType(),
    ['color'] = ModDataColor.colorToModDataColor(itemVisual and itemVisual:getTint()),
    ['texture'] = texture,
  }
end

return itemTransmogModData
