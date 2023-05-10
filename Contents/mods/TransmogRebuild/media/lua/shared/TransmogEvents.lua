local isSinglePlayer = (not isClient() and not isServer())

if isClient() then -- the second condition is for SP
  TmogPrint('Client Events set up')
  Events.OnGameStart.Add(TransmogClient.requestTransmogModData);
  Events.OnReceiveGlobalModData.Add(TransmogClient.onReceiveGlobalModData);
end

if isServer() then
  TmogPrint('Server() Events set up')
  local TransmogServer = require('TransmogServer')
  Events.OnServerStarted.Add(TransmogServer.GenerateTransmogModData)
end

if isSinglePlayer then
  TmogPrint('SinglePlayer Events set up')
  local transmogSinglePlayerInit = require('TransmogSinglePlayer')
  Events.OnGameStart.Add(transmogSinglePlayerInit);
end
