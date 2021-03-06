local _, XB                     = ...
XB.Game.Spell                   = {}
XB.Game.Spell.Cast              = {}
XB.Game.Spell.Cooldown          = {}
XB.Game.Spell.SpellInfo         = {}

local GetSpecialization         = GetSpecialization
local GetSpecializationInfo     = GetSpecializationInfo
local UnitClass                 = UnitClass

local function BuildSpells()
    local classIndex = select(3,UnitClass('player'))
    local spec = GetSpecializationInfo(GetSpecialization())

    wipe(XB.Game.Spell.Cast)
    wipe(XB.Game.Spell.Cooldown)
    wipe(XB.Game.Spell.SpellInfo)

    XB.Game.Spell.SpellInfo  = XB.Abilities:GetSpellsTable(classIndex,spec)

    for k,v in pairs(XB.Game.Spell.SpellInfo) do
        if type(v) == 'number' then
            XB.Game.Spell.Cooldown[k] = function()
                local result    = {
                    remains     = 0,
                    charges     = 0,
                    chargesFrac = 0,
                    chargesMax  = 0,
                    recharges   = 0,
                }

                result.remains = XB.Game:GetSpellCD(v)
                result.charges = XB.Game:GetCharges(v)
                result.chargesFrac = XB.Game:GetChargesFrac(v)
                result.chargesMax = XB.Game:GetChargesFrac(v,true)
                result.recharges = XB.Game:GetRecharge(v)

                return result
            end

            function XB.Game.Spell.Cast.Racial()
                if XB.Game:GetSpellCD(XB.Game:GetRacial()) == 0 then
                    local race = XB.Game:GetRace()
                    if race == "Pandaren" or race == "Goblin" then
                        return XB.Runer:CastSpell('target',XB.Game:GetRacial(),true,true)
                    else
                        return XB.Runer:CastSpell('player',XB.Game:GetRacial(),true,true)
                    end
                end
            end

            XB.Game.Spell.Cast[k] = function(unit, ...)
                local spellCast = v
                local spellName = GetSpellInfo(v)
                --if spellName == nil then print(v) end
                if unit == nil then
                    if IsHelpfulSpell(spellName) then
                        unit = 'player'
                    else
                        unit = 'target'
                    end
                end
                if IsHelpfulSpell(spellName) and not UnitIsFriend('player', unit) then
                    unit = 'player'
                end

                local minUnits,effectRng = nil,nil
                local debug = false
                local best = false
                local dead = false
                local aoe = false
                local channel = false
                local known = false
                local useable = false
                local castGroundFlag = 'Enemy'
                for i = 1, select('#', ...) do
                    local arg = select(i, ...)
                    if arg == 'debug' then debug = true
                    elseif arg == 'best' then best = true
                    elseif arg == 'dead' then dead = true
                    elseif arg == 'aoe' then aoe = true
                    elseif arg == 'channel' then channel = true
                    elseif arg == 'known' then known = true
                    elseif arg == 'useable' then useable = true
                    elseif arg == 'heal' then castGroundFlag = 'Friendly'
                    elseif type(arg) == 'number' then
                        if minUnits == nil then
                            minUnits = arg
                        else
                            effectRng = arg
                        end
                    end
                end
                minUnits = minUnits or 1
                effectRng = effectRng or 8

                -- /run print(XB.Game.Spell.Cast.MindBlast())
                if (not select(2,IsUsableSpell(v)) or useable) and XB.Game:GetSpellCD(v) == 0 then
                    if best then
                        local minRange = select(5,GetSpellInfo(v))
                        local maxRange = select(6,GetSpellInfo(v))
                        return XB.Runer:CastGroundAtBestLocation(spellCast,effectRng,minUnits,maxRange,minRange,castGroundFlag)
                    else
                        return XB.Runer:CastSpell(unit,spellCast,aoe,false,false,known,dead,false,useable,debug,channel)
                    end
                end
                return false
            end
        end
    end
end

XB.Core:WhenInGame(BuildSpells,0)
XB.CR:WhenChangingCR(BuildSpells,0)