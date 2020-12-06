local AddonName, Addon = ...
local Addon = _G[AddonName]

local getmetatable = getmetatable
local CreateFrame = CreateFrame

function Addon:CreateBoundedModel(Name, Parent, ...)
  Parent = Parent or UIParent
  local obj = CreateFrame("Frame", Name, Parent, ...)
  local base = getmetatable(obj).__index
  local mdl = self:CreateModel(nil, obj)

  obj:SetClipsChildren(true)
  
  function obj:SetModel(path)
    mdl:SetModel(path)
  end

  function obj:GetBoundedModel()
    return mdl
  end

  obj:SetScript(
    "OnSizeChanged",
    function(self, w, h)
      if w < 0.5 or h < 0.5 then
        mdl:Hide()
      else
        mdl:Show()
      end
    end
  )

  return obj
end
