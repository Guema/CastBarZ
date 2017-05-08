local AddonName, AddonTable = ...
local Addon = _G[AddonName]

assert(Addon ~= nil, AddonName.." could not be load")

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

    function obj:RegisterEvent(event, callback)
        assert(type(callback) == "function", "Usage : obj:RegisterUnitEvent(string event, function callback")
        self.callbacks[event] = callback
        base.RegisterEvent(self, event)
    end

    --Wrapping RegisterUnitEvent method
    function obj:RegisterUnitEvent(event, unit, callback)
        assert(type(callback) == "function", "Usage : obj:RegisterUnitEvent(string event, string unitID, function callback")
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
    local s = self.CreateSparkleStatusBar(nil, f)
    local l = self.CreateSparkleStatusBar(nil, f)
    local nameText = CreateFrame("Frame", nil, f)
    local timerText = CreateFrame("Frame", nil, f)

    f:Hide()
    f:SetSize(220, 24)
    f:SetPoint("BOTTOM", 0, 170)
    local t = f:CreateTexture()
    t:SetColorTexture(0, 0, 0, 0.4)
    t:SetPoint("TOPLEFT", f, "TOPLEFT", -2, 2)
    t:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 2, -2)
    local t = f:CreateTexture()
    t:SetColorTexture(0, 0, 0)
    t:SetAllPoints(f)
    
    s:SetAllPoints(f)
    s:SetStatusBarTexture("Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
    s:SetSparkleTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    s:SetStatusBarColor(0, 0.5, 0.8)
    s:SetFillStyle("STANDARD")
    s:SetMinMaxValues(0.0, 1.0)
    
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

    l:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
    l:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    l:SetHeight(24)
    l:SetStatusBarTexture("Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
    l:SetSparkleTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    l:SetStatusBarColor(0.8, 0.6, 0.0)
    l:SetAlpha(0.5)
    l:SetFillStyle("REVERSE")
    l:SetMinMaxValues(0.0, 1.0)

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
    local sentTime

    f:RegisterUnitEvent("UNIT_SPELLCAST_START", Unit, function(self, event, unit, ...)
        ccname, _, cctext, cctexture, ccstime, ccetime, _, cccastID = UnitCastingInfo(unit)
        l:SetValue(100 / (ccetime - ccstime))
        text:SetFormattedText("%s", string.sub( cctext, 1, 40 ))
        self:Show()
        self.fadeout:Stop()
        self.fadein:Play()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", Unit, function(self, event, unit, ...)
        ccname, _, cctext, cctexture, ccetime, ccstime, _, cccastID = UnitChannelInfo(unit)
        l:SetValue(0)
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