-- local function canBeTransmogged(scriptItem)
--   if scriptItem.getScriptItem then
--     scriptItem = scriptItem:getScriptItem()
--   end

--   local typeString = scriptItem:getTypeString()
--   local isClothing = typeString == 'Clothing'

--   if isClothing then
--     return true
--   end
-- end

-- local function applyTransmogToPlayer()
--   local player = getPlayer();

--   local inv = player:getInventory();
--   for i = 0, inv:getItems():size() - 1 do
--     local item = inv:getItems():get(i);

--     if item ~= nil and canBeTransmogged(item) then
--       -- Transmog Item
--       print('CanBeTransmogged!')
--     end
--   end

--   player:resetModelNextFrame();
-- end

-- Events.OnGameStart.Add(applyTransmogToPlayer);