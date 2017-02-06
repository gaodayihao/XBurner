local _, XB = ...

-- Locals
local UnitExists = ObjectExists or UnitExists
local date       = date
local UnitName   = UnitName

XB.ActionLog = {}

local Data = {}
local L = XB.Locale

local log_height = 16
local log_items = 10
local abs_height = log_height * log_items + log_height
local delta = 0

local XB_AL = XB.Interface:BuildGUI({
	key = 'XB_ALFrame',
	width = 460,
	height = abs_height,
})
XB.Interface:Add(L:TA('AL', 'Option'), function() XB_AL:Show() end)
XB_AL:Hide()

local headers = {
	{'TOPLEFT', 'Action', 5},
	{'TOPLEFT', 'Description', 130},
	{'TOPRIGHT', 'Time', -25}
}
for i=1, 3 do
	XB_AL.header = XB_AL.content:CreateFontString('XB_ALHeaderText')
	XB_AL.header:SetFont('Fonts\\ARIALN.TTF', log_height-3)
	XB_AL.header:SetPoint(headers[i][1], XB_AL.frame, headers[i][3], -4)
	XB_AL.header:SetText('|cff'..XB.Color..L:TA('AL', headers[i][2]))
end

XB_AL.frame:SetScript('OnMouseWheel', function(self, mouse)
	local top = #Data - log_items
	if mouse == 1 then
		if delta < top then
			delta = delta + mouse
		end
	elseif mouse == -1 then
		if delta > 0 then
			delta = delta + mouse
		end
	end
	XB.ActionLog:Update()
end)

local LogItem = { }
 headers[3][3] = -3

for i = 1, (log_items) do
	LogItem[i] = CreateFrame('Frame', nil, XB_AL.frame)
	LogItem[i]:SetFrameLevel(94)
	local texture = LogItem[i]:CreateTexture(nil, 'BACKGROUND')
	texture:SetAllPoints(LogItem[i])
	LogItem[i].texture = texture
	LogItem[i]:SetHeight(log_height)
	LogItem[i]:SetPoint('LEFT', XB_AL.frame, 'LEFT')
	LogItem[i]:SetPoint('RIGHT', XB_AL.frame, 'RIGHT')
	for k=1, 3 do
		LogItem[i][k] = LogItem[i]:CreateFontString('itemA')
		LogItem[i][k]:SetFont('Fonts\\ARIALN.TTF', log_height-3)
		LogItem[i][k]:SetShadowColor(0,0,0, 0.8)
		LogItem[i][k]:SetShadowOffset(-1,-1)
		LogItem[i][k]:SetPoint(headers[k][1], LogItem[i], headers[k][3], 0)
	end
	local position = ((i * log_height) * -1)
	LogItem[i]:SetPoint('TOPLEFT', XB_AL.frame, 'TOPLEFT', 0, position)
end

function XB.ActionLog:Refresh(event, spell, target)
	if Data[1] and Data[1]['event'] == event
	and Data[1]['description'] == spell
	and Data[1]['target'] == target then
		Data[1]['count'] = Data[1]['count'] + 1
		Data[1]['time'] = date('%H:%M:%S')
		self:Update()
		return true
	end
end

function XB.ActionLog:Add(event, spell, icon, target)
	target = UnitExists(target) and UnitName(target) or target
	event = event or 'Unknown'
	icon = icon or 'Interface\\ICONS\\Inv_gizmo_02.png'
	if self:Refresh(event, spell, target) then return end
	table.insert(Data, 1, {
		event = event,
		target = target,
		icon = icon,
		description = spell,
		count = 1,
		time = date('%H:%M:%S')
	})
	if delta > 0 and delta < #Data - log_items then
		delta = delta + 1
	end
	self:Update()
end

function XB.ActionLog:UpdateRow(row, a, b, c)
	LogItem[row][1]:SetText(a)
	LogItem[row][2]:SetText(b)
	LogItem[row][3]:SetText(c)
end

function XB.ActionLog:Update()
	local offset = 0
	for i = log_items, 1, -1 do
		offset = offset + 1
		local item = Data[offset + delta]
		if not item then
			self:UpdateRow(i, '', '', '')
		else
			local target = item.target and ' |cfffdcc00@|r (' .. item.target .. ')' or ''
			local icon = '|T'..item.icon..':'..(log_height-3)..':'..(log_height-3)..'|t'
			local desc = icon..' '..item.description..target..' [|cfffdcc00x'..item.count..'|r] '
			self:UpdateRow(i, '|cff85888c'..item.event..'|r', desc, '|cff85888c'..item.time..'|r')
		end
	end
end

-- wipe data when we enter combat
XB.Listener:Add('XB_AL','PLAYER_REGEN_DISABLED', function()
	wipe(Data)
end)
