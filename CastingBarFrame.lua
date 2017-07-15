local AddonName, AddonTable = ...
local Addon = _G[AddonName]
local LSM = LibStub("LibSharedMedia-3.0")


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

local LATENCY_TOLERENCE = 100

function Addon.CreateClass(Class, Name, Parent)
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
    m:Show()

    m:SetScript("OnShow", function(self)
        self:SetModel("Spells\\Lightning_Area_Disc_State.M2")
    end)

    return m
end


function Addon:CreateCastingBarFrame(Unit, Parent)
    assert(type(Unit) == "string", "Usage : CreateCastingBarFrame(string Unit)")
    Parent = Parent or UIParent

    local f = self.CreateSparkleStatusBar(AddonName..Unit, Parent)
    local l = CreateFrame("StatusBar", nil, f)
    local textoverlay = CreateFrame("Frame", nil, f)

    local config = self.db.profile.units[Unit]

    f:Hide()
    f:SetSize(config.width, config.height)
    f:SetPoint(config.anchor, Parent, config.parent_anchor, config.Xoffset, config.Yoffset)
    local t = f:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(0, 0, 0, 0.4)
    t:SetPoint("TOPLEFT", f, "TOPLEFT", -2, 2)
    t:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 2, -2)
    local t = f:CreateTexture(nil, "BACKGROUND")
    t:SetColorTexture(0, 0, 0)
    t:SetAllPoints(f)
    local t = f:CreateTexture("StatusBarTexture")
    t:SetTexture(LSM:Fetch("statusbar", "Solid"))
    f:SetStatusBarTexture(t)
    f:SetSparkleTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    f:SetStatusBarColor(0, 0.5, 0.8)
    f:SetFillStyle("STANDARD")
    f:SetMinMaxValues(0.0, 1.0)

    local m = self:CreatePlayerModel(nil, f)
    m:SetFrameLevel(2)

    local scrollframe = CreateFrame("ScrollFrame", nil, f)
    scrollframe:SetScrollChild(m)
    scrollframe:SetPoint("LEFT", f:GetStatusBarTexture(), "LEFT")
    scrollframe:SetPoint("RIGHT", f:GetStatusBarTexture(), "RIGHT")
    scrollframe:SetPoint("TOP", f, "TOP")
    scrollframe:SetPoint("BOTTOM", f, "BOTTOM")
    scrollframe:SetVerticalScroll(0)
    scrollframe:SetHorizontalScroll(0)

    textoverlay:SetAllPoints(f)
    textoverlay:SetFrameLevel(3)
    local nametext = textoverlay:CreateFontString()
    nametext:SetFont("Fonts\\2002.TTF", 10, "OUTLINE")
    nametext:SetAllPoints(f)
    nametext:SetTextColor( 1, 1, 1)

    local timertext = textoverlay:CreateFontString()
    timertext:SetPoint("TOPLEFT", f, "TOPRIGHT", -60, 0)
    timertext:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 0)
    timertext:SetWidth(60)
    timertext:SetFont("Fonts\\2002.TTF", 8, "OUTLINE")
    timertext:SetJustifyH("RIGHT")

    l:SetFrameLevel(1)
    l:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
    l:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    l:SetHeight(24)
    
    l:SetStatusBarTexture(LSM:Fetch("statusbar", "Solid"))
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

    f.fadein:SetScript("OnPlay", function(self, ...)
        f.fadeout:Stop()
        f:Show()
    end)

    f.fadeout:SetScript("OnFinished", function(self, ...)
        f:Hide()
    end)

    local ccname, cctext, cctexture, ccstime, ccetime, cccastID

    f:RegisterUnitEvent("UNIT_SPELLCAST_START", Unit, function(self, event, unit, ...)
        ccname, _, cctext, cctexture, ccstime, ccetime, _, cccastID = UnitCastingInfo(unit)
        l:SetValue(LATENCY_TOLERENCE / (ccetime - ccstime))
        nametext:SetFormattedText("%s", string.sub( cctext, 1, 40 ))
        self.fadein:Play()
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", Unit, function(self, event, unit, ...)
        ccname, _, cctext, cctexture, ccetime, ccstime, _, cccastID = UnitChannelInfo(unit)
        l:SetValue(0)
        nametext:SetFormattedText("%s", string.sub( ccname, 1, 40 ))
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
        local val = f:GetMinMaxValues()
        nametext:SetText(INTERRUPTED)
        timertext:SetText("")
        f:SetValue(val)
    end)

    f:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", Unit, function(self, event, unit, name, rank, castid, spellid)
        if(castid == cccastID) then
            local _, val = f:GetMinMaxValues()
            f:SetValue(val)
        end
    end)

    f:SetScript('OnUpdate', function(self, rate)
        if ccstime and ccetime then
            local t = GetTime() * 1000
            f:SetValue((t - ccstime) / (ccetime-ccstime))
            timertext:SetFormattedText("%.1f", (t - ccstime)/1000, (ccetime-ccstime)/1000)
            --ttext:SetFormattedText("%.1f", (ccetime - t)/1000)
        end
    end)

    return f
end