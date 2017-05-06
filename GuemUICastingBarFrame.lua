
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
local INTERRUPTED = INTERRUPTED

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

function Addon:CreateCastingBarFrame(Unit, Parent)
    assert(type(Unit) == "string", "Usage : CreateCastingBarFrame(string Unit)")
    Parent = Parent or UIParent
    local f = self:CreateClass("Frame", AddonName..Unit, Parent)
    local s = self:CreateClass("StatusBar", nil, f)
    local sparkle = CreateFrame("Frame", nil, s)
    local nameText = CreateFrame("Frame", nil, f)
    local timerText = CreateFrame("Frame", nil, f)
    local latencyoverlay = CreateFrame("Frame", nil, f)

    f:Hide()
    f:SetSize(220, 24)
    f:SetPoint("BOTTOM", 0, 170)
    local t = f:CreateTexture("Texture")
    t:SetColorTexture(0, 0, 0)
    t:SetAllPoints(f)
    
    s:SetAllPoints(f)
    s:SetStatusBarTexture("Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
    s:SetStatusBarColor(0, 0.5, 8.0)
    s:SetFillStyle("STANDARD_NO_RANGE_FILL")
    s:SetMinMaxValues(0.0, 1.0)
    s:SetScript("OnValueChanged", function(self, val)
        if(val <= 0.0 or val >= 1.0) then
            sparkle:Hide()
        else
            sparkle:Show()
        end
    end)

    sparkle:SetPoint("TOPLEFT", s:GetStatusBarTexture(), "TOPRIGHT", -7, 15)
    sparkle:SetPoint("BOTTOMRIGHT", s:GetStatusBarTexture(), "BOTTOMRIGHT", 7, -15)
    local t = sparkle:CreateTexture()
    t:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    t:SetVertexColor(s:GetStatusBarColor())
    t:SetBlendMode("ADD")
    t:SetAllPoints(sparkle)
    
    nameText:SetAllPoints(f)
    local text = nameText:CreateFontString()
    text:SetFont("Fonts\\2002.TTF", 10, "OUTLINE")
    text:SetAllPoints(f)
    text:SetTextColor( 1, 1, 1)

    timerText:SetPoint("TOPLEFT", f, "TOPRIGHT", -60, 0)
    timerText:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 0)
    timerText:SetWidth(60)
    local ttext = timerText:CreateFontString()
    ttext:SetFont("Fonts\\2002.TTF", 8, "OUTLINE")
    ttext:SetJustifyH("RIGHT")
    ttext:SetAllPoints(timerText)

    latencyoverlay:SetPoint("TOPRIGHT", f, "TOPRIGHT")
    latencyoverlay:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
    local t = latencyoverlay:CreateTexture()
    t:SetColorTexture(0.8, 0.6, 0.0, 0.3)
    t:SetAllPoints(latencyoverlay)

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
    
    f.fadeout:SetScript("OnFinished", function(self, ...)
        f:Hide()
    end)

    local ccname, cctext, cctexture, ccstime, ccetime, cccastID
    local wlatency

    f:RegisterUnitEvent("UNIT_SPELLCAST_START", Unit, function(self, event, unit, ...)
        ccname, _, cctext, cctexture, ccstime, ccetime, _, cccastID = UnitCastingInfo(unit)
        _, _, _, wlatency = GetNetStats()
        latencyoverlay:SetWidth(wlatency * 1000 / (ccetime-ccstime))
        text:SetFormattedText("%s", string.sub( cctext, 1, 40 ))
        self:Show()
        self.fadeout:Stop()
        self.fadein:Play()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", Unit, function(self, event, unit, ...)
        ccname, _, cctext, cctexture, ccetime, ccstime, _, cccastID = UnitChannelInfo(unit)
        _, _, _, wlatency = GetNetStats()
        latencyoverlay:SetWidth(0)
        text:SetFormattedText("%s", string.sub( ccname, 1, 40 ))
        self:Show()
        self.fadeout:Stop()
        self.fadein:Play()
    end)


    f:RegisterUnitEvent("UNIT_SPELLCAST_STOP", Unit, function(self, event, unit, name, rank, castid, spellid)
        ccname, _, cctext, cctexture, ccstime, ccetime, _, cccastID = UnitCastingInfo(unit)
        self.fadeout:Play()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", Unit, function(self, event, unit, name, rank, castid, spellid)
        ccname, _, cctext, cctexture, ccstime, ccetime, _, cccastID = UnitChannelInfo(unit)
        self.fadeout:Play()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", Unit, function(self, event, unit, name, rank, castid, spellid)
        local val = s:GetMinMaxValues()
        text:SetText(INTERRUPTED)
        ttext:SetText("")
        s:SetValue(val)
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", Unit, function(self, event, unit, name, rank, castid, spellid)
        if(castid == cccastID) then
            local _, val = s:GetMinMaxValues()
            s:SetValue(val)
        end
    end)

    f:SetScript('OnUpdate', function(self, rate)
        if ccstime and ccetime then
            local t = GetTime() * 1000
            s:SetValue((t - ccstime) / (ccetime-ccstime))
            --ttext:SetFormattedText("%.1f / %.1f", (t - ccstime)/1000, (ccetime-ccstime)/1000)
            ttext:SetFormattedText("%.1f", (ccetime - t)/1000)
        end
    end)

    return f
end