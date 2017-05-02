
local AddonName, AddonTable = ...
local LSM = LibStub("LibSharedMedia-3.0")

_G[AddonName] = _G[AddonName] or LibStub("AceAddon-3.0"):NewAddon(AddonName)
local Addon = _G[AddonName]

local assert = assert
local type = type
local getmetatable = getmetatable
local CreateFrame = CreateFrame
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local GetNetStats = GetNetStats
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local IsHarmfulSpell = IsHarmfulSpell
local IsHelpfulSpell = IsHelpfulSpell
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

function Addon:CreatePlayerModel(Name, Parent, Region)
    Name = Name or nil
    Parent = Parent or UIParent

    local m = CreateFrame("PlayerModel", Name, Parent)
    m:SetPoint("CENTER", Parent, "CENTER")
    m:SetSize(Parent:GetSize())
    m:SetModel("Spells\\Lightning_Area_Disc_State.M2")
    m:SetModelScale(Parent:GetEffectiveScale())
    m:SetSequence(28)
    m:SetPosition(0.0, 0.0, 0.0)
    m:SetFrameLevel(3)
    m:Show()

    m:SetScript("OnShow", function(self)
        self:SetModel("Spells\\Lightning_Area_Disc_State.M2")
    end)

    return m
end



function Addon:CreateCastingBarFrame(Unit, Parent)
    assert(type(Unit) == "string", "Usage : CreateCastingBarFrame(string Unit)")
    Parent = Parent or UIParent
    local f = self:CreateClass("Frame", AddonName..Unit, Parent)
    local s = self:CreateClass("StatusBar", nil, f)
    --local spark = s:CreateTexture(spark)
    
    f:Hide()
    f:SetSize(230, 25)
    f:SetPoint("BOTTOM", 0, 170)
    local t = f:CreateTexture()
    t:SetColorTexture(0, 0, 0)
    t:SetAllPoints(f)

    s:SetPoint("LEFT", f, "LEFT")
    s:SetSize(f:GetSize())
    s:SetStatusBarTexture("Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
    s:SetStatusBarColor(0, 0.4, 7.0)
    s:SetFillStyle("STANDARD")
    s:SetMinMaxValues(0.0, 1.0)

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

    local m = self:CreatePlayerModel(nil, f)

    local scrollframe = CreateFrame("ScrollFrame", nil, f)
    scrollframe:SetScrollChild(m)
    scrollframe:SetPoint("LEFT", f, "LEFT")
    scrollframe:SetHeight(f:GetHeight())
    scrollframe:SetWidth(0)
    scrollframe:SetVerticalScroll(0)
    scrollframe:SetHorizontalScroll(0)

    f.fadein:SetScript("OnPlay", function(self, ...)
        f.fadeout:Stop()
        f:Show()
    end)

    f.fadeout:SetScript("OnFinished", function(self, ...)
        f:Hide()
    end)

    local c = {}

    f:RegisterUnitEvent("UNIT_SPELLCAST_START", Unit, function(self, event, unit, ...)
        c.name, _, c.text, c.texture, c.startTime, c.endTime, _, c.castID, c.notInterruptible = UnitCastingInfo(unit)
        self.fadein:Play()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_STOP", Unit, function(self, event, unit, name, rank, castid, spellid)
        self.fadeout:Play()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", Unit, function(self, event, unit, name, rank, castid, spellid)
        local val = s:GetMinMaxValues()
        c = {}
        s:SetValue(val)
        scrollframe:SetWidth(0)
        scrollframe:UpdateScrollChildRect()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", Unit, function(self, event, unit, name, rank, castid, spellid)
        if(castid == c.castid) then
            local _, val = s:GetMinMaxValues()
            s:SetValue(val)
            scrollframe:SetWidth(15)
        end
    end)

    f:SetScript('OnUpdate', function(self, rate)
        if c.startTime and c.endTime then
            s:SetValue((GetTime()*1000 - c.startTime) / (c.endTime-c.startTime))
            scrollframe:SetWidth(s:GetStatusBarTexture():GetWidth())
        end
    end)

    return f
end