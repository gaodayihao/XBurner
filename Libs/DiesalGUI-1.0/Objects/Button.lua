-- $Id: Button.lua 54 2016-07-19 00:35:10Z diesal2010 $

local DiesalGUI = LibStub("DiesalGUI-1.0")
-- ~~| Libraries |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local DiesalTools = LibStub("DiesalTools-1.0")
local DiesalStyle = LibStub("DiesalStyle-1.0")
-- ~~| Lua Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local type, tonumber, select 											= type, tonumber, select 	
local pairs, ipairs, next												= pairs, ipairs, next
local min, max					 											= math.min, math.max	
-- ~~| WoW Upvalues |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local CreateFrame, UIParent, GetCursorPosition 					= CreateFrame, UIParent, GetCursorPosition
local GetScreenWidth, GetScreenHeight								= GetScreenWidth, GetScreenHeight	
local GetSpellInfo, GetBonusBarOffset, GetDodgeChance			= GetSpellInfo, GetBonusBarOffset, GetDodgeChance
local GetPrimaryTalentTree, GetCombatRatingBonus				= GetPrimaryTalentTree, GetCombatRatingBonus
-- ~~| Button |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local TYPE 		= "Button"
local VERSION 	= 5
-- ~~| Button StyleSheets |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local styleSheet = {
	['text-color'] = {
		type			= 'Font',
		color			= 'b8c2cc',
	},
}
local wireFrame = {	
	['frame-white'] = {				
		type			= 'outline',
		layer			= 'OVERLAY',
		color			= 'ffffff',	
	},		
}
-- ~~| Button Methods |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local methods = {		
	['OnAcquire'] = function(self)			
		self:ApplySettings()
		self:AddStyleSheet(styleSheet)
		self:Enable()
		-- self:AddStyleSheet(wireFrameSheet)			
		self:Show()		
	end,
	['OnRelease'] = function(self)		
		
	end,	
	['ApplySettings'] = function(self)		
		local settings 	= self.settings
		local frame 		= self.frame	
		
		self:SetWidth(settings.width)
		self:SetHeight(settings.height)								
	end,	
	["SetText"] = function(self, text)
		self.text:SetText(text)
	end,
	["Disable"] = function(self)
		self.settings.disabled = true
		self.frame:Disable()		
	end,
	["Enable"] = function(self)
		self.settings.disabled = false
		self.frame:Enable()		
	end,
	["RegisterForClicks"] = function(self,...)		
		self.frame:RegisterForClicks(...)		
	end,
	["SetFont"] = function(self,...)		
		self.mText:SetFont(...)
	end,				
}
-- ~~| Button Constructor |~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local function Constructor(name)	
	local self 		= DiesalGUI:CreateObjectBase(TYPE)
	local frame		= CreateFrame('Button',name,UIParent)		
	self.frame		= frame	
	self.defaults = {		
		height 			= 32,
		width 			= 32,
	}	
	-- ~~ Events ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	-- OnAcquire, OnRelease, OnHeightSet, OnWidthSet	
	-- OnClick, OnEnter, OnLeave, OnDisable, OnEnable 	
	-- ~~ Construct ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	
	self.mText = self:CreateRegion("FontString", 'text', frame)		
	self.mText:SetPoint("TOPLEFT", 4, -2)
	self.mText:SetPoint("BOTTOMRIGHT", -4, 0)
	self.mText:SetJustifyV("MIDDLE")	
	frame:SetFontString(self.mText)	
	frame:SetScript("OnClick", function(this,button,...)
		DiesalGUI:OnMouse(this,button)
		
		self:FireEvent("OnClick",button,...)	
	end)
	frame:SetScript("OnEnter", function(this)
		self:FireEvent("OnEnter")	
	end)
	frame:SetScript("OnLeave", function(this)
		self:FireEvent("OnLeave")	
	end)
	frame:SetScript("OnDisable", function(this)
		self:FireEvent("OnDisable")	
	end)
	frame:SetScript("OnEnable", function(this)
		self:FireEvent("OnEnable")	
	end)	
	-- ~~ Methods ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	for method, func in pairs(methods) do	self[method] = func	end
	-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	return self
end
	
DiesalGUI:RegisterObjectConstructor(TYPE,Constructor,VERSION)