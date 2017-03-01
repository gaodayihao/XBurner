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
local L                         = (function(key) return XB.Locale:TA('Retribution',key) end)
local talent                    = XB.Game.Talent

local GUI = {
  {type = 'header', text = XB.Locale:TA('Any','Abiliteis'), align = 'center'},{type = 'spacer'},
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

XB.CR:Add(70, L('Name'), InCombat, OutCombat, OnLoad, OnUnload, GUI, Pause)