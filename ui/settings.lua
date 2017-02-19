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

            { type = 'spacer'},
            { type = 'header', text = L:TA('Settings', 'combat'), align = 'Center'},{type = 'spacer'},
            { type = 'checkbox', text = L:TA('Settings', 'auto_target'), key = 'at', default = true, tooltip = L:TA('Settings','auto_target_tp')},
            { type = 'checkbox', text = L:TA('Settings', 'allow_player'), key = 'ap', default = false, tooltip = L:TA('Settings','allow_player_tp')},
            
            { type = 'spacer'},{type = 'ruler'},
            { type = 'header', text = L:TA('Settings', 'ui'),align = 'Center'},{type = 'spacer'},
            { type = 'spinner', text = L:TA('Settings', 'bsize'), key = 'bsize', default = 40, step = 5, min = 25, callback = callback, tooltip = L:TA('Settings','bsize_tp')},
            { type = 'spinner', text = L:TA('Settings', 'bpad'), key = 'bpad', default = 2, step = 1, max = 10, callback = callback, tooltip = L:TA('Settings','bpad_tp')},

            -- {type = 'ruler'},{type = 'spacer'},
            -- { type = 'button', text = L:TA('Settings', 'apply_bt'), align = 'center', with = 200, callback = callback}
        }
}

XB.STs = XB.Interface:BuildGUI(config)
XB.Interface:Add(L:TA('Settings', 'option'), function() XB.STs:Show() end)
XB.STs:Hide()
