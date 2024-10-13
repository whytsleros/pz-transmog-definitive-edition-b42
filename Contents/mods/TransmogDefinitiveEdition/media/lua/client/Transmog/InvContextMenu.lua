local iconTexture = getTexture("media/ui/TransmogIcon.png")
local textMenu = getText("IGUI_TransmogDE_Context_Menu")
local textTransmogrify = getText("IGUI_TransmogDE_Context_Transmogrify")
local textHide = getText("IGUI_TransmogDE_Context_Hide")
local textDefault = getText("IGUI_TransmogDE_Context_Default")
local textColor = getText("IGUI_TransmogDE_Context_Color")
local textTexture = getText("IGUI_TransmogDE_Context_Texture")

local addEditTransmogItemOption = function(player, context, items)
  local playerObj = getSpecificPlayer(player)
  local testItem = nil
  local clothing = nil
  for _, v in ipairs(items) do
    testItem = v;
    if not instanceof(v, "InventoryItem") then
      testItem = v.items[1];
    end
    if TransmogDE.isTransmoggable(testItem) then
      clothing = testItem;
    end
  end

  if tostring(#items) == "1" and clothing then
    local option = context:addOption(textMenu);
    option.iconTexture = iconTexture
    local menuContext = context:getNew(context);
    context:addSubMenu(option, menuContext);

    menuContext:addOption(textTransmogrify, clothing, function()
      TransmogListViewer.OnOpenPanel(clothing)
      TransmogDE.triggerUpdate()
    end);

    menuContext:addOption(textHide, clothing, function()
      TransmogDE.setClothingHidden(clothing)
      TransmogDE.triggerUpdate()
    end);

		menuContext:addOption(textDefault, clothing, function()
      TransmogDE.setItemToDefault(clothing)
      TransmogDE.triggerUpdate()
    end);

    local transmogTo = TransmogDE.getItemTransmogModData(clothing).transmogTo
    if not transmogTo then
      return
    end

    local tmogScriptItem = ScriptManager.instance:getItem(transmogTo)
    if not tmogScriptItem then
      return context
    end

    local tmogClothingItemAsset = TransmogDE.getClothingItemAsset(tmogScriptItem)
    if tmogClothingItemAsset:getAllowRandomTint() then
      menuContext:addOption(textColor, clothing, function()
        local modal = ColorPickerModal:new(clothing, playerObj);
        modal:initialise();
        modal:addToUIManager();
      end);
    end

    local textureChoices =
        tmogClothingItemAsset:hasModel() and tmogClothingItemAsset:getTextureChoices()
        or tmogClothingItemAsset:getBaseTextures()

    -- TmogPrint('clothing', clothing)
    -- TmogPrint('clothing.getClothingItem', clothing:getClothingItem())
    -- TmogPrint('transmogTo', transmogTo)
    -- TmogPrint('tmogClothingItemAsset', tmogClothingItemAsset)
    -- TmogPrint('hasModel()', tmogClothingItemAsset:hasModel())
    -- TmogPrint('getTextureChoices()', tmogClothingItemAsset:getTextureChoices())
    -- TmogPrint('getBaseTextures()', tmogClothingItemAsset:getBaseTextures())
    if textureChoices and (textureChoices:size() > 1) then
      menuContext:addOption(textTexture, clothing, function()
        local modal = TexturePickerModal:new(clothing, playerObj, textureChoices);
        modal:initialise();
        modal:addToUIManager();
      end);
    end
  end

  return context
end


Events.OnFillInventoryObjectContextMenu.Add(addEditTransmogItemOption);
