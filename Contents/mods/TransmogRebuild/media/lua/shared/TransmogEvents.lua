if isClient() then -- the second condition is for SP
  TmogPrint('Client Events set up')
  Events.OnGameStart.Add(TransmogClient.requestTransmogModData);
  Events.OnReceiveGlobalModData.Add(TransmogClient.onReceiveGlobalModData);
end


