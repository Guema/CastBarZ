local AddonName, Addon = ...
local Addon = _G[AddonName]

function Addon:CreateModel(Name, Parent, ...)
  Parent = Parent or UIParent
  local obj = CreateFrame("PlayerModel", Name, Parent, ...)
  local base = getmetatable(obj).__index
  local mdl
  local transform = {}

  function obj:SetModel(id)
    mdl = id
  end

  function obj:SetTransform(a, b, c, d, e, f, g)
    transform = {a, b, c, d, e, f, g}
    self:SetPosition(transform[1], transform[2], transform[3])
  end

  obj:SetScript(
    "OnModelLoaded",
    function(self)
      self:ClearTransform()
      self:SetPosition(transform[1], transform[2], transform[3])
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
