local _, XB = ...

XB.Faceroll = {}

-- This to put an icon on top of the spell we want
local activeFrame = CreateFrame('Frame', 'activeCastFrame', UIParent)
activeFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
activeFrame:SetBackdropColor(0,0,0,1);
activeFrame.texture = activeFrame:CreateTexture()
activeFrame.texture:SetTexture("Interface/TARGETINGFRAME/UI-RaidTargetingIcon_8")
activeFrame.texture:SetPoint("CENTER")
activeFrame:SetFrameStrata('HIGH')
activeFrame:Hide()

-- Work in Progress...
local display = CreateFrame('Frame', 'Faceroll_Info', activeFrame)
display:SetClampedToScreen(true)
display:SetSize(0, 0)
display:SetPoint("TOP")
display:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
	edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
display:SetBackdropColor(0,0,0,1);
display.text = display:CreateFontString('PE_StatusText')
display.text:SetFont("Fonts\\ARIALN.TTF", 16)
display.text:SetPoint("CENTER", display)

function XB.Faceroll:Set(spell, target)
	local spellButton = XB.Buttons[spell]
	if not spellButton then return end
	local bSize = spellButton:GetWidth()
	activeFrame:SetSize(bSize+5, bSize+5)
	display:SetSize(display.text:GetStringWidth()+20, display.text:GetStringHeight()+20)
	activeFrame.texture:SetSize(activeFrame:GetWidth()-5,activeFrame:GetHeight()-5)
	activeFrame:SetPoint("CENTER", spellButton, "CENTER")
	display:SetPoint("TOP", spellButton, 0, display.text:GetStringHeight()+20)
	spell = '|cff'..XB.Color.."Spell:|r "..spell
	local isTargeting = '|cff'..XB.Color..tostring(UnitIsUnit("target", target or 'player'))
	target = '|cff'..XB.Color.."\nTarget:|r"..(UnitName(target or 'player') or '')
	display.text:SetText(spell..target.."("..isTargeting..")")
	activeFrame:Show()
end

function XB.Faceroll:Hide()
	activeFrame:Hide()
end
