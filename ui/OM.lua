local _, XB = ...

local DiesalGUI = LibStub('DiesalGUI-1.0')
local SharedMedia = LibStub("LibSharedMedia-3.0")
local L = XB.Locale
local noop = function() end
local TargetUnit = XB.Unlocked and TargetUnit or noop

local statusBars = {}
local statusBarsUsed = {}

local parent = XB.Interface:BuildGUI({
    key = 'XBOMgui',
    width = 500,
    height = 250,
    title = L:TA('OM', 'Title')
})
parent:Hide()
XB.Interface:Add(L:TA('OM', 'Option'), function() parent:Show() end)

local dOM = 'Enemy'
local bt = {
    ENEMIE = {a = 'TOPLEFT', b = 'Enemy', x = 0},
    EnemyVerify = {a = 'TOP', b = 'EnemyVerify', x = -parent.content:GetWidth()/8},
    FRIENDLY = {a = 'TOP', b = 'Friendly', x = parent.content:GetWidth()/8},
    DEAD = {a = 'TOPRIGHT', b = 'Dead', x = 0}
}
for k,v in pairs(bt) do
    bt[k] = DiesalGUI:Create("Button")
    parent:AddChild(bt[k])
    bt[k]:SetParent(parent.content)
    bt[k]:SetPoint(v.a, parent.content, v.a, v.x,0)
    bt[k]:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10)
    bt[k].frame:SetSize(parent.content:GetWidth()/4, 20)
    bt[k]:AddStyleSheet(XB.UI.buttonStyleSheet)
    bt[k]:SetEventListener("OnClick", function() dOM = v.b end)
    bt[k]:SetText(L:TA('OM', v.b))
end

local ListWindow = DiesalGUI:Create('ScrollFrame')
parent:AddChild(ListWindow)
ListWindow:SetParent(parent.content)
ListWindow:SetPoint("TOP", parent.content, "TOP", 0, -15)
ListWindow.frame:SetSize(parent.content:GetWidth(), parent.content:GetHeight()-20)
ListWindow.parent = parent

local function getStatusBar()
    local statusBar = tremove(statusBars)
    if not statusBar then
        statusBar = DiesalGUI:Create('StatusBar')
        statusBar:SetParent(ListWindow.content)
        parent:AddChild(statusBar)
        statusBar.frame:SetStatusBarColor(1,1,1,0.35)
    end
    statusBar:Show()
    table.insert(statusBarsUsed, statusBar)
    return statusBar
end

local function recycleStatusBars()
    for i = #statusBarsUsed, 1, -1 do
        statusBarsUsed[i]:Hide()
        tinsert(statusBars, tremove(statusBarsUsed))
    end
end

local function RefreshGUI()
    local offset = -5
    recycleStatusBars()
	local units = dOM == 'EnemyVerify' and XB.Area:Enemies() or XB.OM:Get(dOM)
    for _, Obj in pairs(units) do
        local Health = math.floor(((UnitHealth(Obj.key) or 1) / (UnitHealthMax(Obj.key) or 1) * 100))
        local statusBar = getStatusBar()
        local distance = XB.Protected.Distance(Obj.key)
        statusBar.frame:SetPoint('TOP', ListWindow.content, 'TOP', 2, offset )
        statusBar.frame.Left:SetText('|cff'..XB.Core:ClassColor(Obj.key, 'hex')..Obj.name)
        statusBar.frame.Right:SetText('( |cff0070deID|r: '..Obj.id..' / |cffabd473Health|r: '..Health..' / |cfffff569Dist|r: '..distance..' )')
        statusBar.frame:SetScript('OnMouseDown', function(self) TargetUnit(Obj.key) end)
        statusBar:SetValue(Health)
        offset = offset -18
    end
end

C_Timer.NewTicker(0.1, (function()
    if parent:IsShown() then
        RefreshGUI()
    end
end), nil)
