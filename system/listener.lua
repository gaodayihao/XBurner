local _, XB = ...

XB.Listener = {}
XB.Globals.Listener = XB.Listener

local listeners = {}

local frame = CreateFrame('Frame', 'XB_Events')
frame:SetScript('OnEvent', function(self, event, ...)
	if not listeners[event] then return end
	for k in pairs(listeners[event]) do
		listeners[event][k](...)
	end
end)

function XB.Listener:Add(name, event, callback)
	if not listeners[event] then
		frame:RegisterEvent(event)
		listeners[event] = {}
	end
	listeners[event][name] = callback
end

function XB.Listener:Remove(name, event)
	if listeners[event] then
		listeners[event][name] = nil
	end
end

function XB.Listener:Trigger(event, ...)
	onEvent(nil, event, ...)
end