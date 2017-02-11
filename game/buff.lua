local _, XB                     = ...
XB.Game.Buff                    = {}
XB.Game.Debuff                  = {}
local GetSpecialization         = GetSpecialization
local GetSpecializationInfo     = GetSpecializationInfo
local GetTime                   = GetTime
local UnitClass                 = UnitClass

local function BuildBuffAndDebuff()
    local classIndex = select(3,UnitClass('player'))
    local spec = GetSpecializationInfo(GetSpecialization())
    local buffs = XB.Abilities:GetBuffsTable(classIndex,spec)

    wipe(XB.Game.Buff)
    for name, spellID in pairs(buffs) do
        XB.Game.Buff[name] = function(target)
            local target = target and target or 'player'
            local buff      = {
                up          = false,
                down        = true,
                duration    = 0,
                remains     = 0,
                stack       = 0,
                refresh     = true,
            }
            local name, duration, expires, caster, timeMod, stack = XB.Game:GetUnitBuff(target,spellID)
            if not not name then
                buff.remains    = math.max((expires - GetTime()) / timeMod,0)
                buff.up         = buff.remains > 0
                buff.down       = not buff.up
                buff.duration   = duration
                buff.stack      = stack
                buff.refresh    = buff.remains <= buff.duration * 0.3
            end
            return buff
        end
    end

    local debuffs = XB.Abilities:GetDebuffsTable(classIndex,spec)
    wipe(XB.Game.Debuff)
    for name, spellID in pairs(debuffs) do
        XB.Game.Debuff[name] = function(target)
            local target = target and target or 'target'
            local debuff    = {
                up          = false,
                down        = true,
                duration    = 0,
                remains     = 0,
                stack       = 0,
                refresh     = true,
            }
            local name, duration, expires, caster, timeMod, stack = XB.Game:GetUnitDebuff(target,spellID)
            if not not name then
                debuff.remains  = math.max((expires - GetTime()) / timeMod,0)
                debuff.up       = debuff.remains > 0
                debuff.down     = not debuff.up
                debuff.duration = duration
                debuff.stack    = stack
                debuff.refresh  = debuff.remains <= debuff.duration * 0.3
            end
            return debuff
        end
    end
end


XB.Core:WhenInGame(BuildBuffAndDebuff)
XB.CR:WhenChangingCR(BuildBuffAndDebuff)