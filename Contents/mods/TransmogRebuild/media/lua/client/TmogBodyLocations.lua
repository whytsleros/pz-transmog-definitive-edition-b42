local function updateBodyLocations()
  local group = BodyLocations.getGroup("Human")

  local allLoc = group:getAllLocations();
  local allLocSize = allLoc:size() - 1
  group:getOrCreateLocation("Hide_Everything")

  for i = 0, allLocSize do
    local ID = allLoc:get(i):getId()
    group:setHideModel("Hide_Everything", ID)
  end

  group:getOrCreateLocation("TransmogLocation")
  group:setMultiItem("TransmogLocation", true)
end

Events.OnGameBoot.Add(updateBodyLocations)
