local _, XB = ...

-- Locals
local GetActionInfo                = GetActionInfo
local ActionButton_CalculateAction = ActionButton_CalculateAction
local GetSpellInfo                 = GetSpellInfo
local wipe                         = wipe

XB.Buttons = {}

local nBars = {
	"ActionButton",
	"MultiBarBottomRightButton",
	"MultiBarBottomLeftButton",
	"MultiBarRightButton",
	"MultiBarLeftButton"
}

local function UpdateButtons()
	wipe(XB.Buttons)
	for _, group in ipairs(nBars) do
		for i =1, 12 do
			local button = _G[group .. i]
			if button then
				local actionType, id = GetActionInfo(ActionButton_CalculateAction(button, "LeftButton"))
				if actionType == 'spell' then
					local spell = GetSpellInfo(id)
					if spell then
						XB.Buttons[spell] = button
					end
				end
			end
		end
	end
end

XB.Listener:Add('XB_Buttons','PLAYER_ENTERING_WORLD', function ()
	UpdateButtons()
end)

XB.Listener:Add('XB_Buttons','ACTIONBAR_SLOT_CHANGED', function ()
	UpdateButtons()
end)
