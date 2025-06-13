--- @class ModDataColor
--- @field r float
--- @field g float
--- @field b float
--- @field a float

local function defaultModDataColor()
  return {
    r = 1,
    g = 1,
    b = 1,
    a = 1,
  }
end

local ModDataColor = {}

--- @param color Color|ImmutableColor|nil
--- @return ModDataColor
function ModDataColor.colorToModDataColor(color)
  if color then
    return {
      r = color:getRedFloat(),
      g = color:getGreenFloat(),
      b = color:getBlueFloat(),
      a = color:getAlphaFloat(),
    }
  end

  return defaultModDataColor()
end

--- @param color ModDataColor
--- @return ImmutableColor
function ModDataColor.modDataColorToImmutableColor(color)
  return ImmutableColor.new(Color.new(color.r, color.g, color.b, color.a))
end

return ModDataColor
