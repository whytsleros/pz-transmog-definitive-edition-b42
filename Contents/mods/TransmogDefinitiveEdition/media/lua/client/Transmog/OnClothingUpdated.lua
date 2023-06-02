local function wearHideEverything(player)
	local playerInv = player:getInventory()

	local hideItem = playerInv:FindAndReturn("TransmogDE.Hide_Everything");
	if not hideItem then
		TmogPrint('Hide_Everything is missing, lets add it')
		hideItem = player:getInventory():AddItem('TransmogDE.Hide_Everything');
	end
	if not hideItem:isWorn() then
		TmogPrint('Hide_Everything is not equipped, lets wear it')
		player:setWornItem(hideItem:getBodyLocation(), hideItem)
		hideItem:setFavorite(true)
	end

	TmogPrint('wearHideEverything - Done')
end

local function wearTransmogItems(player)
	local wornItems = player:getWornItems()
	local playerInv = player:getInventory()

	local toWear = {}
	local toRemove = {}
	for i = 0, wornItems:size() - 1 do
		local item = wornItems:getItemByIndex(i);
		if item and TransmogDE.isTransmoggable(item) and not TransmogDE.getTransmogChild(item) then
			-- check if it has an existing tmogitem
			-- if not create a new tmog item, and bind it using the parent item id
			local tmogItem = TransmogDE.createTransmogItem(item, player)
			table.insert(toWear, tmogItem)
		end
		if item and TransmogDE.isTransmogItem(item) and not item:hasTag("Hide_Everything") then
			-- check if it still has a worn parent
			local tmogParentId = item:getModData()['TransmogParent']
			local parentItem = tmogParentId and playerInv:getItemById(tmogParentId)
			-- use isEquipped, isWorn is only for clothing, does not include backpacks
			if not tmogParentId or not parentItem or not parentItem:isEquipped() then
				-- parent either does not exist anymore, or it's unequipped, or it was never set
				-- in in these cases, mark item to remove
				table.insert(toRemove, item)
			end
		end
	end

	for _, tmogItem in ipairs(toWear) do
		player:setWornItem(tmogItem:getBodyLocation(), tmogItem)
	end

	for _, tmogItem in ipairs(toRemove) do
		wornItems:remove(tmogItem);
		playerInv:Remove(tmogItem);
	end

	player:resetModelNextFrame();

	sendClothing(player);
	TmogPrint('wearTransmogItems, to wear:', #toWear, ' to remove:', #toRemove)
end

local function applyTransmogToPlayerItems(player)
	local player = player or getPlayer() -- getSpecificPlayer(playerNum);
	wearHideEverything(player);
	wearTransmogItems(player)
end

LuaEventManager.AddEvent("ApplyTransmogToPlayerItems");

Events.ApplyTransmogToPlayerItems.Add(applyTransmogToPlayerItems);

local function onClothingUpdated(player)
	local hotbar = getPlayerHotbar(player:getPlayerNum());
	if hotbar == nil then return end -- player is dead

	-- I need to use the same check as the ISHotbar otherwise it shits itself,
	-- and it will randomly start spamming `OnClothingUpdated`, dunno why, but this seems to fix it
	local itemsChanged = hotbar:compareWornItems()
	if not itemsChanged then
		return
	end

	applyTransmogToPlayerItems(player)
end

Events.OnClothingUpdated.Add(onClothingUpdated)
