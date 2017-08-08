local AddonName, AddonTable = ...
local Addon = _G[AddonName]
local LEW = LibStub("LibEventWrapper-1.0")

local getmetatable = getmetatable
local math = math



assert(Addon ~= nil, AddonName.." could not be load")

local WIDTH_FACTOR = 0.45
local HEIGHT_FACTOR = 1.8

function Addon.CreateSparkleStatusBar(Name, Parent, ...)
    local obj = LEW:WrapFrame(CreateFrame("StatusBar", Name, Parent, ...))
    local base = getmetatable(obj).__index
    local vmin, vmax = base.GetMinMaxValues(obj)
    local sparkleR, sparkleL = obj:CreateTexture(), obj:CreateTexture()
    local fillStyle = base.GetFillStyle(obj)

    sparkleR:SetBlendMode("ADD")
    sparkleL:SetBlendMode("ADD") 

    function obj:SetSparkleTexture(texture)
        sparkleR:SetTexture(texture)
        sparkleL:SetTexture(texture)
    end

    function obj:GetSparkleTexture()
        return sparkleR, sparkleL
    end

    hooksecurefunc(obj, "SetStatusBarTexture", function(self, texture)
        sparkleR:SetPoint("CENTER", texture, "RIGHT")
        sparkleL:SetPoint("CENTER", texture, "LEFT")
    end)

    hooksecurefunc(obj, "SetMinMaxValues", function(self, newvmin, newvmax)
        vmin, vmax = newvmin, newvmax
    end)

    hooksecurefunc(obj, "SetStatusBarColor", function(self, r, g, b, a)
        sparkleR:SetVertexColor(r, g, b, a)
        sparkleL:SetVertexColor(r, g, b, a)
    end)

    hooksecurefunc(obj, "SetFillStyle", function(self, style)
        fillStyle = base.GetFillStyle(obj)
    end)

    obj:SetScript("OnSizeChanged", function(self, w, h)
        sparkleR:SetSize(h * WIDTH_FACTOR, h * HEIGHT_FACTOR)
        sparkleL:SetSize(h * WIDTH_FACTOR, h * HEIGHT_FACTOR)
    end)

    obj:SetScript("OnValueChanged", function(self, val) 
        if(fillStyle == "STANDARD" or fillStyle == "STANDARD_NO_RANGE_FILL" or fillStyle == "CENTER") then
            sparkleR:Show()
        else
            sparkleR:Hide()
        end
        if(fillStyle == "REVERSE" or fillStyle == "CENTER") then
            sparkleL:Show()
        else
            sparkleL:Hide()
        end
    end)

    return obj
end