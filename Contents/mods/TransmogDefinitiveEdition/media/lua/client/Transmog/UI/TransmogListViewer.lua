require "ISUI/AdminPanel/ISItemsListViewer"

TransmogListViewer = ISItemsListViewer:derive("TransmogListViewer");

function TransmogListViewer:new(x, y, width, height, itemToTmog)
  local o = {}
  x = getCore():getScreenWidth() / 2 - (width / 2);
  y = getCore():getScreenHeight() / 2 - (height / 2);
  o = ISItemsListViewer:new(x, y, width, height);
  setmetatable(o, self)
  self.__index = self
  o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
  o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 };
  o.width = width;
  o.height = height;
  o.moveWithMouse = true;
  -- These two must be set before init, so it's passed to the ISItemsListTable
  o.itemToTmog = itemToTmog;
  o.isTransmogListViewer = true
  TransmogListViewer.instance = o;
  return o;
end

function TransmogListViewer.OnOpenPanel(itemToTmog)
  if TransmogListViewer.instance then
    TransmogListViewer.instance:close()
  end
  local modal = TransmogListViewer:new(50, 200, 850, 650, itemToTmog)
  modal:initialise();
  modal:addToUIManager();
  modal:removeChild(modal.playerSelect);
  modal.instance:setKeyboardFocus()
end

function TransmogListViewer:initList()
  -- Hack to use as litte code as possible and keep backcompatibility
  -- getAllItems is used inside the original function (ISItemsListViewer.initList)
  local backupGetAllItems = getAllItems;
  getAllItems = function()
    local filteredItems = ArrayList:new()
    local allItems = backupGetAllItems()
    for i = 0, allItems:size() - 1 do
      local item = allItems:get(i);
      --The above code activates as soon as the item list viewer is activated.
      if TransmogDE.isTransmoggable(item) and TransmogDE.immersiveModeItemCheck(item) then
        filteredItems:add(item)
      end
    end
    return filteredItems
  end

  ISItemsListViewer.initList(self);

  -- put the original function back in it's place
  getAllItems = backupGetAllItems;
end

function TransmogListViewer:prerender()
  local z = 20;
  self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
    self.backgroundColor.b);
  self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
    self.borderColor.b);
  local text = "Transmog List - Standard Mode"
  self:drawText(text, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Medium, text) / 2), z, 1, 1, 1, 1,
    UIFont.Medium);
end

local old_ISItemsListTable_createChildren = ISItemsListTable.createChildren
function ISItemsListTable:createChildren()
  local result = old_ISItemsListTable_createChildren(self)

  if self.viewer.isTransmogListViewer then
    self:removeChild(self.buttonAdd1);
    self:removeChild(self.buttonAdd2);
    self:removeChild(self.buttonAdd5);
    self:removeChild(self.buttonAddMultiple);
    self:removeChild(self.filters);

    self.datas:setOnMouseDoubleClick(self, self.sendItemToTransmog);
  end

  return result
end

function ISItemsListTable:sendItemToTransmog(scriptItem)
  print('sendItemToTransmog'..tostring(scriptItem))
  local text = 'Transmogged to' .. getItemNameFromFullType(scriptItem:getFullName())
  HaloTextHelper.addText(getPlayer(), text, HaloTextHelper.getColorGreen())
  TransmogDE.setItemTransmog(self.viewer.itemToTmog, scriptItem)
  TransmogDE.resetClothingChild(self.viewer.itemToTmog)
end
