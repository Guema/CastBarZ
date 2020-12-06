local AddonName, AddonTable = ...
local Addon = _G[AddonName]
local AceEvent = LibStub("AceEvent-3.0")

local getmetatable = getmetatable
local math = math

assert(Addon ~= nil, AddonName .. " could not be load")

local WIDTH_FACTOR = 0.45
local HEIGHT_FACTOR = 1.8

function Addon.CreateSparkleStatusBar(Name, Parent, ...)
  local obj = AceEvent:Embed(CreateFrame("StatusBar", Name, Parent, ...))
  local base = getmetatable(obj).__index
  local texture

  local vmin, vmax = base.GetMinMaxValues(obj)
  local sparkle = obj:CreateTexture("sparkle", 5)
  local fillStyle = base.GetFillStyle(obj)
  local hideOnBounds = true
  local size = {}

  sparkle:SetShown(true)
  sparkle:SetBlendMode("ADD")

  function obj:SetSparkleTexture(texture)
    sparkle:SetTexture(texture)
  end

  function obj:GetSparkleTexture()
    return sparkle
  end

  function obj:HideSparklesOnBounds(value)
    value = value == true
    hideOnBounds = value
  end

  function obj:SetSparkleColor(r, g, b, a)
    sparkle:SetVertexColor(r, g, b, a)
  end

  hooksecurefunc(
    obj,
    "SetStatusBarTexture",
    function(self, newTexture)
      sparkle:ClearAllPoints()
      sparkle:SetPoint("CENTER", newTexture, "RIGHT")
      texture = newTexture
    end
  )

  hooksecurefunc(
    obj,
    "SetMinMaxValues",
    function(self, newvmin, newvmax)
      vmin, vmax = newvmin, newvmax
    end
  )

  hooksecurefunc(
    obj,
    "SetFillStyle",
    function(self, style)
      fillStyle = base.GetFillStyle(obj)
    end
  )

  local function adjustSize()
  end

  obj:HookScript(
    "OnSizeChanged",
    function(self, w, h)
      -- sparkle:SetSize(h * WIDTH_FACTOR, h * HEIGHT_FACTOR)
      sparkle:ClearAllPoints()
      sparkle:SetPoint("TOPLEFT", texture, "RIGHT", -(h * WIDTH_FACTOR) / 2, (h * HEIGHT_FACTOR) / 2)
      sparkle:SetPoint("BOTTOMRIGHT", texture, "RIGHT", (h * WIDTH_FACTOR) / 2, -(h * HEIGHT_FACTOR) / 2)
    end
  )

  obj:SetScript(
    "OnValueChanged",
    function(self, val)
      if (hideOnBounds) then
        sparkle:SetShown(vmin < val and vmax > val)
      else
        sparkle:SetShown(true)
      end
    end
  )

  return obj
end
