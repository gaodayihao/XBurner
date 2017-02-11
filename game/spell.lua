local _, XB                     = ...
XB.Player.Spell                 = {}
local GetSpecialization         = GetSpecialization
local GetSpecializationInfo     = GetSpecializationInfo
local UnitClass                 = UnitClass

local function BuildSpells()
    local classIndex = select(3,UnitClass('player'))
    local spec = GetSpecializationInfo(GetSpecialization())

    wipe(XB.Player.Spell)
    XB.Player.Spell.Cast       = {}
    XB.Player.Spell.Cooldown   = {}
    XB.Player.Spell.SpellInfo  = XB.Abilities:GetSpellsTable(classIndex,spec)

    for k,v in pairs(XB.Player.Spell.SpellInfo) do
        if type(v) == 'number' then
            XB.Player.Spell.Cooldown[k] = function()
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

            XB.Player.Spell.Cast[k] = function(unit,flag)
                
            end
        end
    end
end

XB.Core:WhenInGame(BuildSpells,0)
XB.CR:WhenChangingCR(BuildSpells,0)