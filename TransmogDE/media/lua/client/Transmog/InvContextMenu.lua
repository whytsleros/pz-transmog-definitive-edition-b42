local isTransmoggable = require 'Transmog/Utils/IsTransmogable'
local getItemTransmogModData = require 'Transmog/Utils/getItemTransmogModData'

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

  menuContext:addOption("Transmog to Base.Jacket_Black", clothing, function()
    local moddata = getItemTransmogModData(clothing)
    moddata.transmogTo = 'Base.Jacket_Black'
  end);

  -- menuContext:addOption("Transmogrify", clothing, function()
  --   TransmogListViewer.OnOpenPanel(clothing)
  --   -- TransmogDE.triggerUpdate()
  -- end);

  -- menuContext:addOption("Hide Item", clothing, function()
  --   -- TransmogDE.setClothingHidden(clothing)
  --   -- TransmogDE.triggerUpdate()
  -- end);

  -- menuContext:addOption("Reset to Default", clothing, function()
  --   -- TransmogDE.setItemToDefault(clothing)
  --   -- TransmogDE.triggerUpdate()
  -- end);

  -- local transmogTo = TransmogDE.getItemTransmogModData(clothing).transmogTo
  -- if not transmogTo then
  --   return
  -- end

  -- local tmogScriptItem = ScriptManager.instance:getItem(transmogTo)
  -- if not tmogScriptItem then
  --   return context
  -- end

  -- local tmogClothingItemAsset = TransmogDE.getClothingItemAsset(tmogScriptItem)
  -- if tmogClothingItemAsset:getAllowRandomTint() then
  --   menuContext:addOption("Change Color", clothing, function()
  --     local modal = ColorPickerModal:new(clothing, playerObj);
  --     modal:initialise();
  --     modal:addToUIManager();
  --   end);
  -- end

  -- local textureChoices =
  --     tmogClothingItemAsset:hasModel() and tmogClothingItemAsset:getTextureChoices()
  --     or tmogClothingItemAsset:getBaseTextures()

  -- if textureChoices and (textureChoices:size() > 1) then
  --   menuContext:addOption("Change Texture", clothing, function()
  --     local modal = TexturePickerModal:new(clothing, playerObj, textureChoices);
  --     modal:initialise();
  --     modal:addToUIManager();
  --   end);
  -- end
end


Events.OnFillInventoryObjectContextMenu.Add(addEditTransmogItemOption);
