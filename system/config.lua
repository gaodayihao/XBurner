local n_name, XB = ...

XB.Config = {}
local Data = {}

XB.Listener:Add("XB_Config", "ADDON_LOADED", function(addon)
	if addon:lower() == n_name:lower() then
		if XBDATA == nil then
			XBDATA = {}
		end
		Data = XBDATA
	end
end)

function XB.Config:Read(a, b, default)
	-- only return default if its nil in data
	if Data[a] and Data[a][b] ~= nil then
		return Data[a][b]
	end
	return default
end

function XB.Config:Write(a, b, value)
	if not Data[a] then
		Data[a] = {}
	end
	Data[a][b] = value
end
