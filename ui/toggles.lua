local n_name, XB = ...
local mainframe = XB.Interface.MainFrame
local L = XB.Locale
local GameTooltip = GameTooltip

XB.ButtonsSize = 40
XB.ButtonsPadding = 2


local GenericIconOff = [[Interface\GLUES\CREDITS\Arakkoa1]]
local GenericIconOn = [[Interface/BUTTONS/CheckButtonGlow]]
local SharedMedia = LibStub("LibSharedMedia-3.0")

-- Load Saved sizes
XB.Core:WhenInGame(function()
    XB.ButtonsSize = XB.Config:Read(n_name..'_Settings', 'bsize', 40)
    XB.ButtonsPadding = XB.Config:Read(n_name..'_Settings', 'bpad', 2)
    XB.Interface:RefreshToggles()
end)

local Toggles = {}
local tIndex = 0

local function SetTexture(parent, icon)
    local temp = parent:CreateTexture()
    local isChecked = isChecked or false
    if icon and type(icon) == "number" then
        icon = select(3,GetSpellInfo(icon))
    end
    if icon then
        temp:SetTexture(icon)
        temp:SetTexCoord(.08, .92, .08, .92)
    end
    temp:SetAllPoints(parent)
    return temp
end

local function OnClick(self, func, button)
    if button == 'LeftButton' then
        self.actv = not self.actv
        XB.Config:Write('TOGGLE_STATES', self.key, self.actv)
        if self.actv then
            self.Checked_Frame.texture:SetTexture(GenericIconOn)
        else
            self.Checked_Frame.texture:SetTexture(GenericIconOff)
        end
    end
    if func then
        func(self, button)
    end
    self:SetChecked(self.actv)
end

local function OnEnter(self, name, text)
    local OnOff = self.actv and L:TA('Any', 'ON') or L:TA('Any', 'OFF')
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:AddDoubleLine(name, OnOff)
    if text then
        GameTooltip:AddLine('|cffFFFFFF'..text)
    end
    GameTooltip:Show()
end

local function CreateToggle(eval)
    eval.key = eval.key:lower()
    Toggles[eval.key] = CreateFrame("CheckButton", eval.key, mainframe.content)
    local temp = Toggles[eval.key]
    temp.index = tIndex
    tIndex = tIndex + 1
    temp:SetFrameStrata("high")
    temp:SetFrameLevel(1)
    temp.key = eval.key
    temp:SetSize(XB.ButtonsSize*0.8, XB.ButtonsSize*0.8)
    temp:SetFrameLevel(1)
    temp:SetNormalFontObject("GameFontNormal")
    temp.texture = SetTexture(temp, eval.icon)
    temp.actv = XB.Config:Read('TOGGLE_STATES', eval.key, eval.default or false)
    XB.Config:Write('TOGGLE_STATES', eval.key, temp.actv)
    temp:SetChecked(temp.actv)
    temp.text = temp:CreateFontString(nil,'OVERLAY')
    temp.text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 20,'THICKOUTLINE')
    temp.text:SetJustifyH("CENTER")
    temp.text:SetTextColor(1,1,1,1)
    temp:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    temp:SetScript("OnClick", function(self, button) OnClick(self, eval.func, button) end)
    temp:SetScript("OnEnter", function(self) OnEnter(self, eval.name, eval.text) end)
    temp:SetScript("OnLeave", function() GameTooltip:Hide() end)
    local tempFrame = CreateFrame("Frame", nil, temp)
    tempFrame:SetSize(XB.ButtonsSize*1.67, XB.ButtonsSize*1.67)
    tempFrame:SetPoint("CENTER")
    tempFrame.texture = tempFrame:CreateTexture(temp, "OVERLAY")
    tempFrame.texture:SetAllPoints()
    tempFrame.texture:SetAlpha(100)
    if temp.actv then
        tempFrame.texture:SetTexture(GenericIconOn)
    else
        tempFrame.texture:SetTexture(GenericIconOff)
    end

    temp.Checked_Frame = tempFrame
end

function XB.Interface:UpdateIcon(key, icon)
    if not icon or not Toggles[key] then return end
    if icon and type(icon) == "number" then
        icon = select(3,GetSpellInfo(icon))
    end
    Toggles[key].texture:SetTexture(icon)
end

function XB.Interface:UpdateToggleText(key, text)
    if not text or not Toggles[key] then return end
    Toggles[key].text:SetText(text)
end

function XB.Interface:AddToggle(eval)
    if Toggles[eval.key] then
        Toggles[eval.key]:Show()
    else
        CreateToggle(eval)
    end
    XB.Interface:RefreshToggles()
end

function XB.Interface:RefreshToggles()
    local temp = {}
    for k in pairs(Toggles) do
        if Toggles[k]:IsShown() then
            table.insert(temp,Toggles[k])
        end
    end
    table.sort( temp, function(a,b) return a.index < b.index end )
    for i = 1,#temp do
        local pos = (XB.ButtonsSize*i)+(i*XB.ButtonsPadding)-(XB.ButtonsSize+XB.ButtonsPadding) - (XB.ButtonsSize*(i-2)) *0.1 
        temp[i]:SetSize(XB.ButtonsSize*0.8, XB.ButtonsSize*0.8)
        temp[i].Checked_Frame:SetSize(XB.ButtonsSize*1.67, XB.ButtonsSize*1.67)
        temp[i]:SetPoint("LEFT", mainframe.content, pos, 0)

        temp[i].text:SetTextHeight(XB.ButtonsSize/3)
        temp[i].text:SetPoint("CENTER",0,0)
    end
    mainframe.settings.width = #temp*(XB.ButtonsSize+XB.ButtonsPadding)-XB.ButtonsPadding - (XB.ButtonsSize*(#temp-2)) *0.1
    mainframe.settings.height = XB.ButtonsSize+18

    mainframe.settings.minHeight = mainframe.settings.height
    mainframe.settings.minWidth = mainframe.settings.width
    mainframe.settings.maxHeight = mainframe.settings.height
    mainframe.settings.maxWidth = mainframe.settings.width
    mainframe:ApplySettings()
end

function XB.Interface:ResetToggles()
    for k in pairs(Toggles) do
        Toggles[k]:Hide()
    end
    self:DefaultToggles()
end

function XB.Interface:toggleToggle(key, state)
    local self = Toggles[key:lower()]
    if not self then return end
    self.actv = state or not self.actv
    self:SetChecked(self.actv)
    XB.Config:Write('TOGGLE_STATES', self.key, self.actv)
    if self.actv then
        self.Checked_Frame.texture:SetTexture(GenericIconOn)
    else
        self.Checked_Frame.texture:SetTexture(GenericIconOff)
    end
end

function XB.Interface:GetToggle(toggle)
    return XB.Config:Read('TOGGLE_STATES', toggle:lower(), false)
end

-- Globals
XB.Globals.Interface.toggleToggle = XB.Interface.toggleToggle
XB.Globals.Interface.AddToggle = XB.Interface.AddToggle
XB.Globals.Interface.GetToggle = XB.Interface.GetToggle
