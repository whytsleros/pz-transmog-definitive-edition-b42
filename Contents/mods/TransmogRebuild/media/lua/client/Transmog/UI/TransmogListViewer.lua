TransmogListViewer = ISItemsListViewer:derive("TransmogListViewer");

function TransmogListViewer.OnOpenPanel()
  if TransmogListViewer.instance then
    TransmogListViewer.instance:close()
  end
  local modal = TransmogListViewer:new(50, 200, 850, 650)
  modal:initialise();
  modal:addToUIManager();
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
      if TransmogRebuild.isTransmoggable(item) then
        filteredItems:add(item)
      end
    end
    return filteredItems
  end
  -- Has to be set before init list, so it's passed to the ISItemsListTable
  self.isTransmogListViewer = true

  ISItemsListViewer.initList(self);
  getAllItems = backupGetAllItems;
end

function TransmogListViewer:prerender()
  local z = 20;
  self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b);
  self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b);
  local text = "Transmog List - Standard Mode"
  self:drawText(text, self.width/2 - (getTextManager():MeasureStringX(UIFont.Medium, text) / 2), z, 1,1,1,1, UIFont.Medium);
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

    self.datas:setOnMouseDoubleClick(self, function (item)
      HaloTextHelper.addText(getPlayer(), tostring(item), HaloTextHelper.getColorGreen())
    end);
  end
  
	return result
end
