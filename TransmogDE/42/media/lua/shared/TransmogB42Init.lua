-- Global TransmogB42 Compatibility Module
-- This ensures TransmogB42 is available globally before other files load

if not TransmogB42 then
    TransmogB42 = {}
    
    -- Version detection
    TransmogB42.isB42 = function()
        local version = getCore():getVersionNumber()
        return version and (version:find("42") ~= nil or version:find("Build 42") ~= nil)
    end
    
    -- Initialize compatibility flag
    TransmogB42.IS_BUILD_42 = TransmogB42.isB42()
    
    -- Debug function
    TransmogB42.debugPrint = function(msg)
        print("[TransmogDE] " .. tostring(msg))
    end
    
    -- Get worn items (B42 compatible)
    TransmogB42.getWornItems = function(character)
        if not character then return {} end
        
        if character.getWornItems then
            return character:getWornItems()
        elseif character.getItemContainer then
            -- Fallback for older versions
            local container = character:getItemContainer()
            if container then
                return container:getItems()
            end
        end
        return {}
    end
    
    -- Update character visual (B42 compatible)
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
            -- Fallback for older versions
            if character.dressInNamedOutfit then
                character:dressInNamedOutfit(character:getDisplayName())
            end
        end
    end
    
    TransmogB42.debugPrint("TransmogB42 Compatibility Module Initialized - Build 42: " .. tostring(TransmogB42.IS_BUILD_42))
end
