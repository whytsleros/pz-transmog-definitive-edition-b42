
local old_ISWearClothing_perform = ISWearClothing.perform
function ISWearClothing:perform()
	local result = old_ISWearClothing_perform(self)

	TransmogDE.triggerUpdate(self.character)

	return result
end
