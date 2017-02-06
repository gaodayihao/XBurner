local _, XB  = ...
local C_Timer = C_Timer

XB.Protected = {}

local unlockers = {}

function XB.Protected:AddUnlocker(name, test, functions, extended, om)
	table.insert(unlockers, {
		name = name,
		test = test,
		functions = functions,
		extended = extended,
		om = om
	})
end

function XB.Protected.SetUnlocker(name, unlocker)
	XB.Core:Print('|cffff0000Found:|r ' .. name, '\nRemember to /reload after attaching a unlocker!')
	for uname, func in pairs(unlocker.functions) do
		XB.Protected[uname] = func
	end
	if unlocker.extended then
		for uname, func in pairs(unlocker.extended) do
			XB.Protected[uname] = func
		end
	end
	if unlocker.om then
		XB.AdvancedOM = true
		XB.OM.Maker = unlocker.om
	end
	XB.Unlocked = true
end

C_Timer.After(5, function ()
	C_Timer.NewTicker(0.2, (function()
		if XB.Unlocked or not XB.Interface:GetToggle('mastertoggle') then return end
		for i=1, #unlockers do
			local unlocker = unlockers[i]
			if unlocker.test() then
				XB.Protected.SetUnlocker(unlocker.name, unlocker)
				break
			end
		end
	end), nil)
end)

XB.Globals.AddUnlocker = XB.Protected.AddUnlocker
XB.Globals.AdvancedOM = XB.AdvancedOM
