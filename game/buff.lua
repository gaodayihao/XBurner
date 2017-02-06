local _, XB                     = ...
XB.Game.Buff                    = {}
XB.Game.Debuff                  = {}
local GetSpecialization         = GetSpecialization
local GetSpecializationInfo     = GetSpecializationInfo
local GetTime                   = GetTime
local UnitClass                 = UnitClass
local activeSpec			    = 0

local function BuildBuffAndDebuff()
    local classIndex = select(3,UnitClass('player'))
    local spec = activeSpec
    local buffs = XB.Abilities:GetBuffsTable(classIndex,spec)

    wipe(XB.Game.Buff)
    for name, spellID in pairs(buffs) do
        XB.Game.Buff[name] = function(target)
            local target = target and target or 'player'
            local buff = {
                up = false,
                down = true,
                duration = 0,
                remains = 0,
            }
            local name, duration, expires, caster, timeMod = XB.Game:UnitBuff(target,spellID)
            if not not name then
                buff.remains = math.max((expires - GetTime()) / timeMod,0)
                buff.up = buff.remains > 0
                buff.down = not buff.up
                buff.duration = duration
            end
            return buff
        end
    end

    local debuffs = XB.Abilities:GetDebuffsTable(classIndex,spec)
    wipe(XB.Game.Debuff)
    for name, spellID in pairs(debuffs) do
        XB.Game.Debuff[name] = function(target)
            local target = target and target or 'target'
            local debuff = {
                up = false,
                down = true,
                duration = 0,
                remains = 0,
            }
            local name, duration, expires, caster, timeMod = XB.Game:UnitDebuff(target,spellID)
            if not not name then
                debuff.remains = math.max((expires - GetTime()) / timeMod,0)
                debuff.up = debuff.remains > 0
                debuff.down = not debuff.up
                debuff.duration = duration
            end
            return debuff
        end
    end
end

XB.Listener:Add('XB_Buff','PLAYER_LOGIN', function ()
	activeSpec = GetSpecializationInfo(GetSpecialization())
	BuildBuffAndDebuff()
end)

XB.Listener:Add('XB_Buff','PLAYER_SPECIALIZATION_CHANGED', function (unitID)
    if unitID ~= 'player' or activeSpec == GetSpecializationInfo(GetSpecialization()) then return end
	activeSpec = GetSpecializationInfo(GetSpecialization())
	BuildBuffAndDebuff()
end)