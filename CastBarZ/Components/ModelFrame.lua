local AddonName, Addon = ...
local Addon = _G[AddonName]

function Addon:CreateModel(Name, Parent, ...)
  Parent = Parent or UIParent
  local obj = CreateFrame("PlayerModel", Name, Parent, ...)
  local base = getmetatable(obj).__index
  local mdl

  function obj:SetModel(path)
    mdl = path
  end

  obj:SetScript(
    "OnModelLoaded",
    function(self)
      self:SetPortraitZoom(1)
      self:ClearTransform()
      self:SetTransform(1, 0, 0.050, 0, 0, 0, 0.200)
    end
  )

  obj:SetScript(
    "OnShow",
    function(self)
      pcall(base.SetModel, self, mdl)
    end
  )

  obj:SetScript(
    "OnSizeChanged",
    function(self, w, h)
      if w < 0.5 or h < 0.5 then
        self:Hide()
      else
        self:Show()
      end
    end
  )

  return obj
end
