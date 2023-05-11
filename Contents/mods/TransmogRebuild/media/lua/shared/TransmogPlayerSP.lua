if not TmogIsSinglePlayer() then
  return
end

local TransmogServer = require('TransmogServer')

local function transmogSinglePlayerInit()
  local TransmogModData = TransmogServer.GenerateTransmogModData()
  -- Directly get the mod data, and swap all the ClothingItemAssets
  local beltScriptItem = ScriptManager.instance:getItem('Base.Belt2')
  local beltClothingItemAsset = beltScriptItem:getClothingItemAsset()
  for originalItemName, tmogItemName in pairs(TransmogModData.itemToTransmogMap) do
    local originalScriptItem = ScriptManager.instance:getItem(originalItemName)
    local originalClothingItemAsset = originalScriptItem:getClothingItemAsset()

    local tmogScriptItem = ScriptManager.instance:getItem(tmogItemName)
    tmogScriptItem:setClothingItemAsset(originalClothingItemAsset)

    originalScriptItem:setClothingItemAsset(beltClothingItemAsset)
  end

  TmogPrint('transmogSinglePlayerInit: DONE')

  -- Must be triggered after Transmog Has been Initialized
  triggerEvent("OnClothingUpdated", getPlayer())
end

Events.OnGameStart.Add(transmogSinglePlayerInit);
