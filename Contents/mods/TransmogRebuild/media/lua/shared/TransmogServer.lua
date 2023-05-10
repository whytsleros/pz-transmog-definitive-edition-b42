local Commands = {};
Commands.TransmogServer = {};

Commands.TransmogServer.RequestTransmogForItem = function(source, args)
    local username = source:getUsername();
    local itemFullName = args.fullName;

    TmogPrint("player [" .. username .. "] requested transmog for item: " .. itemFullName)

    local transmogData = ModData.getOrCreate("TransmogData");

    if transmogData[itemFullName] then
        --  return the existing transmog
        return
    end
end

Commands.TransmogServer.GenerateTransmogModData = function()
    TmogPrint('GenerateTransmogModData')
    local scriptManager = getScriptManager();
    local allItems = scriptManager:getAllItems()
    local transmogModData = TransmogRebuild.getTransmogModData()
    local itemToTransmogMap = transmogModData.itemToTransmogMap or {}
    local transmogToItemMap = transmogModData.transmogToItemMap or {}

    local serverTransmoggedItemCount = 0
    local size = allItems:size() - 1;
    for i = 0, size do
        local item = allItems:get(i);
        if TransmogRebuild.isItemTransmoggable(item) then
            local fullName = item:getFullName()
            serverTransmoggedItemCount = serverTransmoggedItemCount + 1
            if not itemToTransmogMap[fullName] then
                table.insert(transmogToItemMap, fullName)
                itemToTransmogMap[fullName] = 'TransmogRebuild.TransmogItem_'..#transmogToItemMap
            end
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

return Commands.TransmogServer
