local _, XB                     = ...

-- func cache
local GetTime                   = GetTime

-- local var
local buff                      = XB.Game.Buff
local talent                    = XB.Game.Talent
local game                      = XB.Game
local movingStart               = 0
local cast                      = XB.Game.Spell.Cast
local cr                        = XB.CR

local GUI = {
  {type = 'header', text = 'Abiliteis', align = 'center'},
  {type = 'checkspin', text = 'Body And Soul', key = 'A_BaS', default_check = true, default_spin = 1.5,max = 5,min = 0,step = 0.5},

  {type = 'ruler'},{type = 'spacer'},
  {type = 'header', text = 'CoolDown', align = 'center'},
  {type = 'text', text = 'comming soon'},
}

local CommonActionList = function()
    if cr:UI('A_BaS_check')
        and not buff.BodyAndSoul().up
        and game:IsMoving('player') 
        and not buff.SurrenderToMadness().up 
        and talent.BodyAndSoul.enable 
    then
        if movingStart == 0 then
            movingStart = GetTime()
        elseif GetTime() > movingStart + cr:UI('A_BaS_spin') then
            if cast.PowerWordShield('player') then return true end
        end
    else
        movingStart = 0
    end
end

local InCombat = function()
    if CommonActionList() then return true end
end

local OutCombat = function()
    if CommonActionList() then return true end
end

local OnLoad = function()
end

local OnUnload = function()
end

XB.CR:Add(258, '[XB] Priest - Shadow', InCombat, OutCombat, OnLoad, GUI, OnUnload)
