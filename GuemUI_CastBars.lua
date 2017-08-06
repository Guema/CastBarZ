local AddonName, AddonTable = ...
local _G = _G
local LoadAddOn = LoadAddOn
local AceDB = LibStub("AceDB-3.0")

_G[AddonName] = LibStub("AceAddon-3.0"):NewAddon(AddonTable, AddonName)
local Addon = _G[AddonName]

local defaults = {
    profile = {
        player = {
            show_name = false,
            show_timer = false,
            show_latency = false,
            status_bar_texture = "",
            status_bar_color = {r = 0, g = 0.4, b = 0.8, a = 1},
            background_color = {r = 0, g = 0, b = 0, a = 1},
            width = 220,
            height = 24,
            xoffset = 0,
            yoffset = 190
        }
    }
}

function Addon:OnInitialize()
    _G.CastingBarFrame:UnregisterAllEvents()
    self.db = AceDB:New(AddonName.."DB", defaults, true)
    LoadAddOn("GuemUIConfig")
end

function Addon:OnEnable()
    self.player = self:CreateCastingBar3D("player")
end