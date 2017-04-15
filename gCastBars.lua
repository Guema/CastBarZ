--[[
    gCastBars.lua
        This file is published in the public domain.
]]--


-- Initialize addon with the scope parameters provided by Blizzard
local AddonName, AddonTable = ...
-- Search the addon name in global(_G) scope. If not initilialized, do it.
_G[AddonName] = _G[AddonName] or LibStub('AceAddon-3.0'):NewAddon(AddonName)
local Addon = _G[AddonName]
local LSM = LibStub('LibSharedMedia-3.0')

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

function Addon:OnInitialize()
    --_G.CastingBarFrame.ignoreFramePositionManager = true
    _G.CastingBarFrame:UnregisterAllEvents()
end

function Addon:OnEnable()
    self.CastBarFrame = CreateFrame("Frame", nil, UIParent)
    local CastBarFrame = self.CastBarFrame
    CastBarFrame:SetFrameStrata("BACKGROUND")
    CastBarFrame:SetSize(230, 24)

    CastBarFrame.texture = CastBarFrame:CreateTexture(nil, "BACKGROUND")
    local t = CastBarFrame.texture
    
    t:SetAllPoints(CastBarFrame)
    t:SetTexture("Interface\\TargetingFrame\\UI-StatusBar.blp")
    t:SetVertexColor(1.0, 1.0, 1.0, 1.0)

    CastBarFrame:SetPoint("BOTTOM",0,185)
    CastBarFrame:Show()
end

function DumpTable(tb)
    for k, v in pairs(tb) do
        print(k, v)
    end
end



--function Addon: On