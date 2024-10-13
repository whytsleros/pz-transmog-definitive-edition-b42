require "ISUI/ISToolTipInv"

local old_render = ISToolTipInv.render

function ISToolTipInv:render()
  if not self.item or not TransmogDE.isTransmoggable(self.item) then
    return old_render(self)
  end

  local itemModData = TransmogDE.getItemTransmogModData(self.item)
  if itemModData.transmogTo == self.item:getScriptItem():getFullName() then
    return old_render(self)
  end

  local text = itemModData.transmogTo
    and getText("IGUI_TransmogDE_Tooltip_TransmogTo", getItemNameFromFullType(itemModData.transmogTo))
    or getText("IGUI_TransmogDE_Tooltip_TransmogHidden")
  local tmogTooltipText = {
    text,
  }

  local font = UIFont[getCore():getOptionTooltipFont()];
  local lineSpacing = self.tooltip:getLineSpacing()
  local y = self.tooltip:getHeight()
  local height = (#tmogTooltipText * lineSpacing) + (lineSpacing / 2)

  local old_setHeight = ISToolTipInv.setHeight

  local isFirstTimeSetHeight = true
  self.setHeight = function(self, h, ...)
    if isFirstTimeSetHeight then
      isFirstTimeSetHeight = false
      y = h
      h = h + height
    end
    return old_setHeight(self, h, ...)
  end

  local old_drawRectBorder = ISToolTipInv.drawRectBorder
  self.drawRectBorder = function(self, ...)
    for _, text in ipairs(tmogTooltipText) do
      self.tooltip:DrawText(font, text, 5, y, 1, 0.6, 0, 1)
      y = y + lineSpacing
    end
    old_drawRectBorder(self, ...)
  end

  old_render(self)

  self.setHeight = old_setHeight
  self.drawRectBorder = old_drawRectBorder
end
