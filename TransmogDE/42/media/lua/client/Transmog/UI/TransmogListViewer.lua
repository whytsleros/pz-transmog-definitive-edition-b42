require "ISUI/AdminPanel/ISItemsListViewer"
local isTransmoggable = require 'Transmog/utils/IsTransmogable'
local ImmersiveMode = require 'Transmog/ImmersiveMode'

-- Import B42 compatibility module
local TransmogB42 = require "TransmogB42Compatibility"

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
  
  TransmogB42.debugPrint("TransmogListViewer created")
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
  
  -- B42 compatible player select removal
  if modal.playerSelect then
    modal:removeChild(modal.playerSelect);
  end
  
  modal.instance:setKeyboardFocus()
  TransmogB42.debugPrint("TransmogListViewer panel opened")
end

function TransmogListViewer:initList()
  -- Hack to use as little code as possible and keep backward compatibility
  -- getAllItems is used inside the original function (ISItemsListViewer.initList)
  local backupGetAllItems = getAllItems;
  
  getAllItems = function()
    local filteredItems = nil
    
    -- B42 compatible ArrayList creation
    if TransmogB42.IS_BUILD_42 then
      if ArrayList and ArrayList.new then
        filteredItems = ArrayList:new()
      elseif ArrayList then
        filteredItems = ArrayList()
      end
    else
      filteredItems = ArrayList:new()
    end
    
    if not filteredItems then
      TransmogB42.debugPrint("Warning: Could not create ArrayList")
      getAllItems = backupGetAllItems
      return backupGetAllItems()
    end
    
    local allItems = backupGetAllItems()
    
    -- Exit if we don't have items for transmog
    if not self.itemToTmog then
      getAllItems = backupGetAllItems
      return allItems
    end
    
    for i = 0, allItems:size() - 1 do
      local item = allItems:get(i);
      
      -- Verify that the item is transmoggable and is in cache in immersive mode
      if item and isTransmoggable(item) and ImmersiveMode.isItemInImmersiveModeCache(item) then
        -- Get body location with verification
        local itemBodyLocation = ""
        local success1 = pcall(function() 
          if item.getBodyLocation then
            itemBodyLocation = item:getBodyLocation() or "" 
          end
        end)
        
        local targetBodyLocation = ""
        local success2 = pcall(function() 
          if self.itemToTmog.getBodyLocation then
            targetBodyLocation = self.itemToTmog:getBodyLocation() or "" 
          end
        end)
        
        if not success1 or not success2 then
          TransmogB42.debugPrint("Warning: Could not get body location for item comparison")
        end
        
        local isSameBodyLocation = itemBodyLocation == targetBodyLocation
        
        -- B42 compatible sandbox variable check
        local limitToSameLocation = false
        if SandboxVars and SandboxVars.TransmogDE and SandboxVars.TransmogDE.LimitTransmogToSameBodyLocation then
          limitToSameLocation = SandboxVars.TransmogDE.LimitTransmogToSameBodyLocation
        end
        
        if not limitToSameLocation then
          filteredItems:add(item)
        elseif isSameBodyLocation then
          filteredItems:add(item)
        end
      end
    end
    
    TransmogB42.debugPrint("Filtered " .. filteredItems:size() .. " transmoggable items")
    return filteredItems
  end

  local success = pcall(function()
    ISItemsListViewer.initList(self)
  end)
  
  if not success then
    TransmogB42.debugPrint("Warning: Failed to initialize ISItemsListViewer")
  end

  -- put the original function back in its place
  getAllItems = backupGetAllItems;
end

function TransmogListViewer:prerender()
  local z = 20;
  self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g,
    self.backgroundColor.b);
  self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g,
    self.borderColor.b);
  
  -- B42 compatible sandbox variable check
  local isImmersiveMode = false
  if SandboxVars and SandboxVars.TransmogDE and SandboxVars.TransmogDE.ImmersiveModeToggle then
    isImmersiveMode = SandboxVars.TransmogDE.ImmersiveModeToggle
  end
  
  local text = "Transmog List - "..(isImmersiveMode and 'Immersive Mode' or 'Standard Mode')
  
  -- B42 compatible text rendering
  if getTextManager and UIFont and UIFont.Medium then
    self:drawText(text, self.width / 2 - (getTextManager():MeasureStringX(UIFont.Medium, text) / 2), z, 1, 1, 1, 1,
      UIFont.Medium);
  else
    -- Fallback text rendering
    self:drawText(text, self.width / 2 - 100, z, 1, 1, 1, 1);
  end
end

-- B42 compatible ISItemsListTable modification
local old_ISItemsListTable_createChildren = ISItemsListTable.createChildren
function ISItemsListTable:createChildren()
  local result = old_ISItemsListTable_createChildren(self)

  if self.viewer and self.viewer.isTransmogListViewer then
    -- B42 compatible button removal
    if self.buttonAdd1 then self:removeChild(self.buttonAdd1); end
    if self.buttonAdd2 then self:removeChild(self.buttonAdd2); end
    if self.buttonAdd5 then self:removeChild(self.buttonAdd5); end
    if self.buttonAddMultiple then self:removeChild(self.buttonAddMultiple); end
    if self.filters then self:removeChild(self.filters); end

    if self.datas and self.datas.setOnMouseDoubleClick then
      self.datas:setOnMouseDoubleClick(self, function (self, scriptItem)
        if TransmogListViewer.instance and TransmogListViewer.instance.onItemSelected then
          TransmogListViewer.instance.onItemSelected(scriptItem)
          TransmogB42.debugPrint("Item selected: " .. tostring(scriptItem and scriptItem:getName() or "unknown"))
        end
      end);
    end
  end

  return result
end

