require "ISUI/ISToolTipInv"

local old_render = ISToolTipInv.render

function ISToolTipInv:render()
  if not self.item or not TransmogRebuild.isTransmoggable(self.item) then
    return old_render(self)
  end

  local itemModData = TransmogRebuild.getItemTransmogModData(self.item)
  local name = itemModData.transmogTo and getItemNameFromFullType(itemModData.transmogTo) or "Hidden"
  local tmogTooltipText = {
    "Transmog to: " .. name,
  }

  local font = UIFont[getCore():getOptionTooltipFont()];
  local lineSpacing = self.tooltip:getLineSpacing()
  local height = self.tooltip:getHeight()
  local newHeight = height + (#tmogTooltipText * lineSpacing) + (lineSpacing / 2)

  local old_setHeight = ISToolTipInv.setHeight

  self.setHeight = function(self, h, ...)
    h = newHeight
    self.keepOnScreen = false
    return old_setHeight(self, h, ...)
  end

  local old_drawRectBorder = ISToolTipInv.drawRectBorder
  self.drawRectBorder = function(self, ...)
    for _, text in ipairs(tmogTooltipText) do
      self.tooltip:DrawText(font, text, 5, height, 1, 0.6, 0, 1)
      height = height + lineSpacing
    end
    old_drawRectBorder(self, ...)
  end

  old_render(self)

  self.setHeight = old_setHeight
  self.drawRectBorder = old_drawRectBorder
end
