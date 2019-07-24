local AddonName = GetAddOnDependencies(...)
local Addon = _G[AddonName]
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local optionframe = AceConfigDialog:AddToBlizOptions(AddonName, AddonName)

function Addon:OpenConfigDialog()
  --Blizz bugs suxxxxx
  InterfaceOptionsFrame_Show()
  InterfaceOptionsFrame_OpenToCategory(AddonName)
end
