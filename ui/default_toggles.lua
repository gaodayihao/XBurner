local _, XB = ...
local L = XB.Locale

local dToggles = {
	{
		key = 'mastertoggle',
		name = 'MasterToggle',
		text = L:TA('mainframe', 'MasterToggle'),
		icon = 'Interface\\ICONS\\Ability_repair.png',
		func = (function(self, button)
			if button == "RightButton" then
				-- if IsControlKeyDown() then
				-- 	XB.Interface.MainFrame.drag:Show()
				-- else
					XB.Interface:DropMenu()
				-- end
			end
		end),
        default = true
	},
	{
		key = 'aoe',
		name = 'Multitarget',
		text = L:TA('mainframe', 'AoE'),
		icon = 'Interface\\ICONS\\Ability_Druid_Starfall.png',
        default = true
	},
	{
		key = 'cooldowns',
		name = 'Cooldowns',
		text = L:TA('mainframe', 'Cooldowns'),
		icon = 'Interface\\ICONS\\Achievement_BG_winAB_underXminutes.png',
        default = true
	},
	{
		key = 'cooldownsonboss',
		name = 'CooldownsOnBoss',
		text = L:TA('mainframe', 'CooldownsOnBoss'),
		icon = 59752,
        default = false
	},
	{
		key = 'interrupts',
		name = 'Interrupts',
		text = L:TA('mainframe', 'Interrupts'),
		icon = 'Interface\\ICONS\\Ability_Kick.png',
        default = true
	},
}

function XB.Interface:DefaultToggles()
	for i=1, #dToggles do
		self:AddToggle(dToggles[i])
	end
end