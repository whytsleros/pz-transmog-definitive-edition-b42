TransmogClient = TransmogClient or {}

TransmogClient.requestItemTransmog = function(InventoryItem)

end

TransmogClient.requestTransmogModData = function()
  TmogPrint('requestTransmogModData')

  ModData.request("TransmogModData")
end


TransmogClient.onReceiveGlobalModData = function(module, packet)
  if module ~= "TransmogModData" or not packet then
    return
  end

  TmogPrint('onReceiveGlobalModData: ' .. module)

  ModData.add("TransmogModData", packet)

  -- TransmogV3.applyTransmogFromModData()
end
