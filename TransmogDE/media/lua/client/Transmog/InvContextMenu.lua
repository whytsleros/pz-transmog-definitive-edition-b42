local isTransmoggable = require 'Transmog/utils/IsTransmogable'
local itemTransmogModData = require 'Transmog/utils/itemTransmogModData'
local refreshPlayerTransmog = require 'Transmog/utils/refreshPlayerTransmog'
local debug = require "Transmog/utils/debug"

local iconTexture = getTexture("media/ui/TransmogIcon.png")

local addEditTransmogItemOption = function(playerIdx, context, items)
  local playerObj = getSpecificPlayer(playerIdx)
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

  if isDebugEnabled() then
    menuContext:addOption("Print Tmog Data", clothing, function()
      debug.printTable(itemTransmogModData.get(clothing))
    end);
  end

  menuContext:addOption("Transmogrify", clothing, function()
    local function onTransmogrify(scriptItem)
      local moddata = itemTransmogModData.get(clothing)
      moddata.transmogTo = scriptItem:getFullName()
      refreshPlayerTransmog(playerObj)
    end

    TransmogListViewer.OnOpenPanel(clothing, onTransmogrify)
  end);

  menuContext:addOption("Hide Item", clothing, function()
    local moddata = itemTransmogModData.get(clothing)
    moddata.transmogTo = ''
    refreshPlayerTransmog(playerObj)
  end);

  menuContext:addOption("Reset to Default", clothing, function()
    itemTransmogModData.reset(clothing)
    refreshPlayerTransmog(playerObj)
  end);

  local moddata = itemTransmogModData.get(clothing)

  local tmogItem = InventoryItemFactory.CreateItem(moddata.transmogTo)

  local tmogClothingItem = tmogItem:getClothingItem()

  if tmogClothingItem == nil then
    return
  end

  if tmogClothingItem:getAllowRandomTint() then
    ---@param color ModDataColor
    local function onColorSelected(color)
      local moddata = itemTransmogModData.get(clothing)
      moddata.color = color
      refreshPlayerTransmog(playerObj)
    end
    menuContext:addOption("Change Colors", clothing, function()
      local modal = ColorPickerModal:new(clothing, playerObj, onColorSelected);
      modal:initialise();
      modal:addToUIManager();
    end);
  end

  local textureChoices = tmogClothingItem:hasModel()
      and tmogClothingItem:getTextureChoices() or tmogClothingItem:getBaseTextures()

  if textureChoices and (textureChoices:size() > 1) then
    menuContext:addOption("Change Texture", clothing, function()
      local modal = TexturePickerModal:new(clothing, playerObj, textureChoices);
      modal:initialise();
      modal:addToUIManager();
    end);
  end
end


Events.OnFillInventoryObjectContextMenu.Add(addEditTransmogItemOption);
