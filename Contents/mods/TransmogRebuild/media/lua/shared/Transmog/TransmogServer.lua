local TransmogServer = {};

TransmogServer.GenerateTransmogModData = function()
    TmogPrint('Server TransmogModData')
    local scriptManager = getScriptManager();
    local allItems = scriptManager:getAllItems()
    local transmogModData = TransmogRebuild.getTransmogModData()
    local itemToTransmogMap = transmogModData.itemToTransmogMap or {}
    local transmogToItemMap = transmogModData.transmogToItemMap or {}

    local serverTransmoggedItemCount = 0
    local size = allItems:size() - 1;
    for i = 0, size do
        local item = allItems:get(i);
        if TransmogRebuild.isTransmoggable(item) then
            local fullName = item:getFullName()
            serverTransmoggedItemCount = serverTransmoggedItemCount + 1
            if not itemToTransmogMap[fullName] then
                table.insert(transmogToItemMap, fullName)
                itemToTransmogMap[fullName] = 'TransmogRebuild.TransmogItem_' .. #transmogToItemMap
            end
            TmogPrint(fullName..' -> '..tostring(itemToTransmogMap[fullName]))
        end
    end

    if #transmogToItemMap >= 5000 then
        TmogPrint("ERROR: Reached limit of transmoggable items")
    end

    ModData.add("TransmogModData", transmogModData)
    ModData.transmit("TransmogModData")

    TmogPrint('Transmogged items count: ' .. tostring(serverTransmoggedItemCount))

    return transmogModData
end

if isServer() then
    TmogPrint('Server Events set up')
    Events.OnServerStarted.Add(Commands.TransmogServer.GenerateTransmogModData)
end

return TransmogServer