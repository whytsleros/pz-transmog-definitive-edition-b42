TransmogClient = TransmogClient or {}

TransmogClient.requestTransmogModData = function()
  TmogPrint('requestTransmogModData')

  ModData.request("TransmogModData")
end


TransmogClient.onReceiveGlobalModData = function(module, packet)
  TmogPrint('onReceiveGlobalModData: ' .. module .. tostring(packet))
  if module ~= "TransmogModData" or not packet then
    return
  end


  ModData.add("TransmogModData", packet)

  TransmogRebuild.patchAllItemsFromModData(packet)
end

return TransmogClient