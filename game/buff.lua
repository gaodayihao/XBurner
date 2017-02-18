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
        XB.Game.Buff[name] = function(target,any)
            if any == nil then any = true else any = false end
            local target = target and target or 'player'
            local buff      = {
                up          = false,
                down        = true,
                duration    = 0,
                remains     = 0,
                stack       = 0,
                refresh     = true,
            }
            local name,duration,expires,caster,timeMod,stack = nil,nil,nil,nil,nil,nil
            if any then
                name,duration,expires,caster,timeMod,stack = XB.Game:GetUnitBuffAny(target,spellID)
            else
                name,duration,expires,caster,timeMod,stack = XB.Game:GetUnitBuff(target,spellID)
            end
            if name ~= nil then
                buff.remains    = math.max((expires - GetTime()) / timeMod,0)
                buff.up         = true
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
    for Name, SpellID in pairs(debuffs) do
        XB.Game.Debuff[Name] = function(target, any)
            local any = any or false
            local target = target or 'target'
            local debuff    = {
                up          = false,
                down        = true,
                duration    = 0,
                remains     = 0,
                stack       = 0,
                refresh     = true,
                count       = function() return XB.Area:Debuff(SpellID,any) end
            }
            local name, duration, expires, caster, timeMod, stack = nil, nil, nil, nil ,nil ,nil
            if any then
                name, duration, expires, caster, timeMod, stack =  XB.Game:GetUnitDebuffAny(target,SpellID)
            else
                name, duration, expires, caster, timeMod, stack = XB.Game:GetUnitDebuff(target,SpellID)
            end
            if name ~= nil then
                debuff.remains  = math.max((expires - GetTime()) / timeMod,0)
                debuff.up       = true
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