local group = BodyLocations.getGroup("Human")
group:getOrCreateLocation("TransmogLocation")
group:setMultiItem("TransmogLocation", true)
group:getOrCreateLocation("Hide_Everything")

local function updateBodyLocations()
  local group = BodyLocations.getGroup("Human")

  local allLoc = group:getAllLocations();
  local allLocSize = allLoc:size() - 1

  for i = 0, allLocSize do
    local ID = allLoc:get(i):getId()

    if tostring(ID) ~= "TransmogLocation" then
      group:setHideModel("Hide_Everything", ID)
    end
  end
end

Events.OnGameStart.Add(updateBodyLocations)
