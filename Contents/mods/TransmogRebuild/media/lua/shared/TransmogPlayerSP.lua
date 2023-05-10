if not TmogIsSinglePlayer() then
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

Events.OnGameStart.Add(transmogSinglePlayerInit);
