local _, XB = ...

XB.FakeUnits = {}
XB.Globals.FakeUnits = XB.FakeUnits
local Units = {}

function XB.FakeUnits:Add(Name, Func)
	if not Units[Name] then
		Units[Name] = Func
	end
end

function XB.FakeUnits:Filter(unit)
	for token,func in pairs(Units) do
		if unit:find(token) then
			local arg2 = unit:match('%((.+)%)')
			local num = unit:match("%d+") or 1
			return func(tonumber(num), arg2)
		end
	end
	return unit
end