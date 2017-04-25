
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

    self.castbars = {}
    function self.castbarsAddCastBar(frame)

    end
end

function Addon:OnEnable()
    self.CastingBarFrame = self:CreateClass("StatusBar")
    local f = self.CastingBarFrame
    f:SetSize(220, 24)
    f:SetPoint("BOTTOM", 0, 170)

    f:RegisterUnitEvent("UNIT_SPELLCAST_START", "player", function(_, event, _, name, _)
        print("Casting ".. name .. "...")
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", function()
        print("Succes !")
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player", function()
        print("Stopped.")
    end)

    f:UnregisterEvent("UNIT_SPELLCAST_STOP")
end