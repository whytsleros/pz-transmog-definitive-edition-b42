local isSinglePlayer = (not isClient() and not isServer())

if not isSinglePlayer then
  return
end

local TransmogServer = require('TransmogServer')

local function transmogSinglePlayerInit()
  local TransmogModData = TransmogServer.GenerateTransmogModData()
  -- Directly get the mod data, and swap all the ClothingItemAssets
  for donorItemName, receiverItemName in pairs(TransmogModData.itemToTransmogMap) do
    local donorScriptItem = ScriptManager.instance:getItem(donorItemName)
    local donorClothingItemAsset = donorScriptItem:getClothingItemAsset()
    local receiverScriptItem = ScriptManager.instance:getItem(receiverItemName)
    receiverScriptItem:setClothingItemAsset(donorClothingItemAsset)
  end
end

TmogPrint('SinglePlayer Events set up')

local function applyTransmogToPlayerItems(player)
  local inv = player:getInventory();
  for i = 0, inv:getItems():size() - 1 do
    local item = inv:getItems():get(i);
    if TransmogRebuild.isTransmogItem(item) then
      TmogPrint('isTransmogItem!')

      local itemModData = item:getModData()
      TmogPrint('transmogColor: '..tostring(itemModData['transmogColor']))
      TmogPrint('transmogTexture: '..tostring(itemModData['transmogTexture']))
      TransmogRebuild.setClothingColor(item, TransmogRebuild.getClothingColor(item))
      TransmogRebuild.setClothingTexture(item, TransmogRebuild.getClothingTexture(item))
    end
  end

  player:resetModelNextFrame();
end

Events.OnClothingUpdated.Add(applyTransmogToPlayerItems);
Events.OnGameStart.Add(transmogSinglePlayerInit);

local function OnCreatePlayer(playerIndex, player)
  applyTransmogToPlayerItems(player)
end

Events.OnCreatePlayer.Add(OnCreatePlayer)