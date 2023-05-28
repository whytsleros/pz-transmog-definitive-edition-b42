
local old_ISUnequipAction_perform = ISUnequipAction.perform
function ISUnequipAction:perform()
	local result = old_ISUnequipAction_perform(self)
	
  TransmogDE.triggerUpdate(self.character)

	return result
end
