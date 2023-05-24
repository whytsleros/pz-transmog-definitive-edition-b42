local function applyTransmogToPlayerItems(player)
  local playerInv = player:getInventory()
  local wornItems = player:getWornItems()

  local tmogItemsToRemove = {}
  for i = 0, wornItems:size() - 1 do
    local wornItem = wornItems:getItemByIndex(i);
    TmogPrint('wornItem:getScriptItem():getFullName():'..tostring(wornItem:getScriptItem():getFullName()))
    TmogPrint('wornItem:'..tostring(wornItem))
    if wornItem and TransmogDE.isTransmogItem(wornItem) then
      table.insert(tmogItemsToRemove, wornItem)
    end
  end
  
  for _, wornItem in ipairs(tmogItemsToRemove) do
    wornItems:remove(wornItem);
    playerInv:Remove(wornItem);
  end

  local wornItems = wornItems
  for i = 0, wornItems:size() - 1 do
    local item = wornItems:getItemByIndex(i);
    TmogPrint(tostring(item))
    if item and TransmogDE.isTransmoggable(item) then
      TransmogDE.giveTransmogItemToPlayer(item)
    end
  end
  
  TransmogDE.giveHideClothingItemToPlayer()

  if (isClient()) then
		sendClothing(player);
	end

  TmogPrint('applyTransmogToPlayerItems! - Done')
end

local wornItemsSize = 0

local function onClothingUpdated(player)
  local wornItems = player:getWornItems()

  TmogPrint('wornItems:size():'..tostring(wornItems:size()))
  TmogPrint('wornItemsSize:'..tostring(wornItemsSize))

  -- \/ Stops the massive spam of "OnClothingUpdated" events
  if wornItems:size() == wornItemsSize then
    return
  end
  wornItemsSize = wornItems:size()

  applyTransmogToPlayerItems(player)
end

Events.OnClothingUpdated.Add(onClothingUpdated);

LuaEventManager.AddEvent("ApplyTransmogToPlayerItems");

Events.ApplyTransmogToPlayerItems.Add(applyTransmogToPlayerItems);