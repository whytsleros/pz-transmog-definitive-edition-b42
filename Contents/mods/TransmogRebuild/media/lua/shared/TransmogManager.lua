local function canBeTransmogged(scriptItem)
  if scriptItem.getScriptItem then
    scriptItem = scriptItem:getScriptItem()
  end

  local typeString = scriptItem:getTypeString()
  local isClothing = typeString == 'Clothing'

  if isClothing then
    return true
  end
end

local function applyTransmogToPlayer()
  local player = getPlayer();

  local inv = player:getInventory();
  for i = 0, inv:getItems():size() - 1 do
    local item = inv:getItems():get(i);

    if item ~= nil and canBeTransmogged(item) then
      -- Transmog Item
      print('CanBeTransmogged!')
    end
  end

  player:resetModelNextFrame();
end

Events.OnGameStart.Add(applyTransmogToPlayer);

--- AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA

local id = 0

local function requestTransmog(clothing)
  local donorScriptItem = clothing:getScriptItem()
  local donorClothingItemAsset = donorScriptItem:getClothingItemAsset()

  local receiverScriptItemName = 'TransmogRebuild.TransmogItem_'..id
  local receiverScriptItem = ScriptManager.instance:getItem(receiverScriptItemName)

  receiverScriptItem:setClothingItemAsset(donorClothingItemAsset)

  local player = getPlayer();

  local spawnedItem = player:getInventory():AddItem(receiverScriptItemName);

  spawnedItem:setName('Tmog - '..clothing:getName())

  local tmogData = ModData.getOrCreate("Transmog");
  tmogData[donorScriptItem:getFullName()] = receiverScriptItemName
  ModData.transmit("Transmog")

  id = id + 1
end

local TransmogContextMenu = function(player, context, items)
  local testItem = nil
  local clothing = nil
  for _, v in ipairs(items) do
    testItem = v;
    if not instanceof(v, "InventoryItem") then
      testItem = v.items[1];
    end
    if canBeTransmogged(testItem) then
      clothing = testItem;
    end
  end

  if tostring(#items) == "1" and clothing then
    local transmog = context:addOption("Transmog", clothing, requestTransmog);
  end

  return context
end


Events.OnFillInventoryObjectContextMenu.Add(TransmogContextMenu);
