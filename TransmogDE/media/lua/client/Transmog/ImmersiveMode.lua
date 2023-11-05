local isTransmoggable = require 'Transmog/utils/IsTransmogable'

local ImmersiveMode = {}

function ImmersiveMode.getModData()
  return ModData.getOrCreate('TransmogImmersiveModeData')
end

function ImmersiveMode.isItemInImmersiveModeCache(item)
  if not SandboxVars.TransmogDE.ImmersiveModeToggle then
    return true
  end
  return ImmersiveMode.getModData()[item:getFullName()] == true
end

function ImmersiveMode.onRefreshContainer(invPane)
  local immersiveModeData = ImmersiveMode.getModData()
  for _, container in pairs(invPane.itemindex) do
    local item = container.items[1]
    if container ~= nil and isTransmoggable(item) then
      immersiveModeData[item:getScriptItem():getFullName()] = true
    end
  end
end

local old_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
  local result = old_ISInventoryPane_refreshContainer(self)

  if not SandboxVars.TransmogDE.ImmersiveModeToggle then
    return result
  end

  ImmersiveMode.onRefreshContainer(self)

  return result
end

return ImmersiveMode
-- TODO: Very inefficient, run this only on the selected container