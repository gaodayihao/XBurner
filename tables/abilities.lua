local _, XB = ...

XB.Abilities = {
     -- Priest
    [5] = {
        -- Discipline
        [256] = {
            abilities                       = {
                angelicFeather              = 121536,
                divineStar                  = 110744,
                halo                        = 120517,
                leapOfFaith                 = 73325,
                lightsWrath                 = 207946,
                massResurrection            = 212036,
                painSuppression             = 33206,
                penance                     = 47540,
                plea                        = 200829,
                powerWordBarrier            = 62618,
                powerWordRadiance           = 194509,
                powerWordShield             = 17,
                powerWordSolace             = 129250,
                purgeTheWicked              = 204197,
                purify                      = 527,
                rapture                     = 47536,
                schism                      = 214621,
            },
            artifacts                       = {

            },
            buffs                           = {
                atonement                   = 194384,
                powerWordShield             = 17,
            },
            debuffs                         = {
                purgeTheWicked              = 204213,
                shadowWordPain              = 589,
                smite                       = 585,
            },
            talents                         = {
                
            },
        },
        -- Holy
        [257] = {
            abilities                       = {

            },
            artifacts                       = {

            },
            buffs                           = {

            },
            debuffs                         = {

            },
            glyphs                          = {

            },
            talents                         = {

            },
        },
        -- Shadow
        [258] = {
            abilities                       = {
                dispersion                  = 47585,
                mindBlast                   = 8092,
                mindBomb                    = 205369,
                mindFlay                    = 15407,
                mindSpike                   = 73510,
                mindVision                  = 2096,
                powerInfusion               = 10060,
                powerWordShield             = 17,
                shadowCrash                 = 205385,
                shadowform                  = 232698,
                shadowWordDeath             = 32379,
                shadowWordPain              = 589,
                shadowWordVoid              = 205351,
                silence                     = 15487,
                surrenderToMadness          = 193223,
                vampiricEmbrace             = 15286,
                vampiricTouch               = 34914,
                voidBolt                    = 205448,
                voidEruption                = 228260,
                voidTorrent                 = 205065,
            },
            artifacts                       = {
                sphereOfInsanity            = 194179,
                unleashTheShadows           = 194093,
                voidTorrent                 = 205065,
            },
            buffs                           = {
                dispersion                  = 47585,
                powerInfusion               = 10060,
                powerWordShield             = 17,
                shadowform                  = 232698,
                shadowyInsight              = 124430,
                shadowyInsight              = 124430,
                surrenderedSoul             = 212570,
                surrenderToMadness          = 193223,
                twistOfFate                 = 123254,
                voidForm                    = 194249,
                voidTorrent                 = 205065,
            },
            debuffs                         = {
                shadowWordPain              = 589,
                vampiricTouch               = 34914,
            },
            talents                         = {
                auspiciousSpirits           = 155271,
                bodyAndSoul                 = 64129,
                fortressOfTheMind           = 193195,
                legacyOfTheVoid             = 193225,
                misery                      = 238558,
                powerInfusion               = 10060,
                reaperOfSouls               = 199853,
                sanlayn                     = 199855,
                shadowCrash                 = 205385,
                shadowWordVoid              = 205351,
                shadowyInsight              = 162452,
                surrenderToMadness          = 193223,
                twistOfFate                 = 109142,
            },
        },
        -- All
        Shared = {
            abilities                       = {
                dispelMagic                 = 528,
                fade                        = 586,
                levitate                    = 1706,
                massDispel                  = 32375,
                mindbender                  = 200174,
                purifyDisease               = 213634,
                resurrection                = 2006,
                shackleUndead               = 9484,
                shadowfiend                 = 34433,
                shadowMend                  = 186263,
                smite                       = 585,
            },
            artifacts                       = {

            },
            buffs                           = {
                bodyAndSoul                 = 224098,
            },
            debuffs                         = {

            },
            talents                         = {
                mindbender                  = 200174,
            },
        },
    },
    -- All
    Shared = {
        abilities                       = {

        },
        artifacts                       = {

        },
        buffs                           = {
            
        },
        debuffs                         = {

        },
        talents                         = {
            
        },
    }
}

local function GetAbilityTable(ablityType,classIndex,spec)
    local table = XB.Core:MergeTables({},XB.Abilities.Shared[ablityType])
    if XB.Abilities[classIndex] then
        table = XB.Core:MergeTables(table,XB.Abilities[classIndex].Shared[ablityType])

        if XB.Abilities[classIndex][spec] then
            table = XB.Core:MergeTables(table,XB.Abilities[classIndex][spec][ablityType])
        end
    end
    return table
end

function XB.Abilities:GetArtifactsTable(classIndex,spec)
    return GetAbilityTable('artifacts', classIndex, spec)
end

function XB.Abilities:GetBuffsTable(classIndex,spec)
    return GetAbilityTable('buffs', classIndex, spec)
end

function XB.Abilities:GetDebuffsTable(classIndex,spec)
    return GetAbilityTable('debuffs', classIndex, spec)
end

function XB.Abilities:GetTalentsTable(classIndex,spec)
    return GetAbilityTable('talents', classIndex, spec)
end