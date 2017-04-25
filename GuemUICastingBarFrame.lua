
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

function Addon:CreateCastingBarFrame(Unit)
    local f = self:CreateClass("StatusBar")

    f:Hide()
    f:SetStatusBarTexture("Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
    f:SetStatusBarColor(0, 0.7, 1.0)
    f:SetSize(220, 24)
    f:SetPoint("BOTTOM", 0, 170)
    f:SetFillStyle("STANDARD")
    f:SetMinMaxValues(0.0, 1.0)

    local t = f:CreateTexture()
    t:SetColorTexture(0, 0, 0)
    t:SetAllPoints(f)

    f.fadein = f:CreateAnimationGroup()
    f.fadein:SetLooping("NONE")
    local alpha = f.fadein:CreateAnimation("Alpha")
    alpha:SetDuration(0.2)
    alpha:SetFromAlpha(0.0)
    alpha:SetToAlpha(1.0)

    f.fadeout = f:CreateAnimationGroup()
    f.fadeout:SetLooping("NONE")
    local alpha = f.fadeout:CreateAnimation("Alpha")
    alpha:SetDuration(0.5)
    alpha:SetFromAlpha(1.0)
    alpha:SetToAlpha(0.0)

    f:RegisterUnitEvent("UNIT_SPELLCAST_START", "player", function(self, event, unit, name, ...)
        self:Show()
        self.fadeout:Stop()
        self.fadein:Play()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player", function(self, event, unit, name, ...)
        self.fadeout:Play()
    end)

    f.fadeout:SetScript("OnFinished", function(self, ...)
        f:Hide()
    end)

    f:SetScript('OnUpdate', function(self, rate)
        local _, _, _, _, startTime, endTime = UnitCastingInfo("player")
        if startTime and endTime then
            f:SetValue((GetTime()*1000 - startTime) / (endTime-startTime))
        end
    end)

    return f
end