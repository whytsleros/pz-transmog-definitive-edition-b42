-- local old_ISUnequipAction_perform = ISUnequipAction.perform
-- function ISUnequipAction:perform()
--   old_ISUnequipAction_perform(self)

--   if self.item:getCategory() ~= "Clothing" then
--     return
--   end

--   if self.item:getBodyLocation() ~= "TransmogLocation" then
--     return
--   end

--   local wornItems = self.character:getWornItems()
--   wornItems:remove(self.item)
-- end
