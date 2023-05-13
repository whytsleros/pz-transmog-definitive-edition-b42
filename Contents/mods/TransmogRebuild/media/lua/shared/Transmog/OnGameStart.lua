local TransmogServer = require('Transmog/TransmogServer')

local function isSinglePlayer()
  return (not isClient() and not isServer())
end

Events.OnGameStart.Add(function ()
  if isSinglePlayer() then
    local modData = TransmogServer.GenerateTransmogModData()
    TransmogRebuild.patchAllItemsFromModData(modData)
    TmogPrint('isSinglePlayer -> OnGameStart -> patchAllItemsFromModData')
    return
  end

  if isClient() then -- the second condition is for SP
    TransmogClient.requestTransmogModData()
    Events.OnReceiveGlobalModData.Add(TransmogClient.onReceiveGlobalModData);
    TmogPrint('isClient -> requestTransmogModData')
  end
end);
