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
end

Events.OnGameStart.Add(updateBodyLocations)
