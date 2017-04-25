
local AddonName, AddonTable = ...
local LSM = LibStub("LibSharedMedia-3.0")

_G[AddonName] = _G[AddonName] or LibStub("AceAddon-3.0"):NewAddon(AddonName)
local Addon = _G[AddonName]


--[[ global refs ]]--

local _G = _G
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local GetNetStats = _G.GetNetStats
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local IsHarmfulSpell = _G.IsHarmfulSpell
local IsHelpfulSpell = _G.IsHelpfulSpell
local pairs = _G.pairs
local AceGUI = LibStub("AceGUI-3.0")

function Addon:OnInitialize()
    --_G.CastingBarFrame.ignoreFramePositionManager = true
    _G.CastingBarFrame:UnregisterAllEvents()
    LSM:Register("statusbar", "Solid", "Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
end

function Addon:OnEnable()
    self.CastingBar = self:CreateCastingBarFrame("player")
end