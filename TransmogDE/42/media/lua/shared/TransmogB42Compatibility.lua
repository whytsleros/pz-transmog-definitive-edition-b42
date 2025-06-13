-- B42 Compatibility Module for Transmog
-- This module ensures compatibility with build 42 of the game, adapting functions and checks as necessary.

TransmogB42 = {}

-- Verify if the current game version is build 42
TransmogB42.isB42 = function()
    local version = getCore():getVersionNumber()
    return version and (version:find("42") ~= nil or version:find("Build 42") ~= nil)
end

-- Initialize compatibility flag
TransmogB42.IS_BUILD_42 = TransmogB42.isB42()

-- B42 specific clothing update functions
TransmogB42.updateCharacterVisual = function(character)
    if not character then return end
    
    if TransmogB42.IS_BUILD_42 then
        -- Build 42 specific functions
        if character.transmitUpdatedModelTextures then
            character:transmitUpdatedModelTextures()
        end
        if character.transmitUpdatedClothing then
            character:transmitUpdatedClothing()
        end
        if character.updateAppearance then
            character:updateAppearance()
        end
    else
        -- Fallback for other builds
        if sendVisual then
            sendVisual(character)
        end
        if sendClothing then
            sendClothing(character)
        end
    end
end

-- B42 compatible function to get clothing items
TransmogB42.getWornItems = function(character)
    if not character then return {} end
    
    local items = {}
    if TransmogB42.IS_BUILD_42 then
        -- Build 42 method
        local wornItems = character:getWornItems()
        if wornItems then
            for i = 0, wornItems:size() - 1 do
                local item = wornItems:get(i)
                if item then
                    table.insert(items, item)
                end
            end
        end
    else
        -- Legacy method
        local playerInv = character:getInventory()
        local allItems = playerInv:getAllItems()
        for i = 0, allItems:size() - 1 do
            local item = allItems:get(i)
            if item and character:isWearing(item) then
                table.insert(items, item)
            end
        end
    end
    
    return items
end

-- Adapt legacy functions for backward compatibility
if not sendVisual then
    sendVisual = function(character)
        TransmogB42.updateCharacterVisual(character)
    end
end

if not sendClothing then
    sendClothing = function(character)
        TransmogB42.updateCharacterVisual(character)
    end
end

-- Debug function
TransmogB42.debugPrint = function(message)
    if TransmogB42.IS_BUILD_42 then
        print("[TransmogDE B42] " .. tostring(message))
    end
end

TransmogB42.debugPrint("Transmog B42 Compatibility Module loaded. Build 42: " .. tostring(TransmogB42.IS_BUILD_42))

return TransmogB42