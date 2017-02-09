local _, XB = ...
XB.Runer   = {}

-- Local stuff for speed
local GetTime              = GetTime
local UnitBuff             = UnitBuff
local UnitIsDeadOrGhost    = UnitIsDeadOrGhost
local SecureCmdOptionParse = SecureCmdOptionParse
local InCombatLockdown     = InCombatLockdown
local C_Timer              = C_Timer

local function IsMountedCheck()
	for i = 1, 40 do
		local mountID = select(11, UnitBuff('player', i))
		if mountID and XB.ByPassMounts(mountID) then
			return true
		end
	end
	return (SecureCmdOptionParse("[overridebar][vehicleui][possessbar,@vehicle,exists][mounted]true")) ~= "true"
end

function XB.Runer.Run(exe)
	return exe()
end

-- Delay until everything is ready
XB.Core:WhenInGame(function()

C_Timer.NewTicker(0.1, (function()
	XB.Faceroll:Hide()
	if XB.Interface:GetToggle('mastertoggle') and not XB.CR.CRChanging then
		if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
			if XB.Queuer:Execute() then return end
			local exe = XB.CR.CR[InCombatLockdown()]
			XB.Runer.Run(exe)
		end
	end
end), nil)

end, 99)
