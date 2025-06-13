-- B42 Compatibility Module for Transmog
-- This module ensures compatibility with build 42 of the game, adapting functions and checks as necessary.

TransmogB42 = {}

-- Verify if the current game version is build 42
TransmogB42.isB42 = getCore():getVersionNumber():find("42") ~= nil

-- Adapt functions to b42 if necessary
if not sendVisual then
    sendVisual = function(character)
        if character and character:isLocalPlayer() then
            character:transmitUpdatedModelTextures()
        end
    end
end

if not sendClothing then
    sendClothing = function(character)
        if character and character:isLocalPlayer() then
            character:transmitUpdatedClothing()
        end
    end
end

return TransmogB42