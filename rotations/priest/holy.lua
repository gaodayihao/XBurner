local _, XB                     = ...

-- func cache
local GetTime                   = GetTime
local UnitExists                = ObjectExists or UnitExists
local UnitIsFriend              = UnitIsFriend

-- local var
local artifact                  = XB.Game.Artifact
local buff                      = XB.Game.Buff
local cast                      = XB.Game.Spell.Cast
local cd                        = XB.Game.Spell.Cooldown
local cr                        = XB.CR
local debuff                    = XB.Game.Debuff
local game                      = XB.Game
local insanityDrainStacks       = 0
local L                         = (function(key) return XB.Locale:TA('Holy_Priest',key) end)
local movingStart               = 0
local s2mbeltcheckVar           = 0
local talent                    = XB.Game.Talent

local GUI = {
  {type = 'header', text = XB.Locale:TA('Any','Abiliteis'), align = 'center'},{type = 'spacer'},
  {type = 'checkspin', text = L('BaS'), key = 'A_BaS', default_check = true, default_spin = 1.5,max = 5,min = 0,step = 0.5,tooltip = L('BaS_tip')},
}

local CommonActionList = function()
end

local InCombat = function()
    if CommonActionList() then return true end
    local useCD                         = XB.Game:UseCooldown()

end

local OutCombat = function()
end

local OnLoad = function()
end

local OnUnload = function()
end

local Pause = function()

end

XB.CR:Add(257, L('Name'), InCombat, OutCombat, OnLoad, OnUnload, GUI, Pause)