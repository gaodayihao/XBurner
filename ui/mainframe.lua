local n_name, XB = ...
-- local logo = '|T'..XB.Media..'logo.blp:15:15|t'
local logo = ''
local L = XB.Locale

XB.Interface.MainFrame = XB.Interface:BuildGUI({
	key = 'XBMFrame',
	width = 100,
	height = 60,
	title = logo..n_name,
	subtitle = " v"..XB.Version..' - '..XB.Branch
})
XB.Interface.MainFrame:SetEventListener('OnClose', function(self)
	XB.Core:Print(L:TA('Any', 'XB_Show'))
end)

local menuFrame = CreateFrame("Frame", 'XB_DropDown', XB.Interface.MainFrame.frame, "UIDropDownMenuTemplate")
menuFrame:SetPoint("BOTTOMLEFT", XB.Interface.MainFrame.frame, "BOTTOMLEFT", 0, 0)
menuFrame:Hide()

local DropMenu = {
	{text = logo..'['..n_name..' |rv'..XB.Version..']', isTitle = 1, notCheckable = 1},
	{text = L:TA('mainframe', 'CRS'), hasArrow = true, menuList = {}, notCheckable = 1},
	{text = L:TA('mainframe', 'CRS_ST'), hasArrow = true, menuList = {}, notCheckable = 1}
}

function XB.Interface:ResetCRs()
	DropMenu[2].menuList = {}
end

function XB.Interface:SetCheckedCR(Name)
	for _,v in pairs(DropMenu[2].menuList) do
		v.checked = Name == v.text
	end
	XB.Core:Print(L:TA('mainframe', 'ChangeCR'), Name)
end

function XB.Interface:AddCR_ST(Name)
	table.insert(DropMenu[3].menuList, {
		text = Name,
		notCheckable = 1,
		func = function()
			self:BuildGUI(Name)
		end
	})
end

function XB.Interface:AddCR(Spec, Name, checked)
	table.insert(DropMenu[2].menuList, {
		text = Name,
		checked = checked,
		func = function()
			XB.CR:Set(Spec, Name)
		end
	})
end

function XB.Interface:DropMenu()
	EasyMenu(DropMenu, menuFrame, menuFrame, 0, 0, "MENU")
end

function XB.Interface:Add(name, func)
	table.insert(DropMenu, {
		text = tostring(name),
		func = func,
		notCheckable = 1
	})
end

XB.Globals.Interface.Add = XB.Interface.Add
