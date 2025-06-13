local debug = require "Transmog/utils/debug"
local itemTransmogModData = require 'Transmog/utils/itemTransmogModData'
local ModDataColor = require "Transmog/utils/modDataColor"

---@param character IsoPlayer|IsoGameCharacter
local function refreshPlayerTransmog(character)
  debug.print('refreshPlayerTransmog')

  ---@type WornItems|ArrayList
  local wornItems = character:getWornItems()
  ---@type ItemVisuals|ArrayList
  local itemVisuals = ItemVisuals.new()
  ---@type WornItems|ArrayList
  local _wornItems = WornItems.new(wornItems)

  -- Este bucle recorre los items equipados y aplica la transmogrifación
  for i = 0, wornItems:size() - 1 do
    ---@type WornItem
    local wornItem = wornItems:get(i)
    if wornItem then
      local wornItemItem = wornItem:getItem()
      local moddata = itemTransmogModData.get(wornItemItem)
      local wornItemItemVisual = wornItemItem:getVisual()

      -- Asegurar que tenemos visual válido antes de continuar
      if wornItemItemVisual then
        wornItemItemVisual:setInventoryItem(wornItemItem)

        -- Si tenemos un elemento para transmogrifar, aplicamos los cambios
        if moddata.transmogTo and moddata.transmogTo ~= "" then
          -- Set transmog
          wornItemItemVisual:setItemType(moddata.transmogTo)
          -- Set color
          wornItemItemVisual:setTint(ModDataColor.modDataColorToImmutableColor(moddata.color))
          -- Set Texture Choice
          wornItemItemVisual:setTextureChoice(moddata.texture)
        end

        itemVisuals:add(wornItemItemVisual)
      end
    end
  end

  -- Actualizar la visualización
  wornItems:setFromItemVisuals(itemVisuals)
  wornItems:copyFrom(_wornItems)

  character:resetModel()
  -- Estas funciones envían los cambios visuales al servidor/clientes
  if sendVisual then sendVisual(character) end
  if sendClothing then sendClothing(character) end
end

local function _refreshPlayerTransmog(index, character) refreshPlayerTransmog(character) end

-- Registrar los eventos con comprobación para mayor compatibilidad
if Events.OnClothingUpdated then Events.OnClothingUpdated.Add(refreshPlayerTransmog) end
if Events.OnCreatePlayer then Events.OnCreatePlayer.Add(_refreshPlayerTransmog) end

return refreshPlayerTransmog