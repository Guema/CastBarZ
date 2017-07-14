local AddonName, AddonTable = ...
local _G = _G
local LSM = LibStub("LibSharedMedia-3.0")
local DB = LibStub("AceDB-3.0")

_G[AddonName] = LibStub("AceAddon-3.0"):NewAddon(AddonName)
local Addon = _G[AddonName]

local defaults = {
    profile = {
        units = {
            player = {
                width = 220,
                height = 24,
                parent_anchor = "BOTTOM",
                anchor = "CENTER",
                Xoffset = 0,
                Yoffset = 170
            }
        }
    }
}

function Addon:OnInitialize()
    --_G.CastingBarFrame.ignoreFramePositionManager = true
    _G.CastingBarFrame:UnregisterAllEvents()
    self.db = DB:New(AddonName.."DB", defaults, true)
    LSM:Register("statusbar", "Solid", "Interface\\AddOns\\"..AddonName.."\\Media\\Solid") -- Will move to GuemUIMedia
end

function Addon:OnEnable()
    self.CastingBar = self:CreateCastingBarFrame("player")
end