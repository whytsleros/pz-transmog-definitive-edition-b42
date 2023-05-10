local function transmogSinglePlayerInit()
  local TransmogServer = require('TransmogServer')
  local TransmogModData = TransmogServer.GenerateTransmogModData()
  -- Directly get the mod data, and swap all the ClothingItemAssets
  for donorItemName, receiverItemName in pairs(TransmogModData.itemToTransmogMap) do
    local donorScriptItem = ScriptManager.instance:getItem(donorItemName)
    local donorClothingItemAsset = donorScriptItem:getClothingItemAsset()
    local receiverScriptItem = ScriptManager.instance:getItem(receiverItemName)
    receiverScriptItem:setClothingItemAsset(donorClothingItemAsset)
  end
end

return transmogSinglePlayerInit
