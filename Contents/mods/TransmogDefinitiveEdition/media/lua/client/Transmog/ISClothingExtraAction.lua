local old_ISClothingExtraAction_perform = ISClothingExtraAction.perform
function ISClothingExtraAction:perform()
	local result = old_ISClothingExtraAction_perform(self)

  TmogPrint('ISClothingExtraAction:perform()')
  TransmogDE.triggerUpdate(self.character)

  return result
end

local old_ISClothingExtraAction_createItem = ISClothingExtraAction.createItem
function ISClothingExtraAction:createItem(item, itemType)
	local newItem = old_ISClothingExtraAction_createItem(self, item, itemType)

  TransmogDE.setItemToDefault(newItem)

	return newItem
end
