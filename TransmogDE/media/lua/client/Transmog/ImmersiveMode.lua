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
  -- Guardamos el resultado original
  local result = nil
  pcall(function()
    result = old_ISInventoryPane_refreshContainer(self)
  end)

  -- Si no está activado el modo inmersivo, salimos
  if not SandboxVars or not SandboxVars.TransmogDE or not SandboxVars.TransmogDE.ImmersiveModeToggle then
    return result
  end

  -- Procesamos los ítems con protección contra errores
  pcall(function()
    ImmersiveMode.onRefreshContainer(self)
  end)

  return result
end

return ImmersiveMode
-- TODO: This could be improved