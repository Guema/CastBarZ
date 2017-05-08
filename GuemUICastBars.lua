local AddonName, AddonTable = ...
local _G = _G
local LSM = LibStub("LibSharedMedia-3.0")
local AceGUI = LibStub("AceGUI-3.0")

_G[AddonName] = LibStub("AceAddon-3.0"):NewAddon(AddonName)
local Addon = _G[AddonName]


function Addon:OnInitialize()
    --_G.CastingBarFrame.ignoreFramePositionManager = true
    _G.CastingBarFrame:UnregisterAllEvents()
    LSM:Register("statusbar", "Solid", "Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
end

function Addon:OnEnable()
    self.CastingBar = self:CreateCastingBarFrame("player")
end