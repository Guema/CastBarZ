
local AddonName, AddonTable = ...
local LSM = LibStub("LibSharedMedia-3.0")

_G[AddonName] = _G[AddonName] or LibStub("AceAddon-3.0"):NewAddon(AddonName)
local Addon = _G[AddonName]


--[[ global refs ]]--

local _G = _G
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local GetNetStats = _G.GetNetStats
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local IsHarmfulSpell = _G.IsHarmfulSpell
local IsHelpfulSpell = _G.IsHelpfulSpell
local pairs = _G.pairs
local AceGUI = LibStub("AceGUI-3.0")

function Addon:OnInitialize()
    --_G.CastingBarFrame.ignoreFramePositionManager = true
    _G.CastingBarFrame:UnregisterAllEvents()
    LSM:Register("statusbar", "Solid", "Interface\\AddOns\\"..AddonName.."\\Media\\Solid")
end

function Addon:OnEnable()
    self.CastingBar = self:CreateCastingBarFrame("player")

    --self.Model:Hide()
    --[[
    -- Create a container frame
    local f = AceGUI:Create("Frame")
    f:SetCallback("OnClose",function(widget) AceGUI:Release(widget) end)
    f:SetTitle("AceGUI-3.0 Example")
    f:SetStatusText("Status Bar")
    f:SetLayout("Flow")
    --local btn = AceGUI:Create("Button")
    --btn:SetWidth(170)
    --btn:SetText("Button !")
    --btn:SetCallback("OnClick", function() print("Click!") end)
    -- Add the button to the container
    --f:AddChild(btn)
    local sliderX, sliderY, sliderZ = AceGUI:Create("Slider"), AceGUI:Create("Slider"), AceGUI:Create("Slider")

    sliderX:SetSliderValues(-50, 50, 0.01)
    sliderY:SetSliderValues(-50, 50, 0.01)
    sliderZ:SetSliderValues(-50, 50, 0.01)

    sliderX:SetValue(0)
    sliderY:SetValue(0)
    sliderZ:SetValue(0)

    f:DoLayout()
    
    local function displayResult()
        print(m:GetPosition())
    end

    local function callback()
        m:SetPosition(sliderX:GetValue(), sliderY:GetValue(), sliderZ:GetValue())
        displayResult()
    end

    sliderX:SetCallback("OnValueChanged", callback)
    sliderY:SetCallback("OnValueChanged", callback)
    sliderZ:SetCallback("OnValueChanged", callback)

    sliderX:SetCallback("OnMouseUp", displayResult)
    sliderY:SetCallback("OnMouseUp", displayResult)
    sliderZ:SetCallback("OnMouseUp", displayResult)
    
    f:AddChild(sliderX)
    f:AddChild(sliderY)
    f:AddChild(sliderZ)
    --]]
end