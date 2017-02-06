local n_name, XB = ...
local L           = XB.Locale

local callback = function()
	XB.ButtonsSize = XB.Config:Read(n_name..'_Settings', 'bsize', 40)
	XB.ButtonsPadding = XB.Config:Read(n_name..'_Settings', 'bpad', 2)
	XB.Interface:RefreshToggles()
end

local config = {
    key = n_name..'_Settings',
    title = n_name,
    subtitle = L:TA('Settings', 'option'),
    width = 250,
    height = 270,
    config = {
			{ type = 'header', text = n_name..' |r v'..XB.Version..' '..XB.Branch, size = 25, align = 'Center'},
			{ type = 'spinner', text = L:TA('Settings', 'bsize'), key = 'bsize', default = 40, step = 5, min = 25, callback = callback},
			{ type = 'spinner', text = L:TA('Settings', 'bpad'), key = 'bpad', default = 2, step = 1, max = 10, callback = callback},

  			-- {type = 'ruler'},{type = 'spacer'},
			-- { type = 'button', text = L:TA('Settings', 'apply_bt'), align = 'center', with = 200, callback = callback}
		}
}

XB.STs = XB.Interface:BuildGUI(config)
XB.Interface:Add(L:TA('Settings', 'option'), function() XB.STs:Show() end)
XB.STs:Hide()
