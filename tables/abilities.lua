local _, XB = ...

XB.Abilities = {
     -- Priest
    [5] = {
        -- Discipline
        [256] = {
            abilities                       = {
                AngelicFeather              = 121536,
                DivineStar                  = 110744,
                Halo                        = 120517,
                LeapOfFaith                 = 73325,
                LightsWrath                 = 207946,
                MassResurrection            = 212036,
                PainSuppression             = 33206,
                Penance                     = 47540,
                Plea                        = 200829,
                PowerWordBarrier            = 62618,
                PowerWordRadiance           = 194509,
                PowerWordShield             = 17,
                PowerWordSolace             = 129250,
                PurgeTheWicked              = 204197,
                Purify                      = 527,
                Papture                     = 47536,
                Schism                      = 214621,
            },
            artifacts                       = {

            },
            buffs                           = {
                Atonement                   = 194384,
                PowerWordShield             = 17,
            },
            debuffs                         = {
                PurgeTheWicked              = 204213,
                ShadowWordPain              = 589,
                Smite                       = 585,
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
                Dispersion                  = 47585,
                MindBlast                   = 8092,
                MindBomb                    = 205369,
                MindFlay                    = 15407,
                MindSpike                   = 73510,
                MindVision                  = 2096,
                PowerInfusion               = 10060,
                PowerWordShield             = 17,
                ShadowCrash                 = 205385,
                Shadowform                  = 232698,
                ShadowWordDeath             = 32379,
                ShadowWordPain              = 589,
                ShadowWordVoid              = 205351,
                Silence                     = 15487,
                SurrenderToMadness          = 193223,
                VampiricEmbrace             = 15286,
                VampiricTouch               = 34914,
                VoidBolt                    = 205448,
                VoidEruption                = 228260,
                VoidTorrent                 = 205065,
            },
            artifacts                       = {
                SphereOfInsanity            = 194179,
                UnleashTheShadows           = 194093,
                VoidTorrent                 = 205065,
            },
            buffs                           = {
                Dispersion                  = 47585,
                PowerInfusion               = 10060,
                PowerWordShield             = 17,
                Shadowform                  = 232698,
                ShadowyInsight              = 124430,
                ShadowyInsight              = 124430,
                SurrenderedSoul             = 212570,
                SurrenderToMadness          = 193223,
                TwistOfFate                 = 123254,
                VoidForm                    = 194249,
                VoidTorrent                 = 205065,
            },
            debuffs                         = {
                ShadowWordPain              = 589,
                VampiricTouch               = 34914,
            },
            talents                         = {
                AuspiciousSpirits           = 155271,
                BodyAndSoul                 = 64129,
                FortressOfTheMind           = 193195,
                LegacyOfTheVoid             = 193225,
                Misery                      = 238558,
                PowerInfusion               = 10060,
                ReaperOfSouls               = 199853,
                Sanlayn                     = 199855,
                ShadowCrash                 = 205385,
                ShadowWordVoid              = 205351,
                ShadowyInsight              = 162452,
                SurrenderToMadness          = 193223,
                TwistOfFate                 = 109142,
            },
        },
        -- All
        Shared = {
            abilities                       = {
                DispelMagic                 = 528,
                Fade                        = 586,
                Levitate                    = 1706,
                MassDispel                  = 32375,
                Mindbender                  = 200174,
                PurifyDisease               = 213634,
                Resurrection                = 2006,
                ShackleUndead               = 9484,
                Shadowfiend                 = 34433,
                ShadowMend                  = 186263,
                Smite                       = 585,
            },
            artifacts                       = {

            },
            buffs                           = {
                BodyAndSoul                 = 224098,
            },
            debuffs                         = {

            },
            talents                         = {
                Mindbender                  = 200174,
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
    },
    PowerList     = {
        Mana            = SPELL_POWER_MANA,
        Rage            = SPELL_POWER_RAGE,
        Focus           = SPELL_POWER_FOCUS,
        Energy          = SPELL_POWER_ENERGY,
        ComboPoints     = SPELL_POWER_COMBO_POINTS,
        Runes           = SPELL_POWER_RUNES,
        RunicPower      = SPELL_POWER_RUNIC_POWER,
        SoulShards      = SPELL_POWER_SOUL_SHARDS,
        LunarPower      = SPELL_POWER_LUNAR_POWER,
        HolyPower       = SPELL_POWER_HOLY_POWER,
        AltPower        = SPELL_POWER_ALTERNATE_POWER,
        Maelstrom       = SPELL_POWER_MAELSTROM,
        Chi             = SPELL_POWER_CHI,
        Insanity        = SPELL_POWER_INSANITY,
        ArcaneCharges   = SPELL_POWER_ARCANE_CHARGES,
        Fury            = SPELL_POWER_FURY,
        Pain            = SPELL_POWER_PAIN,
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