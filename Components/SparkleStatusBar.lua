local AddonName, AddonTable = ...
local Addon = _G[AddonName]
local getmetatable = getmetatable
local LEW = LibStub("LibEventWrapper-1.0")

assert(Addon ~= nil, AddonName.." could not be load")

local WIDTH_FACTOR = 0.45
local HEIGHT_FACTOR = 1.8

function Addon.CreateSparkleStatusBar(Name, Parent, ...)
    local obj = LEW:WrapFrame(CreateFrame("StatusBar", Name, Parent, ...))
    local base = getmetatable(obj).__index
    local nmin, nmax = obj:GetMinMaxValues()
    local showR, showL = true, false
    local sparkleR, sparkleL = obj:CreateTexture(), obj:CreateTexture()

    sparkleR:SetBlendMode("ADD")
    sparkleL:SetBlendMode("ADD") 

    function obj:SetSparkleTexture(texture)
        sparkleR:SetTexture(texture)
        sparkleL:SetTexture(texture)
    end

    function obj:GetSparkleTexture()
        return sparkleR, sparkleL
    end

    function obj:SetStatusBarTexture(texture)
        base.SetStatusBarTexture(self, texture)
        local texture = base.GetStatusBarTexture(self)
        sparkleR:SetPoint("CENTER", texture, "RIGHT")
        sparkleL:SetPoint("CENTER", texture, "LEFT")
    end

    function obj:SetStatusBarColor(r, g, b, a)
        base.SetStatusBarColor(self, r, g, b, a)
        sparkleR:SetVertexColor(r*1.1, g*1.1, b*1.1, a)
        sparkleL:SetVertexColor(r*1.1, g*1.1, b*1.1, a)
    end

    function obj:SetFillStyle(style)
        base.SetFillStyle(self, style)
        if(style == "STANDARD" or style == "STANDARD_NO_RANGE_FILL") then
            showR, showL = true, false
        elseif (style == "REVERSE") then
            showR, showL = false, true
        elseif (style == "CENTER") then
            showR, showL = true, true
        end
    end

    obj:SetScript("OnMinMaxChanged", function(self, newmin, newmax)
        nmin, nmax = newmin, newmax
    end)

    obj:SetScript("OnSizeChanged", function(self, w, h)
        sparkleR:SetSize(h * WIDTH_FACTOR, h * HEIGHT_FACTOR)
        sparkleL:SetSize(h * WIDTH_FACTOR, h * HEIGHT_FACTOR)
    end)

    obj:SetScript("OnValueChanged", function(self, val)
        if (val > nmin and val < nmax) then
            if(showR) then sparkleR:Show() else sparkleR:Hide() end
            if(showL) then sparkleL:Show() else sparkleL:Hide() end
        else
            sparkleR:Hide()
            sparkleL:Hide()
        end
    end)

    return obj
end