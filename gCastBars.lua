
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
    self.CastingBarFrame = self:CreateClass("StatusBar")
    local f = self.CastingBarFrame
    f:Hide()
    f:SetStatusBarTexture("Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
    f:SetSize(220, 24)
    f:SetPoint("BOTTOM", 0, 170)
    f:SetFillStyle("STANDARD")
    f:SetMinMaxValues(0.0, 1.0)
    f.t = f:CreateTexture(nil)
    f.t:SetColorTexture(0, 0, 0)
    f.t:SetAllPoints(f)
    
    f:RegisterUnitEvent("UNIT_SPELLCAST_START", "player", function(self, event, unit, name, ...)
        self:Show()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player", function(self, event, unit, name, ...)
        self:Hide()
    end)

    f:SetScript('OnUpdate', function(self, rate)
        local _, _, _, _, startTime, endTime = UnitCastingInfo("player")
        if startTime and endTime then
            f:SetValue((GetTime()*1000 - startTime) / (endTime-startTime))
        end
    end)
end