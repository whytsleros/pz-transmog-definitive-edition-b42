local isTransmoggable = require 'Transmog/utils/IsTransmogable'
local itemTransmogModData = require 'Transmog/utils/itemTransmogModData'
local refreshPlayerTransmog = require 'Transmog/utils/refreshPlayerTransmog'
local debug = require "Transmog/utils/debug"
local iconTexture = getTexture("media/ui/TransmogIcon.png")

local TransmogInvContextMenu = {}

---@alias addOption fun(player:IsoPlayer,context:ISContextMenu,clothing:InventoryItem):any
---@alias addOptionClothingItem fun(player:IsoPlayer,context:ISContextMenu,clothing:InventoryItem, clothingItem:ClothingItem):any

---@type addOption
function TransmogInvContextMenu.addTransmogrify(player, context, clothing)
  local function onTransmogrify(scriptItem)
    local moddata = itemTransmogModData.get(clothing)
    moddata.transmogTo = scriptItem:getFullName()
    refreshPlayerTransmog(player)
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
  end);
end

---@type addOption
function TransmogInvContextMenu.addResetItem(player, context, clothing)
  context:addOption("Reset to Default", clothing, function()
    itemTransmogModData.reset(clothing)
    refreshPlayerTransmog(player)
  end);
end

---@type addOptionClothingItem
function TransmogInvContextMenu.addChangeColor(player, context, clothing, clothingItem)
  if not clothingItem:getAllowRandomTint() then return end

  ---@param color ModDataColor
  local function onColorSelected(color)
    local moddata = itemTransmogModData.get(clothing)
    moddata.color = color
    refreshPlayerTransmog(player)
  end
  context:addOption("Change Colors", clothing, function()
    local modal = ColorPickerModal:new(clothing, player, onColorSelected);
    modal:initialise();
    modal:addToUIManager();
  end);
end

---@type addOptionClothingItem
function TransmogInvContextMenu.addChangeTexture(player, context, clothing, clothingItem)
  local textureChoices = clothingItem:hasModel() and clothingItem:getTextureChoices() or clothingItem:getBaseTextures()
  if not textureChoices or (textureChoices:size() < 1) then
    return
  end

  context:addOption("Change Texture", clothing, function()
    local modal = TexturePickerModal:new(clothing, player, textureChoices);
    modal:initialise();
    modal:addToUIManager();
  end);
end

---@Param clothing InventoryItem
local function getTmogClothingItem(clothing)
  local moddata = itemTransmogModData.get(clothing)

  local tmogItem = InventoryItemFactory.CreateItem(moddata.transmogTo)

  if not tmogItem then
    return
  end

  local tmogClothingItem = tmogItem:getClothingItem()

  if not tmogClothingItem then
    return
  end

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
  option.iconTexture = iconTexture

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

  if isDebugEnabled() then
    menuContext:addOption("DBG: Print Tmog Data", clothing, function()
      debug.printTable(itemTransmogModData.get(clothing))
    end);
  end
end


Events.OnFillInventoryObjectContextMenu.Add(addEditTransmogItemOption);
