local isTransmoggable = require 'Transmog/utils/IsTransmogable'
local itemTransmogModData = require 'Transmog/utils/itemTransmogModData'
local refreshPlayerTransmog = require 'Transmog/utils/refreshPlayerTransmog'
local debug = require "Transmog/utils/debug"

-- Import B42 compatibility module
local TransmogB42 = require "TransmogB42Compatibility"

-- B42 compatible texture loading
local iconTexture = nil
if TransmogB42.IS_BUILD_42 then
  -- B42 might have different texture loading
  if getTexture then
    iconTexture = getTexture("media/ui/TransmogIcon.png")
  end
else
  iconTexture = getTexture("media/ui/TransmogIcon.png")
end

local TransmogInvContextMenu = {}

---@alias addOption fun(player:IsoPlayer,context:ISContextMenu,clothing:InventoryItem):any
---@alias addOptionClothingItem fun(player:IsoPlayer,context:ISContextMenu,clothing:InventoryItem, clothingItem:ClothingItem):any

---@type addOption
function TransmogInvContextMenu.addTransmogrify(player, context, clothing)
  local function onTransmogrify(scriptItem)
    local moddata = itemTransmogModData.get(clothing)
    moddata.transmogTo = scriptItem:getFullName()
    refreshPlayerTransmog(player)
    TransmogB42.debugPrint("Applied transmog: " .. tostring(scriptItem:getFullName()))
  end

  context:addOption("Transmogrify", clothing, function()
    TransmogListViewer.OnOpenPanel(clothing, onTransmogrify)
  end);
end

---@type addOption
function TransmogInvContextMenu.addHideItem(player, context, clothing)
  context:addOption("Hide Item", clothing, function()
    local moddata = itemTransmogModData.get(clothing)
    moddata.transmogTo = ''
    refreshPlayerTransmog(player)
    TransmogB42.debugPrint("Hidden item: " .. tostring(clothing:getName()))
  end);
end

---@type addOption
function TransmogInvContextMenu.addResetItem(player, context, clothing)
  context:addOption("Reset to Default", clothing, function()
    itemTransmogModData.reset(clothing)
    refreshPlayerTransmog(player)
    TransmogB42.debugPrint("Reset item: " .. tostring(clothing:getName()))
  end);
end

---@type addOptionClothingItem
function TransmogInvContextMenu.addChangeColor(player, context, clothing, clothingItem)
  -- B42 compatible color check
  local allowTint = false
  if TransmogB42.IS_BUILD_42 then
    -- B42 might have different tint checking
    if clothingItem.getAllowRandomTint then
      allowTint = clothingItem:getAllowRandomTint()
    elseif clothingItem.canBeRecolored then
      allowTint = clothingItem:canBeRecolored()
    end
  else
    allowTint = clothingItem:getAllowRandomTint()
  end
  
  if not allowTint then return end

  ---@param color ModDataColor
  local function onColorSelected(color)
    local moddata = itemTransmogModData.get(clothing)
    moddata.color = color
    refreshPlayerTransmog(player)
    TransmogB42.debugPrint("Changed color for: " .. tostring(clothing:getName()))
  end
  
  context:addOption("Change Colors", clothing, function()
    local modal = ColorPickerModal:new(clothing, player, onColorSelected);
    modal:initialise();
    modal:addToUIManager();
  end);
end

---@type addOptionClothingItem
function TransmogInvContextMenu.addChangeTexture(player, context, clothing, clothingItem)
  local textureChoices = nil
  
  -- B42 compatible texture choices
  if TransmogB42.IS_BUILD_42 then
    -- B42 might have different ways to get texture choices
    if clothingItem.getTextureChoices then
      textureChoices = clothingItem:getTextureChoices()
    elseif clothingItem.getAvailableTextures then
      textureChoices = clothingItem:getAvailableTextures()
    end
  else
    textureChoices = clothingItem:hasModel() and clothingItem:getTextureChoices() or clothingItem:getBaseTextures()
  end
  
  if not textureChoices or (textureChoices:size() <= 1) then
    return
  end

  local function onTextureSelected(textureIndex)
    local moddata = itemTransmogModData.get(clothing)
    moddata.texture = textureIndex
    refreshPlayerTransmog(player)
    TransmogB42.debugPrint("Changed texture for: " .. tostring(clothing:getName()) .. " to index: " .. tostring(textureIndex))
  end
  
  context:addOption("Change Texture", clothing, function()
    local modal = TexturePickerModal:new(clothing, player, textureChoices, onTextureSelected);
    modal:initialise();
    modal:addToUIManager();
  end);
end

---@param clothing InventoryItem
local function getTmogClothingItem(clothing)
  if not clothing then return nil end
  
  local moddata = itemTransmogModData.get(clothing)
  if not moddata or not moddata.transmogTo or moddata.transmogTo == "" then
    return nil
  end

  local tmogItem = nil
  local success = pcall(function()
    if TransmogB42.IS_BUILD_42 then
      -- B42 might have different item creation methods
      if InventoryItemFactory and InventoryItemFactory.CreateItem then
        tmogItem = InventoryItemFactory.CreateItem(moddata.transmogTo)
      elseif ItemManager and ItemManager.createItem then
        tmogItem = ItemManager.createItem(moddata.transmogTo)
      end
    else
      tmogItem = InventoryItemFactory.CreateItem(moddata.transmogTo)
    end
  end)

  if not success or not tmogItem then
    TransmogB42.debugPrint("Failed to create transmog item: " .. tostring(moddata.transmogTo))
    return nil
  end

  local tmogClothingItem = nil
  pcall(function()
    tmogClothingItem = tmogItem:getClothingItem()
  end)

  return tmogClothingItem
end

---@param playerIndex int
---@param context ISContextMenu
---@param items table
local function addEditTransmogItemOption(playerIndex, context, items)
  local playerObj = getSpecificPlayer(playerIndex)

  local testItem = nil
  ---@type InventoryItem
  local clothing = nil
  for _, v in ipairs(items) do
    testItem = v;
    if not instanceof(v, "InventoryItem") then
      testItem = v.items[1];
    end
    if isTransmoggable(testItem) then
      clothing = testItem;
    end
  end

  if #items ~= 1 or clothing == nil then
    return
  end

  local option = context:addOption("Transmog Menu");
  if iconTexture then
    option.iconTexture = iconTexture
  end
  
  -- B42 compatible perk checking
  local cantTransmog = false
  if TransmogB42.IS_BUILD_42 then
    -- B42 might have different perk system
    if playerObj.getPerkLevel and Perks and Perks.Tailoring then
      cantTransmog = playerObj:getPerkLevel(Perks.Tailoring) < (SandboxVars.TransmogDE and SandboxVars.TransmogDE.TailoringLevelRequirement or 0)
    end
  else
    cantTransmog = playerObj:getPerkLevel(Perks.Tailoring) < SandboxVars.TransmogDE.TailoringLevelRequirement
  end
  
  if cantTransmog then
    option.notAvailable = cantTransmog;
    local tooltip = ISInventoryPaneContextMenu.addToolTip();
    local requiredLevel = (SandboxVars.TransmogDE and SandboxVars.TransmogDE.TailoringLevelRequirement) or 0
    tooltip.description = getText("Tooltip_CantTransmogLowTailoring", requiredLevel);
    option.toolTip = tooltip;

    return
  end

  local menuContext = context:getNew(context);
  context:addSubMenu(option, menuContext);

  TransmogInvContextMenu.addTransmogrify(playerObj, menuContext, clothing)

  TransmogInvContextMenu.addHideItem(playerObj, menuContext, clothing)

  TransmogInvContextMenu.addResetItem(playerObj, menuContext, clothing)

  local tmogClothingItem = getTmogClothingItem(clothing)

  if tmogClothingItem then
    TransmogInvContextMenu.addChangeColor(playerObj, menuContext, clothing, tmogClothingItem)

    TransmogInvContextMenu.addChangeTexture(playerObj, menuContext, clothing, tmogClothingItem)
  end

  -- B42 compatible debug check
  local debugEnabled = false
  if isDebugEnabled then
    debugEnabled = isDebugEnabled()
  elseif getDebug then
    debugEnabled = getDebug()
  end
  
  if debugEnabled then
    menuContext:addOption("DBG: Print Tmog Data", clothing, function()
      debug.printTable(itemTransmogModData.get(clothing))
    end);
  end
end

-- B42 compatible event registration
local function registerContextMenuEvent()
  if Events and Events.OnFillInventoryObjectContextMenu then
    Events.OnFillInventoryObjectContextMenu.Add(addEditTransmogItemOption)
    TransmogB42.debugPrint("Registered context menu event")
  else
    TransmogB42.debugPrint("Warning: OnFillInventoryObjectContextMenu event not available")
  end
end

-- Initialize the context menu
registerContextMenuEvent()
