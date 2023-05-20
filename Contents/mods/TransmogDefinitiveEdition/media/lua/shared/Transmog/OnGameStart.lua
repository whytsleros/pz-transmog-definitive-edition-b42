local TransmogClient = require('Transmog/TransmogClient')

local function isSinglePlayer()
  return (not isClient() and not isServer())
end

Events.OnGameStart.Add(function()
  TransmogClient.requestTransmogModData()
  if isSinglePlayer() then
    local modData = TransmogDE.GenerateTransmogGlobalModData()
    TransmogDE.patchAllItemsFromModData(modData)
    TmogPrint('isSinglePlayer -> OnGameStart -> patchAllItemsFromModData')
    return
  end
end);

if isClient() then -- the second condition is for SP
  Events.OnReceiveGlobalModData.Add(TransmogClient.onReceiveGlobalModData);
  TmogPrint('OnReceiveGlobalModData.Add')
end
