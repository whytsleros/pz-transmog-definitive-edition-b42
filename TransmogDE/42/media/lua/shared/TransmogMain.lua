-- Main initialization file for Transmog Definitive Edition Build 42
-- This file coordinates the loading and initialization of all mod components

print("Loading Transmog Definitive Edition for Build 42...")

-- Import the B42 compatibility module first
local TransmogB42 = require "TransmogB42Compatibility"

-- Verify Build 42 compatibility
if not TransmogB42.IS_BUILD_42 then
    print("Warning: Transmog DE B42 version loaded but Build 42 not detected!")
    print("Current version: " .. tostring(getCore():getVersionNumber()))
end

-- Global mod table
TransmogDE = TransmogDE or {}

-- Mod information
TransmogDE.VERSION = "2.0.0"
TransmogDE.BUILD_TARGET = "42"
TransmogDE.IS_B42_COMPATIBLE = TransmogB42.IS_BUILD_42

-- Initialize mod components
TransmogDE.init = function()
    TransmogB42.debugPrint("Initializing Transmog DE for Build 42")
    
    -- Verify essential systems are available
    if not Events then
        print("ERROR: Events system not available!")
        return false
    end
    
    if not getPlayer then
        print("ERROR: Player system not available!")
        return false
    end
    
    -- Initialize sandbox variables with B42 compatibility
    TransmogDE.initSandboxVars()
    
    -- Initialize immersive mode
    if ImmersiveMode then
        TransmogDE.initImmersiveMode()
    end
    
    TransmogB42.debugPrint("Transmog DE initialization complete")
    return true
end

-- Initialize sandbox variables with B42 compatibility
TransmogDE.initSandboxVars = function()
    if not SandboxVars then
        TransmogB42.debugPrint("Warning: SandboxVars not available")
        return
    end
    
    -- Ensure our sandbox options exist with defaults
    SandboxVars.TransmogDE = SandboxVars.TransmogDE or {}
    
    if SandboxVars.TransmogDE.ImmersiveModeToggle == nil then
        SandboxVars.TransmogDE.ImmersiveModeToggle = false
    end
    
    if SandboxVars.TransmogDE.LimitTransmogToSameBodyLocation == nil then
        SandboxVars.TransmogDE.LimitTransmogToSameBodyLocation = false
    end
    
    if SandboxVars.TransmogDE.TailoringLevelRequirement == nil then
        SandboxVars.TransmogDE.TailoringLevelRequirement = 0
    end
    
    TransmogB42.debugPrint("Sandbox variables initialized")
end

-- Initialize immersive mode with B42 compatibility
TransmogDE.initImmersiveMode = function()
    if not ImmersiveMode then
        TransmogB42.debugPrint("Warning: ImmersiveMode module not available")
        return
    end
    
    -- Add any B42 specific immersive mode initialization here
    TransmogB42.debugPrint("Immersive mode initialized")
end

-- Body location management for B42
TransmogDE.bodyLocationsToIgnore = {}

TransmogDE.addBodyLocationToIgnore = function(bodyLocation)
    if bodyLocation and bodyLocation ~= "" then
        TransmogDE.bodyLocationsToIgnore[bodyLocation] = true
        TransmogB42.debugPrint("Added body location to ignore: " .. tostring(bodyLocation))
    end
end

-- Check if a body location should be ignored
TransmogDE.shouldIgnoreBodyLocation = function(bodyLocation)
    return TransmogDE.bodyLocationsToIgnore[bodyLocation] == true
end

-- Event handlers for B42
local function onGameStart()
    TransmogDE.init()
end

local function onPlayerConnect(playerIndex, player)
    if player and player:isLocalPlayer() then
        TransmogB42.debugPrint("Local player connected")
        -- Add any player-specific initialization here
    end
end

-- Register events with B42 compatibility
if Events then
    if Events.OnGameStart then
        Events.OnGameStart.Add(onGameStart)
        TransmogB42.debugPrint("Registered OnGameStart event")
    end
    
    if Events.OnCreatePlayer then
        Events.OnCreatePlayer.Add(onPlayerConnect)
        TransmogB42.debugPrint("Registered OnCreatePlayer event")
    end
    
    -- B42 might have additional events
    if TransmogB42.IS_BUILD_42 then
        if Events.OnPlayerFullyConnected then
            Events.OnPlayerFullyConnected.Add(onPlayerConnect)
            TransmogB42.debugPrint("Registered B42 OnPlayerFullyConnected event")
        end
    end
else
    print("ERROR: Could not register Transmog DE events - Events system not available")
end

TransmogB42.debugPrint("TransmogMain.lua loaded successfully")

-- Make global functions available for mod compatibility
if getActivatedMods and getActivatedMods():contains("TransmogDE") then
    TransmogB42.debugPrint("Transmog DE detected in activated mods list")
end

return TransmogDE
