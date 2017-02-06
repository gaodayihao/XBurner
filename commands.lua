local _, XB = ...
local T = XB.Interface.toggleToggle

local L = {
	mastertoggle   = function(state) T(self,'MasterToggle', state) end,
	aoe            = function(state) T(self,'AoE', state) end,
	cooldowns      = function(state) T(self,'Cooldowns', state) end,
	interrupts     = function(state) T(self,'Interrupts', state) end,
    version        = function() XB.Core:Print(XB.Version) end,
    show 			= function() XB.Interface.MainFrame:Show() end,
	hide = function()
		XB.Interface.MainFrame:Hide()
		XB.Core:Print(L:TA('Any', 'XB_Show'))
	end,
}

L.mt = L.mastertoggle
L.toggle = L.mastertoggle
L.tg = L.mastertoggle
L.ver = L.version

XB.Commands:Register('XB', function(msg)
	local command, rest = msg:match("^(%S*)%s*(.-)$");
	command, rest = tostring(command):lower(), tostring(rest):lower()
	rest = rest == 'on' or false
	if L[command] then L[command](rest) end
end, 'xb', 'xburner')