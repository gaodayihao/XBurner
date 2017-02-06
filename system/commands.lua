local _, XB = ...

XB.Commands = {}

function XB.Commands:Register(name, func, ...)
	SlashCmdList[name] = func
	local command
	for i = 1, select('#', ...) do
		command = select(i, ...)
		if command:sub(1, 1) ~= '/' then
			command = '/' .. command
		end
		_G['SLASH_'..name..i] = command
	end
end

XB.Globals.RegisterCommand = XB.Commands.Register
