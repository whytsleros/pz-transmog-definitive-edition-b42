if isServer() then
  return
end

local function applyTransmogToPlayerItems(player)
  TmogPrint('applyTransmogToPlayerItems!')
  local inv = player:getInventory();
  for i = 0, inv:getItems():size() - 1 do
    local item = inv:getItems():get(i);
    if TransmogRebuild.isTransmogItem(item) then
      TmogPrintTable(TransmogRebuild.getItemTransmogModData(item))
      TransmogRebuild.setClothingColor(item, TransmogRebuild.getClothingColor(item))
      TransmogRebuild.setClothingTexture(item, TransmogRebuild.getClothingTexture(item))
    end
  end

  player:resetModelNextFrame();
end

Events.OnClothingUpdated.Add(applyTransmogToPlayerItems);

local function OnCreatePlayer(playerIndex, player)
  applyTransmogToPlayerItems(player)
end

Events.OnCreatePlayer.Add(OnCreatePlayer)