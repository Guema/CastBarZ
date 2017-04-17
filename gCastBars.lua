--[[
    gCastBars.lua
        This file is published in the public domain.
]]--


-- Initialize addon with the scope parameters provided by Blizzard
local AddonName, AddonTable = ...
-- Search the addon name in global(_G) scope. If not initilialized, do it.
_G[AddonName] = _G[AddonName] or LibStub("AceAddon-3.0"):NewAddon(AddonName)
local Addon = _G[AddonName]
local LSM = LibStub("LibSharedMedia-3.0")

--[[ global refs ]]--
-- declaring local references probably allow faster memory access for addons 
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
---------------------

LSM:Register("statusbar", "Solid", "Interface\\AddOns\\"..AddonName.."\\Media\\Solid")

function Addon:OnInitialize()
    --_G.CastingBarFrame.ignoreFramePositionManager = true
    _G.CastingBarFrame:UnregisterAllEvents()
    
end

function Addon:OnEnable()
    self.CastBarFrame = self:CreateCastbarFrame()
    local f = self.CastBarFrame
end

function DumpTable(tb)
    for k, v in pairs(tb) do
        print(k, v)
    end
end

function Addon:CreateCastbarFrame()
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetFrameStrata("BACKGROUND")
    f:SetSize(230, 24)

    f.t = f:CreateTexture(nil, "BACKGROUND")
    local t = f.t
    
    t:SetAllPoints(f)
    t:SetTexture("Interface\\TargetingFrame\\UI-StatusBar.blp")
    t:SetVertexColor(1.0, 1.0, 1.0, 1.0)

    f:SetScript("OnEvent", function(self, event, ...)
        if event == "UNIT_SPELLCAST_START" then
            self:Show()
        elseif event == "UNIT_SPELLCAST_STOP" or "UNIT_SPELLCAST_FAILED" then
            self:Hide()
        end 
    end)

    f:SetPoint("BOTTOM",0,185)
    f:Hide()

    self:ConnectEventsOfUnit(f, "player")
        
    return f
end

function Addon:ConnectEventsOfUnit(Frame, Unit)
    Frame:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_START', Unit)
    Frame:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_UPDATE', Unit)
    Frame:RegisterUnitEvent('UNIT_SPELLCAST_CHANNEL_STOP', Unit)

    Frame:RegisterUnitEvent('UNIT_SPELLCAST_START', Unit)
    Frame:RegisterUnitEvent('UNIT_SPELLCAST_STOP', Unit)
    Frame:RegisterUnitEvent('UNIT_SPELLCAST_FAILED', Unit)
    Frame:RegisterUnitEvent('UNIT_SPELLCAST_FAILED_QUIET', Unit)

    Frame:RegisterUnitEvent('UNIT_SPELLCAST_INTERRUPTED', Unit)
    Frame:RegisterUnitEvent('UNIT_SPELLCAST_DELAYED', Unit)
end


--function Addon: On