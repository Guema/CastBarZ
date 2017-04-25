
local AddonName, AddonTable = ...
local LSM = LibStub("LibSharedMedia-3.0")

_G[AddonName] = _G[AddonName] or LibStub("AceAddon-3.0"):NewAddon(AddonName)
local Addon = _G[AddonName]

local assert = assert
local type = type
local getmetatable = getmetatable
local CreateFrame = CreateFrame
local UIParent = UIParent

function Addon:CreateClass(Class, Name, Parent)
    Name = Name or nil
    Parent = Parent or UIParent

    local obj = CreateFrame(Class, Name, Parent)
    local base = getmetatable(obj).__index
    obj.callbacks = {}

    --Wrapping RegisterUnitEvent method
    function obj:RegisterUnitEvent(event, unit, callback)
        assert(type(callback) == "function" , "Usage : obj:RegisterUnitEvent(string event, string unitID, function callback")
        self.callbacks[event] = callback
        base.RegisterUnitEvent(self, event, unit)
    end

    --Wrapping UnregisterAllEvent method
    function obj:UnregisterAllEvents()
        self.callbacks = {}
        base.UnregisterAllEvents()
    end

    --Wrapping UnregisterEvent method
    function obj:UnregisterEvent(event)
        assert(type(event) == "string", "Usage : obj:UnregisterEvent(string event)")
        self.callbacks[event] = nil
        base.UnregisterEvent(self, event)
    end
    
    --SetScript will call self.callbacks[event] on "OnEvent" fired
    obj:SetScript("OnEvent", function(self, event, ...)
        self.callbacks[event](self, event, ...)
    end)

    return obj
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