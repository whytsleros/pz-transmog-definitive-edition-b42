MxUtils = require('Transmog/MxUtils')

local function applyTransmogToPlayerItems(player)
  local playerInv = player:getInventory()
  local wornItems = player:getWornItems()

  local tmogItemsToRemove = {}
  for i = 0, wornItems:size() - 1 do
    local wornItem = wornItems:getItemByIndex(i);
    if wornItem and TransmogDE.isTransmogItem(wornItem) then
      TmogPrint('to remove:' .. tostring(wornItem:getName()))
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
    if item and TransmogDE.isTransmoggable(item) then
      TransmogDE.giveTransmogItemToPlayer(item)
    end
  end

  TransmogDE.giveHideClothingItemToPlayer()

  player:resetModelNextFrame();

  if (isClient()) then
    sendClothing(player);
  end

  TmogPrint('applyTransmogToPlayerItems! - Done')
end

local debouncedApplyTransmogToPlayerItems = MxUtils.debounce(applyTransmogToPlayerItems, 100)

local function onClothingUpdated(player)
  local hotbar = getPlayerHotbar(player:getPlayerNum());
  if hotbar == nil then return end -- player is dead

  -- I need to use the same check as the ISHotbar otherwise it shits itself,
  -- and it will randomly start spamming `OnClothingUpdated`, dunno why, but this seems to fix it
  local itemsChanged = hotbar:compareWornItems()
  if not itemsChanged then
    return
  end

  debouncedApplyTransmogToPlayerItems(player)
end

Events.OnClothingUpdated.Add(onClothingUpdated);

LuaEventManager.AddEvent("ApplyTransmogToPlayerItems");

Events.ApplyTransmogToPlayerItems.Add(debouncedApplyTransmogToPlayerItems);
