local TransmogServer = require('Transmog/TransmogServer')

local function isSinglePlayer()
  return (not isClient() and not isServer())
end

local function transmogSinglePlayerInit()
  local TransmogModData = TransmogServer.GenerateTransmogModData()
  for originalItemName, tmogItemName in pairs(TransmogModData.itemToTransmogMap) do
    local originalScriptItem = ScriptManager.instance:getItem(originalItemName)
    local originalClothingItemAsset = originalScriptItem:getClothingItemAsset()

    local tmogScriptItem = ScriptManager.instance:getItem(tmogItemName)
    local tmogClothingItemAsset = tmogScriptItem:getClothingItemAsset()
    tmogScriptItem:setClothingItemAsset(originalClothingItemAsset)

    if originalClothingItemAsset:isHat() or originalClothingItemAsset:isMask() then
      -- Hide hats to avoid having the hair being compressed if wearning an helmet or something similiar 
      originalScriptItem:setClothingItemAsset(tmogClothingItemAsset)
    end
  end

  TmogPrint('transmogSinglePlayerInit: DONE')

  -- Must be triggered after Transmog Has been Initialized
  triggerEvent("OnClothingUpdated", getPlayer())
end

Events.OnGameStart.Add(function ()
  if isSinglePlayer() then
    transmogSinglePlayerInit()
    return
  end

  if isClient() then -- the second condition is for SP
    TmogPrint('Client Events set up')
    TransmogClient.requestTransmogModData()
    Events.OnReceiveGlobalModData.Add(TransmogClient.onReceiveGlobalModData);
  end
end);
