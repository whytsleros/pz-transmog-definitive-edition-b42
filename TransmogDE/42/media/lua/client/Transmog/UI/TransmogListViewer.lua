require "ISUI/AdminPanel/ISItemsListViewer"
local isTransmoggable = require 'Transmog/utils/IsTransmogable'
local ImmersiveMode = require 'Transmog/ImmersiveMode'

TransmogListViewer = ISItemsListViewer:derive("TransmogListViewer");

function TransmogListViewer:new(x, y, width, height, itemToTmog, onItemSelected)
  local o = {}
  x = getCore():getScreenWidth() / 2 - (width / 2);
  y = getCore():getScreenHeight() / 2 - (height / 2);
  o = ISPanel:new(x, y, width, height);
  setmetatable(o, self)
  self.__index = self
  o.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 };
  o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.8 };
  o.width = width;
  o.height = height;
  o.moveWithMouse = true;
  -- These two must be set before init, so it's passed to the ISItemsListTable
  o.itemToTmog = itemToTmog;
  o.onItemSelected = onItemSelected;
  o.isTransmogListViewer = true
  TransmogListViewer.instance = o;
  return o;
end

---@param itemToTmog InventoryItem
---@param onItemSelected fun(scriptItem:Item):any
function TransmogListViewer.OnOpenPanel(itemToTmog, onItemSelected)
  if TransmogListViewer.instance then
    TransmogListViewer.instance:close()
  end
  local modal = TransmogListViewer:new(50, 200, 850, 650, itemToTmog, onItemSelected)
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
    
    -- Salir si no tenemos items para transmog
    if not self.itemToTmog then
      getAllItems = backupGetAllItems
      return allItems
    end
    
    for i = 0, allItems:size() - 1 do
      local item = allItems:get(i);
      -- Verificamos que el ítem es transmogrificable y está en cache en modo inmersivo
      if item and isTransmoggable(item) and ImmersiveMode.isItemInImmersiveModeCache(item) then
        -- Obtenemos ubicación corporal con verificación
        local itemBodyLocation = ""
        pcall(function() 
          itemBodyLocation = item:getBodyLocation() or "" 
        end)
        
        local targetBodyLocation = ""
        pcall(function() 
          targetBodyLocation = self.itemToTmog:getBodyLocation() or "" 
        end)
        
        local isSameBodyLocation = itemBodyLocation == targetBodyLocation
        
        if not SandboxVars.TransmogDE.LimitTransmogToSameBodyLocation then
          filteredItems:add(item)
        elseif isSameBodyLocation then
          filteredItems:add(item)
        end
      end
    end
    
    return filteredItems
  end

  pcall(function()
    ISItemsListViewer.initList(self)
  end)

  -- put the original function back in it's place
  getAllItems = backupGetAllItems;
end

function TransmogListViewer:prerender()
  local z = 20;
  self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
    self.backgroundColor.b);
  self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
    self.borderColor.b);
  local isImersiveMode = SandboxVars.TransmogDE.ImmersiveModeToggle
  local text = "Transmog List - "..(isImersiveMode and 'Immersive Mode' or 'Standard Mode')
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

    self.datas:setOnMouseDoubleClick(self, function (self, scriptItem)
      TransmogListViewer.instance.onItemSelected(scriptItem)
    end);
  end

  return result
end

