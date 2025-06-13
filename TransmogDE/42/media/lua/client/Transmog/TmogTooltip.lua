local isTransmoggable = require 'Transmog/utils/IsTransmogable'
local itemTransmogModData = require 'Transmog/utils/itemTransmogModData'

local colors = {
  r = 1,
  g = 0.6,
  b = 0
}

-- Inside java\inventory\InventoryItem.java there is `DoTooltip`, and 5 is the constant for the padding X and Y
-- Code ref:
-- int var3 = var1.getLineSpacing();
-- int var4 = 5;
local paddingConst = 5

local old_render = ISToolTipInv.render
function ISToolTipInv:render()
  if not self.item or not isTransmoggable(self.item) then
    return old_render(self)
  end

  local itemModData = itemTransmogModData.get(self.item)
  local name = itemModData.transmogTo ~= '' and getItemNameFromFullType(itemModData.transmogTo) or "Hidden"

  local textRows = {
    'Transmogged to: ',
    ' - ' .. name
  }
  local font = UIFont[getCore():getOptionTooltipFont()];
  -- set height
  local lineSpacing = self.tooltip:getLineSpacing()
  local height = self.tooltip:getHeight() - paddingConst
  local newHeight = (height + #textRows * lineSpacing) + paddingConst

  local old_setHeight = ISToolTipInv.setHeight

  self.setHeight = function(self, h, ...)
    h = newHeight
    self.keepOnScreen = false -- temp fix for visual bug
    return old_setHeight(self, h, ...)
  end

  local old_drawRectBorder = ISToolTipInv.drawRectBorder

  self.drawRectBorder = function(self, ...)
    for _, text in ipairs(textRows) do
      self.tooltip:DrawText(font, text, paddingConst, height, colors.r, colors.g, colors.b, 1)
      height = height + lineSpacing
    end
    old_drawRectBorder(self, ...)
  end

  old_render(self)

  -- return control back to original methods
  self.setHeight = old_setHeight
  self.drawRectBorder = old_drawRectBorder
end
