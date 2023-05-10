local TransmogContextMenu = function(player, context, items)
  local testItem = nil
  local clothing = nil
  for _, v in ipairs(items) do
    testItem = v;
    if not instanceof(v, "InventoryItem") then
      testItem = v.items[1];
    end
    if TransmogRebuild.isItemTransmoggable(testItem) then
      clothing = testItem;
    end
  end

  if tostring(#items) == "1" and clothing then
    local transmog = context:addOption("Get Transmog", clothing, TransmogRebuild.giveTransmogItemToPlayer);
  end

  return context
end


Events.OnFillInventoryObjectContextMenu.Add(TransmogContextMenu);

