local AddonName, AddonTable = ...
local _G = _G
local LoadAddOn = LoadAddOn
local DB = LibStub("AceDB-3.0")

_G[AddonName] = LibStub("AceAddon-3.0"):NewAddon(AddonTable, AddonName)
local Addon = _G[AddonName]

local defaults = {
    profile = {
        player = {
            width = 220,
            height = 24,
            xoffset = 0,
            yoffset = 190
        }
    }
}

function Addon:OnInitialize()
    --_G.CastingBarFrame.ignoreFramePositionManager = true
    _G.CastingBarFrame:UnregisterAllEvents()
    self.db = DB:New(AddonName.."DB", defaults, true)
    LoadAddOn("GuemUIConfig")
end

function Addon:OnEnable()
    self.player = self:CreateCastingBarFrame("player")
end