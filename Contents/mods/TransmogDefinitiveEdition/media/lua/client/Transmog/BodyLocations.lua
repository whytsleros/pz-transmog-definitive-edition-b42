local group = BodyLocations.getGroup("Human")
group:getOrCreateLocation("TransmogLocation")
group:setMultiItem("TransmogLocation", true)
group:getOrCreateLocation("Hide_Everything")

local function updateBodyLocations()
	local group = BodyLocations.getGroup("Human")

	local locations = group:getAllLocations();
	local locationsSize = locations:size() - 1

	for i = 0, locationsSize do
		local bodyLocationId = locations:get(i):getId()

		if TransmogDE.isTransmoggableBodylocation(tostring(bodyLocationId)) then
			group:setHideModel("Hide_Everything", bodyLocationId)
		end
	end

	local containerLocations = {}
	local allItems = getScriptManager():getAllItems()
	for i = 1, allItems:size() do
		local item = allItems:get(i - 1)
		-- If can be canBeEquipped but not getBodyLocation, then it's a backpack!
		-- So, we force the backpacks to have a BodyLocation, so that it can be hidden by pz using the group:setHideModel! 
		if item:getType() == Type.Container and item:InstanceItem(nil):canBeEquipped() ~= "" and item:getBodyLocation() == "" then
			containerLocations[item:InstanceItem(nil):canBeEquipped()] = true
			item:DoParam("BodyLocation = Back")
		end
	end

	for key, _ in pairs(containerLocations) do
		TmogPrint('canBeEquipped', key)
	end

	-- Based on fur.lua from: https://steamcommunity.com/sharedfiles/filedetails/?id=2893930681
	local humanGroup = BodyLocations.getGroup("Human");
	local tmogLocation = humanGroup:getOrCreateLocation("TransmogLocation");
	local list = getClassFieldVal(humanGroup, getClassField(humanGroup, 1));
	list:remove(tmogLocation)
	-- Put before the backpacks to avoid redering issues
	local index = humanGroup:indexOf("Back") - 1;
	list:add(index, tmogLocation);

	local hideEverythingLocation = humanGroup:getOrCreateLocation("Hide_Everything");
	list:remove(hideEverythingLocation)
	local index = humanGroup:indexOf("Wound");
	list:add(index, hideEverythingLocation);
end

Events.OnGameStart.Add(updateBodyLocations)
