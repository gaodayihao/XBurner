local _, XB                     = ...
XB.Game.Spell                 = {}
local GetSpecialization         = GetSpecialization
local GetSpecializationInfo     = GetSpecializationInfo
local UnitClass                 = UnitClass

local function BuildSpells()
    local classIndex = select(3,UnitClass('player'))
    local spec = GetSpecializationInfo(GetSpecialization())

    wipe(XB.Game.Spell)
    XB.Game.Spell.Cast       = {}
    XB.Game.Spell.Cooldown   = {}
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

            XB.Game.Spell.Cast[k] = function(unit, ...)
                local spellCast = v
                local spellName = GetSpellInfo(v)
                --if spellName == nil then print(v) end
                if unit == nil and flag ~= 'best' then
                    if IsHelpfulSpell(spellName) then
                        unit = 'player'
                    else
                        unit = 'target'
                    end
                end
                if IsHelpfulSpell(spellName) and not UnitIsFriend('player', unit) then
                    unit = 'player'
                end
                -- /run print(XB.Game.Spell.Cast.MindBlast())
                if not select(2,IsUsableSpell(v)) and XB.Game:GetSpellCD(v) == 0 then
                    local minUnits,effectRng = nil,nil
                    local debug = false
                    local best = false
                    local dead = false
                    local aoe = false
                    local channel = false
                    local know = false

                    for i = 1, select('#', ...) do
                        local arg = select(i, ...)
                        if arg == 'debug' then debug = true end
                        if arg == 'best' then best = true end
                        if arg == 'dead' then dead = true end
                        if arg == 'aoe' then aoe = true end
                        if arg == 'channel' then channel = true end
                        if arg == 'know' then know = true end
                        if type(arg) == 'number' then
                            if minUnits == nil then
                                minUnits = arg
                            else
                                effectRng = arg
                            end
                        end
                    end

                    minUnits = minUnits or 1
                    effectRng = effectRng or 8

                    if best then
                        local minRange = select(5,GetSpellInfo(v))
                        local maxRange = select(6,GetSpellInfo(v))
                        return XB.Runer:CastGroundAtBestLocation(spellCast,effectRng,minUnits,maxRange,minRange)
                    else
                        return XB.Runer:CastSpell(unit,spellCast,aoe,false,false,know,dead,false,false,debug,channel)
                    end
                end
                return false
            end
        end
    end
end

XB.Core:WhenInGame(BuildSpells,0)
XB.CR:WhenChangingCR(BuildSpells,0)