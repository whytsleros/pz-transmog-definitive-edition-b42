local debug = require "Transmog/utils/debug"
local itemTransmogModData = require 'Transmog/utils/itemTransmogModData'
local ModDataColor = require "Transmog/utils/modDataColor"

-- Import B42 compatibility module
local TransmogB42 = require "TransmogB42Compatibility"

---@param character IsoPlayer|IsoGameCharacter
local function refreshPlayerTransmog(character)
  debug.print('refreshPlayerTransmog (B42 compatible)')

  if not character then
    debug.print('No character provided to refreshPlayerTransmog')
    return
  end

  -- Use B42 compatible method to get worn items
  local wornItemsList = TransmogB42.getWornItems(character)
  
  if TransmogB42.IS_BUILD_42 then
    -- Build 42 specific implementation
    ---@type WornItems|ArrayList
    local wornItems = character:getWornItems()
    if not wornItems then
      debug.print('No worn items found for character')
      return
    end
    
    ---@type ItemVisuals|ArrayList
    local itemVisuals = ItemVisuals.new()
    ---@type WornItems|ArrayList
    local _wornItems = WornItems.new(wornItems)

    -- Loop through equipped items and apply transmog
    for i = 0, wornItems:size() - 1 do
      ---@type WornItem
      local wornItem = wornItems:get(i)
      if wornItem then
        local wornItemItem = wornItem:getItem()
        local moddata = itemTransmogModData.get(wornItemItem)
        local wornItemItemVisual = wornItemItem:getVisual()

        -- Ensure we have valid visual before continuing
        if wornItemItemVisual then
          wornItemItemVisual:setInventoryItem(wornItemItem)

          -- If we have an item to transmog to, apply the changes
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

    -- Update visualization
    wornItems:setFromItemVisuals(itemVisuals)
    wornItems:copyFrom(_wornItems)

    character:resetModel()
    
    -- Use B42 compatible visual update
    TransmogB42.updateCharacterVisual(character)
    
  else
    -- Legacy implementation for older builds
    debug.print('Using legacy transmog refresh method')
    
    for _, item in ipairs(wornItemsList) do
      local moddata = itemTransmogModData.get(item)
      if moddata.transmogTo and moddata.transmogTo ~= "" then
        local visual = item:getVisual()
        if visual then
          visual:setItemType(moddata.transmogTo)
          visual:setTint(ModDataColor.modDataColorToImmutableColor(moddata.color))
          visual:setTextureChoice(moddata.texture)
        end
      end
    end
    
    character:resetModel()
    
    -- Use legacy functions
    if sendVisual then sendVisual(character) end
    if sendClothing then sendClothing(character) end
  end
end

local function _refreshPlayerTransmog(index, character) 
  refreshPlayerTransmog(character) 
end

-- Register events with B42 compatibility checks
local function registerEvents()
  if Events.OnClothingUpdated then 
    Events.OnClothingUpdated.Add(refreshPlayerTransmog) 
    TransmogB42.debugPrint("Registered OnClothingUpdated event")
  end
  
  if Events.OnCreatePlayer then 
    Events.OnCreatePlayer.Add(_refreshPlayerTransmog) 
    TransmogB42.debugPrint("Registered OnCreatePlayer event")
  end
  
  -- B42 specific events
  if TransmogB42.IS_BUILD_42 then
    if Events.OnPlayerUpdate then
      -- Add any B42 specific event handling here
      TransmogB42.debugPrint("B42 specific events available")
    end
  end
end

-- Initialize events
registerEvents()

return refreshPlayerTransmog