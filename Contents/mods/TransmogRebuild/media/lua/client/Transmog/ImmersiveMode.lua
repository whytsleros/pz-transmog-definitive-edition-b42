
local old_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
  local result = old_ISInventoryPane_refreshContainer(self)

  if SandboxVars.TransmogRebuild.ImmersiveModeToggle ~= true then
    return result
  end

  for _, container in pairs(self.itemindex) do
    local item = container.items[1]
    if container ~= nil and TransmogRebuild.isTransmoggable(item) then
      TransmogRebuild.getImmersiveModeData()[item:getScriptItem():getFullName()] = true
    end
  end

  return result
end
