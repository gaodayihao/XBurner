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
local debuff                    = XB.Game.Debuff
local eq_t19_2pc                = false
local eq_t19_4pc                = false
local game                      = XB.Game
local L                         = (function(key) return XB.Locale:TA('Affliction',key) end)
local talent                    = XB.Game.Talent
local ttd                       = (function(Unit) return XB.CombatTracker:TimeToDie(Unit) end)
local UI                        = (function(key) return XB.CR:UI(key) end)
local TargetRange               = 40

local GUI = {
  {type = 'header', text = XB.Locale:TA('Any','Abiliteis'), align = 'center'},{type = 'spacer'},

  {type = 'spacer'},{type = 'ruler'},
  {type = 'header', text = XB.Locale:TA('Any','CD'), align = 'center'},{type = 'spacer'},
}

local CommonActionList = function()
end

local InCombat = function()
end

local OutCombat = function()
end

local OnLoad = function()
end

local OnUnload = function()
end

local Pause = function()
    if game:IsCasting() and not game:IsCastingSpell(game.Spell.SpellInfo.DrainSoul) then return true end
    return false
end

XB.CR:Add(258, L('Name'), InCombat, OutCombat, OnLoad, OnUnload, GUI, Pause, TargetRange)
