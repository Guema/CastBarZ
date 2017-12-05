local AddonName, Addon = ...
local Addon = _G[AddonName]
local LSM = LibStub("LibSharedMedia-3.0")

assert(Addon ~= nil, AddonName .. " could not be load")

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
local CHANNELING = CHANNELING

local LATENCY_TOLERENCE = 100

function Addon:CreateModel(Name, Parent, ...)
    Parent = Parent or UIParent
    local obj = CreateFrame("PlayerModel", Name, Parent, ...)
    local base = getmetatable(obj).__index
    local mdl
    function obj:SetModel(path)
        mdl = path
    end

    obj:SetScript(
        "OnModelLoaded",
        function(self)
            --self:MakeCurrentCameraCustom()
            self:SetPortraitZoom(1)
            self:ClearTransform()
            --self:SetPosition(3, 0, -1)
            self:SetTransform(1, 0, 0.050, 0, 0, 0, 0.200)
            --self:SetCameraPosition(0, 0, 0)
        end
    )

    obj:SetScript(
        "OnShow",
        function(self)
            pcall(base.SetModel, self, mdl)
        end
    )

    obj:SetScript(
        "OnSizeChanged",
        function(self, w, h)
            if w < 0.5 or h < 0.5 then
                self:Hide()
            else
                self:Show()
            end
        end
    )

    return obj
end

function Addon:CreateBoundedModel(Name, Parent, ...)
    Parent = Parent or UIParent
    local obj = CreateFrame("Frame", Name, Parent, ...)
    local base = getmetatable(obj).__index
    local mdl = self:CreateModel(nil, obj)
    --mdl:SetFrameLevel(3)

    function obj:SetModel(path)
        mdl:SetModel(path)
    end

    function obj:GetBoundedModel()
        return mdl
    end

    mdl:SetScript(
        "OnModelLoaded",
        function(self)
            --self:MakeCurrentCameraCustom()
            self:SetPortraitZoom(1)
            self:ClearTransform()
            self:SetPosition(3, 0, -1)
            obj:SetClipsChildren(true)

            --self:SetTransform(1, 0, 0.050, 0, 0, 0, 0.200)
            --self:SetCameraPosition(0, 0, 0)
            --obj:SetScrollChild(frm)
        end
    )

    obj:SetScript(
        "OnSizeChanged",
        function(self, w, h)
            if w < 0.5 or h < 0.5 then
                mdl:Hide()
            else
                mdl:Show()
            end
        end
    )

    return obj
end

function Addon:CreateCastingBar3D(Unit, Parent)
    Parent = Parent or UIParent
    assert(type(Unit) == "string", "Usage : CreateCastingBar3D(Unit[, Parent]) : Wrong argument type for Unit argument")
    local config = assert(self.db.profile[Unit], "Unit has no db")

    local f = self.CreateSparkleStatusBar(AddonName .. Unit, Parent)
    local l = CreateFrame("StatusBar", nil, f)
    local textoverlay = CreateFrame("Frame", nil, f)

    f:Hide()
    f:SetSize(config.width, config.height)
    f:SetPoint("CENTER", Parent, "BOTTOM", config.xoffset, config.yoffset)

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
    f:SetStatusBarColor(0.3, 0.72, 1)
    t:SetGradientAlpha("HORIZONTAL", 0, 0.47, 0.8, 1, 0.4, 0.8, 1, 1.0)
    f:SetFillStyle("STANDARD")
    f:SetMinMaxValues(0.0, 1.0)

    local m = self:CreateBoundedModel(nil, f)
    m:SetModel("Spells\\Lightning_Area_Disc_State.M2")
    m:SetFrameLevel(2)
    m:SetAllPoints(f:GetStatusBarTexture())
    m:GetBoundedModel():SetAllPoints(f)

    textoverlay:SetAllPoints(f)
    textoverlay:SetFrameLevel(3)
    local nametext = textoverlay:CreateFontString()
    nametext:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    nametext:SetAllPoints(f)
    nametext:SetTextColor(1, 1, 1)

    local timertext = textoverlay:CreateFontString()
    timertext:SetPoint("TOPLEFT", f, "TOPRIGHT", -60, 0)
    timertext:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 0)
    timertext:SetWidth(60)
    timertext:SetFont("Fonts\\FRIZQT__.TTF", 8, "OUTLINE")
    timertext:SetJustifyH("RIGHT")

    l:SetFrameLevel(1)
    l:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
    l:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
    l:SetHeight(24)

    l:SetStatusBarTexture(LSM:Fetch("statusbar", "Solid"))
    l:GetStatusBarTexture():SetGradientAlpha("HORIZONTAL", 1.0, 0.878, 0.298, 1, 1.0, 0.827, 0, 1.0)
    l:SetAlpha(0.5)
    l:SetFillStyle("REVERSE")
    l:SetMinMaxValues(0.0, 1.0)

    f.fadein = f:CreateAnimationGroup()
    f.fadein:SetLooping("NONE")
    local alpha = f.fadein:CreateAnimation("Alpha")
    alpha:SetDuration(0.2)
    alpha:SetFromAlpha(0.0)
    alpha:SetToAlpha(1.0)
    alpha:SetSmoothing("IN_OUT")

    f.fadeout = f:CreateAnimationGroup()
    f.fadeout:SetLooping("NONE")
    local alpha = f.fadeout:CreateAnimation("Alpha")
    alpha:SetDuration(0.2)
    alpha:SetFromAlpha(1.0)
    alpha:SetToAlpha(0.0)
    alpha:SetStartDelay(0.4)
    alpha:SetSmoothing("IN_OUT")

    local currently_casting = false

    function f:GetCurrentlyCasting()
        return currently_casting
    end

    f.fadein:SetScript(
        "OnPlay",
        function(self, ...)
            currently_casting = true
            f.fadeout:Stop()
            f:SetShown(true)
        end
    )

    f.fadeout:SetScript(
        "OnPlay",
        function(self, ...)
            currently_casting = false
        end
    )

    f.fadeout:SetScript(
        "OnFinished",
        function(self, ...)
            f:SetShown(false)
        end
    )

    do
        local ccname, cctext, cctexture, ccstime, ccetime, currentTime, cccastID

        f:RegisterEvent(
            "UNIT_SPELLCAST_START",
            function(event, unit, ...)
                if (unit ~= Unit) then
                    return
                end
                ccname, _, cctext, cctexture, ccstime, ccetime, _, cccastID = UnitCastingInfo(unit)
                currentTime = ccstime
                l:SetValue(LATENCY_TOLERENCE / (ccetime - ccstime))
                nametext:SetFormattedText("%s", string.sub(cctext, 1, 40))
                f.fadein:Play()
            end
        )

        f:RegisterEvent(
            "UNIT_SPELLCAST_CHANNEL_START",
            function(event, unit, ...)
                if (unit ~= Unit) then
                    return
                end
                ccname, _, cctext, cctexture, ccetime, ccstime, _, cccastID = UnitChannelInfo(unit)
                currentTime = ccetime
                l:SetValue(0)
                nametext:SetFormattedText("%s", string.sub(ccname, 1, 40))
                f.fadein:Play()
            end
        )

        f:RegisterEvent(
            "UNIT_SPELLCAST_STOP",
            function(event, unit, name, rank, castid, spellid)
                if (unit ~= Unit) then
                    return
                end
                f.fadeout:Play()
            end
        )

        f:RegisterEvent(
            "UNIT_SPELLCAST_CHANNEL_STOP",
            function(event, unit, name, rank, castid, spellid)
                if (unit ~= Unit) then
                    return
                end
                f.fadeout:Play()
            end
        )

        f:RegisterEvent(
            "UNIT_SPELLCAST_INTERRUPTED",
            function(event, unit, name, rank, castid, spellid)
                if (unit ~= Unit) then
                    return
                end
                local val = f:GetMinMaxValues()
                nametext:SetText(INTERRUPTED)
                timertext:SetText("")
                f:SetValue(0)
                l:SetValue(0)
                f.fadeout:Play()
            end
        )

        f:RegisterEvent(
            "UNIT_SPELLCAST_SUCCEEDED",
            function(event, unit, name, rank, castid, spellid)
                if (unit ~= Unit) then
                    return
                end
                if (castid == cccastID) then
                    local _, val = f:GetMinMaxValues()
                    currentTime = ccetime
                    f:SetValue(val)
                end
            end
        )

        f:SetScript(
            "OnUpdate",
            function(self, rate)
                if (currently_casting) then
                    local nmin, nmax = f:GetMinMaxValues()
                    currentTime = GetTime() * 1000
                    f:SetValue((currentTime - ccstime) / (ccetime - ccstime))
                    timertext:SetFormattedText(
                        "%.1f",
                        math.abs((currentTime - ccstime) / 1000),
                        math.abs((ccetime - ccstime) / 1000)
                    )
                end
            end
        )
    end

    return f
end
