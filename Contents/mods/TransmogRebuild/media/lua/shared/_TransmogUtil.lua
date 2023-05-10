function TmogPrint(stuff)
  print('TransmogRebuild:'..stuff)
end

function TmogIsSinglePlayer()
  return (not isClient() and not isServer())
end

