local _, XB                     = ...

-- func cache
local GetTime                   = GetTime
local UnitExists                = ObjectExists or UnitExists
local UnitIsFriend              = UnitIsFriend

-- local var
local buff                      = XB.Game.Buff
local talent                    = XB.Game.Talent
local game                      = XB.Game
local movingStart               = 0
local cast                      = XB.Game.Spell.Cast
local cr                        = XB.CR
local eq_t19_4pc                = false
local eq_t19_2pc                = false
local ttd                       = (function(Unit) return XB.CombatTracker:TimeToDie(Unit) end)
local debuff                    = XB.Game.Debuff
local cd                        = XB.Game.Spell.Cooldown
local artifact                  = XB.Game.Artifact
local voidformStart             = 0
local voidformTimeStacks        = 0
local insanityDrainStacks       = 0
local s2mbeltcheckVar           = 0
local L                         = (function(key) return XB.Locale:TA('Shadow',key) end)

local GUI = {
  {type = 'header', text = L('Abiliteis'), align = 'center'},{type = 'spacer'},
  {type = 'checkspin', text = L('BaS'), key = 'A_BaS', default_check = true, default_spin = 1.5,max = 5,min = 0,step = 0.5},
  {type = 'spinner', text = L('SwpT'), key = 'A_SWP_T', default = 6,max = 10,min = 1,step = 1},
  {type = 'spinner', text = L('VtT'), key = 'A_VT_T', default = 3,max = 10,min = 1,step = 1},
  {type = 'checkspin', text = L('ShadowCrash'), key = 'A_SC', default_check = true, default_spin = 1,max = 5,min = 1,step = 1},
  {type = 'spinner', text = L('S2MCheck'), key = 'A_S2MCheck', default = 90,max = 130,min = 50,step = 5},
  {type = 'checkspin', text = L('ActiveEnemies'), key = 'A_AE', default_check = false, default_spin = 5,max = 10,min = 1,step = 1},

  {type = 'spacer'},{type = 'ruler'},
  {type = 'header', text = L('CD'), align = 'center'},{type = 'spacer'},
  {type = 'checkspin', text = L('PowerInfusion'), key = 'C_PI', default_check = true, default_spin = 10,max = 30,min = 1,step = 1},
  {type = 'checkbox', text = L('Shadowfiend'), key = 'C_SF', default = true},
  {type = 'checkbox', text = L('Mindbender'), key = 'C_Mb', default = true},
  {type = 'spinner', text = L('VoidTorrent'), key = 'C_VT', default = 0,max = 60,min = 0,step = 5},

  {type = 'spacer'},{type = 'ruler'},
  {type = 'header', text = L('CD_S2M'), align = 'center'},{type = 'spacer'},
  {type = 'checkspin', text = L('PowerInfusion'), key = 'C_PI_S2M', default_check = true, default_spin = 55,max = 100,min = 1,step = 1},
  {type = 'checkbox', text = L('Shadowfiend'), key = 'C_SF_S2M', default = true},
  {type = 'checkbox', text = L('Mindbender'), key = 'C_Mb_S2M', default = true},
  {type = 'spinner', text = L('VoidTorrent'), key = 'C_VT_S2M', default = 20,max = 60,min = 0,step = 5},
}

local CommonActionList = function()
    if cr:UI('A_BaS_check')
        and XB.Game:IsMoving('player')
        and XB.Game.Talent.BodyAndSoul.enabled
        and not XB.Game.Buff.SurrenderToMadness().up
        and not XB.Game.Buff.BodyAndSoul().up
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
    if not XB.Checker:IsValidEnemy('target') then return false end

-- function var
    local gcd                           = game:GCD()
    local swpCount                      = debuff.ShadowWordPain().count()
    local vtCount                       = debuff.VampiricTouch().count()
    local forceSingle                   = not XB.Game:UseAoE()
    local enemies                       = XB.Area:Enemies()
    local insanity                      = XB.Game.Power.Insanity().amount
    local activeEnemies                 = 1 if not cr:UI('A_AE_check') then activeEnemies = #XB.Area:EnemiesT(8) end
    local reaperOfSoulsVar              = 0 if talent.ReaperOfSouls.enabled then reaperOfSoulsVar = 1 end
    local currentInsanityDrain          = 6 + (insanityDrainStacks+0.2) * (2.0/3.0)
    local useCD                         = XB.Game:UseCooldown()
    local s2mcheck                      = cr:UI('A_S2MCheck')

    local ActionListAnyEnemyShadowWordDeath = function()
        local targetHP = XB.Game:GetHP('target')
        if (targetHP > 35 and talent.ReaperOfSouls.enabled or targetHP > 20 and not talent.ReaperOfSouls.enabled) and buff.Voidform().up and cd.ShadowWordDeath().charges > 0 then
            local s2mVar = 1 if buff.SurrenderToMadness().up then s2mVar = 2 end
            if cd.ShadowWordDeath().charges == 2 or
                (currentInsanityDrain*gcd>insanity
                    and (insanity - (currentInsanityDrain*gcd) + (15+15*reaperOfSoulsVar)*s2mVar)<100
                    and (not buff.PowerWordShield().up or not buff.SurrenderToMadness().up))
            then
                for i = 1,#enemies do
                    local enemy = enemies[i].key
                    local enemyHP = XB.Game:GetHP(enemy)
                    if enemyHP < 20 or enemyHP < 35 and talent.ReaperOfSouls.enabled then
                        if cast.ShadowWordDeath(enemy,'aoe','useable') then return true end
                    end
                end
            end
        end
        if talent.TwistOfFate.enabled and buff.TwistOfFate().down then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                local enemyHP = XB.Game:GetHP(enemy)
                if enemyHP < 35 then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
        return false
    end

-- Action List Main
    local ActionListMain = function()
    -- surrender_to_madness,if=talent.surrender_to_madness.enabled&target.time_to_die<=variable.s2mcheck
        -- Never automatic use S2M
    -- mindbender,if=talent.mindbender.enabled&((talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck+60)|!talent.surrender_to_madness.enabled)
        if talent.Mindbender.enabled
            and useCD
            and cr:UI('C_Mb')
            and ((talent.SurrenderToMadness.enabled and ttd('target') > s2mcheck + 60) or not talent.SurrenderToMadness.enabled)
        then
            if cast.Mindbender() then return true end
        end
    -- shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd.max,moving=1,cycle_targets=1
        if talent.Misery.enabled and game:IsMoving('player') and debuff.ShadowWordPain().remains < gcd then
            if cast.ShadowWordPain('target','aoe') then return true end
        end
        if talent.Misery.enabled and game:IsMoving('player') and not forceSingle then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if (swpCount < cr:UI('A_SWP_T') or debuff.ShadowWordPain(enemy).up)
                    and debuff.ShadowWordPain(enemy).remains < gcd
                then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max),cycle_targets=1
        if talent.Misery.enabled and (debuff.ShadowWordPain().remains < 3*gcd or debuff.VampiricTouch().remains < 3*gcd) then
            if cast.VampiricTouch('target','aoe') then return true end
        end
        if talent.Misery.enabled and not forceSingle then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if (vtCount < cr:UI('A_VT_T') or (debuff.ShadowWordPain(enemy).up and debuff.VampiricTouch(enemy).up))
                    and (debuff.ShadowWordPain(enemy).remains < 3*gcd or debuff.VampiricTouch(enemy).remains < 3*gcd)
                then
                    if cast.VampiricTouch(enemy,'aoe') then return true end
                end
            end
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if (swpCount < cr:UI('A_SWP_T') or debuff.ShadowWordPain(enemy).up)
                    and debuff.ShadowWordPain(enemy).remains < gcd
                then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- shadow_word_pain,if=!talent.misery.enabled&dot.shadow_word_pain.remains<(3+(4%3))*gcd
        if not talent.Misery.enabled and debuff.ShadowWordPain().remains < (3+(4%3))*gcd then
            if cast.ShadowWordPain('target','aoe') then return true end
        end
    -- vampiric_touch,if=!talent.misery.enabled&dot.vampiric_touch.remains<(4+(4%3))*gcd
        if not talent.Misery.enabled and debuff.VampiricTouch().remains < (4+(4%3))*gcd then
            if cast.VampiricTouch('target','aoe') then return true end
        end
    -- void_eruption,if=insanity>=70|(talent.auspicious_spirits.enabled&insanity>=(65-shadowy_apparitions_in_flight*3))|set_bonus.tier19_4pc
        if XB.Interface:GetToggle('voidEruption') and insanity >= 70 or (talent.AuspiciousSpirits.enabled and insanity >=65) or eq_t19_4pc then
            if cast.VoidEruption('player') then return true end
        end
    -- shadow_crash,if=talent.shadow_crash.enabled
        if talent.ShadowCrash.enabled and cr:UI('A_SC_check') then
            if cast.ShadowCrash('target','best') then return true end
        end
    -- mindbender,if=talent.mindbender.enabled&set_bonus.tier18_2pc
        -- T18????
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&talent.legacy_of_the_void.enabled&insanity>=70,cycle_targets=1
        if not talent.Misery.enabled and talent.LegacyOfTheVoid.enabled and insanity >= 70 and not forceSingle then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if swpCount < cr:UI('A_SWP_T') and debuff.ShadowWordPain(enemy).down then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- vampiric_touch,if=!talent.misery.enabled&!ticking&talent.legacy_of_the_void.enabled&insanity>=70,cycle_targets=1
        if not talent.Misery.enabled and talent.LegacyOfTheVoid.enabled and insanity >= 70 and not forceSingle then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if vtCount < cr:UI('A_VT_T') and debuff.VampiricTouch(enemy).down then
                    if cast.VampiricTouch(enemy,'aoe') then return true end
                end
            end
        end

        if ActionListAnyEnemyShadowWordDeath() then return true end

    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2&insanity<=(90-20*talent.reaper_of_souls.enabled)
        if (activeEnemies <= cr:UI('A_AE_spin') or talent.ReaperOfSouls.enabled)
            and cd.ShadowWordDeath().charges == 2
            and insanity <= (90-20*reaperOfSoulsVar)
        then
            if cast.ShadowWordDeath('target','aoe') then return true end
        end
    -- mind_blast,if=active_enemies<=4&talent.legacy_of_the_void.enabled&(insanity<=81|(insanity<=75.2&talent.fortress_of_the_mind.enabled))
        if activeEnemies <= cr:UI('A_AE_spin') and talent.LegacyOfTheVoid.enabled and (insanity<=81 or (insanity <= 75.2 and talent.FortressOfTheMind.enabled)) then
            if cast.MindBlast() then return true end
        end
    -- mind_blast,if=active_enemies<=4&!talent.legacy_of_the_void.enabled|(insanity<=96|(insanity<=95.2&talent.fortress_of_the_mind.enabled))
        if activeEnemies <= cr:UI('A_AE_spin') and not talent.LegacyOfTheVoid.enabled or (insanity<=96 or (insanity <= 95.2 and talent.FortressOfTheMind.enabled)) then
            if cast.MindBlast() then return true end
        end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
        if not talent.Misery.enabled
            and activeEnemies < cr:UI('A_AE_spin')
            and (talent.AuspiciousSpirits.enabled or talent.ShadowyInsight.enabled)
            and not forceSingle
        then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if swpCount < cr:UI('A_SWP_T') and debuff.ShadowWordPain(enemy).down and ttd(enemy) > 10 then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- vampiric_touch,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
        if not talent.Misery.enabled
            and (activeEnemies < cr:UI('A_AE_spin') or talent.Sanlayn.enabled or (talent.AuspiciousSpirits.enabled and artifact.UnleashTheShadows.enabled))
            and not forceSingle
        then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if vtCount < cr:UI('A_VT_T') and debuff.VampiricTouch(enemy).down and ttd(enemy) > 10 then
                    if cast.VampiricTouch(enemy,'aoe') then return true end
                end
            end
        end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
        if not talent.Misery.enabled and (activeEnemies < cr:UI('A_AE_spin') and artifact.SphereOfInsanity.enabled) and not forceSingle then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if swpCount < cr:UI('A_SWP_T') and debuff.ShadowWordPain(enemy).down and ttd(enemy) > 10 then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- shadow_word_void,if=talent.shadow_word_void.enabled&(insanity<=70&talent.legacy_of_the_void.enabled)|(insanity<=85&!talent.legacy_of_the_void.enabled)
        if talent.ShadowWordVoid.enabled and ((insanity <= 70 and talent.LegacyOfTheVoid.enabled) or (insanity <= 85 and not talent.LegacyOfTheVoid.enabled)) then
            if cast.ShadowWordVoid() then return true end
        end
    -- mind_flay,interrupt=1,chain=1
        if not game:IsCastingSpell(game.Spell.SpellInfo.MindFlay) then
            if cast.MindFlay('target','channel') then return true end
        end
    -- shadow_word_pain
        if cast.ShadowWordPain('target','aoe') then return true end
    end -- Action List Main End

-- Action List VF
    local ActionListVF = function()
    -- surrender_to_madness,if=talent.surrender_to_madness.enabled&insanity>=25&(cooldown.void_bolt.up|cooldown.void_torrent.up|cooldown.shadow_word_death.up|buff.shadowy_insight.up)target.time_to_die<=variable.s2mcheck-(buff.insanity_drain_stacks.stack)
        -- Never automatic use S2M
    -- void_bolt
        if cast.VoidBolt('target','known') then return true end
    -- shadow_crash,if=talent.shadow_crash.enabled
        if talent.ShadowCrash.enabled and cr:UI('A_SC_check') then
            if cast.ShadowCrash('target','best') then return true end
        end
    -- void_torrent,if=dot.shadow_word_pain.remains>5.5&dot.vampiric_touch.remains>5.5&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+60))
        if XB.Interface:GetToggle('voidTorrent')
            and debuff.ShadowWordPain().remains > 5.5
            and debuff.VampiricTouch().remains > 5.5
            and insanityDrainStacks >= cr:UI('C_VT')
            and (not talent.SurrenderToMadness.enabled or (ttd('target') > s2mcheck - insanityDrainStacks + 60))
        then
            if cast.VoidTorrent() then return true end
        end
    -- mindbender,if=talent.mindbender.enabled&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+30))
        if talent.Mindbender.enabled
            and useCD
            and cr:UI('C_Mb')
            and (not talent.SurrenderToMadness.enabled or (ttd('target') > s2mcheck - insanityDrainStacks + 30))
        then
            if cast.Mindbender() then return true end
        end
    -- power_infusion,if=buff.insanity_drain_stacks.stack>=(10+2*set_bonus.tier19_2pc+5*buff.bloodlust.up+5*variable.s2mbeltcheck)&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+61))
        local eq_t19_2pcVar = 0 if eq_t19_2pc then eq_t19_2pcVar = 1 end
        local bloodlustVar = 0 if XB.Game:HasBloodLust() then bloodlustVar = 1 end
        if insanityDrainStacks >= (cr:UI('C_PI_spin') + 2*eq_t19_2pcVar + 5*bloodlustVar+5*s2mbeltcheckVar)
            and (not talent.SurrenderToMadness.enabled or ttd('target') > s2mcheck - insanityDrainStacks + 61)
            and useCD
            and cr:UI('C_PI_check')
        then
            if cast.PowerInfusion() then return true end
        end
    -- berserking,if=buff.voidform.stack>=10&buff.insanity_drain_stacks.stack<=20&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.stack)+60))
        if XB.Game:GetRace() == 'Troll'
            and useCD
            and buff.Voidform().stack >= 10
            and insanityDrainStacks <= 20
            and (not talent.SurrenderToMadness.enabled or ttd('target') > s2mcheck - insanityDrainStacks + 60)
        then
            if cast.Racial() then return true end
        end

        if ActionListAnyEnemyShadowWordDeath() then return true end

    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+(10+20*talent.reaper_of_souls.enabled))<100
        if (activeEnemies <= cr:UI('A_AE_spin') or talent.ReaperOfSouls.enabled)
            and currentInsanityDrain * gcd > insanity
            and insanity - (currentInsanityDrain * gcd) + (10 + 20 * reaperOfSoulsVar) < 100
        then
            if cast.ShadowWordDeath('target','aoe') then return true end
        end
    -- wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
        if cd.VoidBolt().remains < gcd*0.28 then
            XB.Runer:Wait(cd.VoidBolt().remains)
            return true
        end
    -- mind_blast,if=active_enemies<=4
        if activeEnemies <= cr:UI('A_AE_spin') then
            if cast.MindBlast() then return true end
        end
    -- wait,sec=action.mind_blast.usable_in,if=action.mind_blast.usable_in<gcd.max*0.28&active_enemies<=4
        if activeEnemies <= cr:UI('A_AE_spin') and cd.MindBlast().remains < gcd*0.28 then
            XB.Runer:Wait(cd.MindBlast().remains)
            return true
        end
    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2
        if (activeEnemies <= cr:UI('A_AE_spin') or talent.ReaperOfSouls.enabled)
            and cd.ShadowWordDeath().charges == 2
        then
            if cast.ShadowWordDeath('target','aoe') then return true end
        end
    -- shadowfiend,if=!talent.mindbender.enabled,if=buff.voidform.stack>15
        if useCD and cr:UI('C_SF') and not talent.Mindbender.enabled and buff.Voidform().stack > 15 then
            if cast.Shadowfiend() then return true end
        end
    -- shadow_word_void,if=talent.shadow_word_void.enabled&(insanity-(current_insanity_drain*gcd.max)+25)<100
        if talent.ShadowWordVoid.enabled and (insanity - (currentInsanityDrain*gcd)+25)<100 then
            if cast.ShadowWordVoid() then return true end
        end
    -- shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd,moving=1,cycle_targets=1
        if talent.Misery.enabled and game:IsMoving('player') and debuff.ShadowWordPain().remains < gcd then
            if cast.ShadowWordPain('target','aoe') then return true end
        end
        if talent.Misery.enabled and game:IsMoving('player') and not forceSingle then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if (swpCount < cr:UI('A_SWP_T') or debuff.ShadowWordPain(enemy).up)
                    and debuff.ShadowWordPain(enemy).remains < gcd
                then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max),cycle_targets=1
        if talent.Misery.enabled and (debuff.ShadowWordPain().remains < 3*gcd or debuff.VampiricTouch().remains < 3*gcd) then
            if cast.VampiricTouch('target','aoe') then return true end
        end
        if talent.Misery.enabled and not forceSingle then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if (vtCount < cr:UI('A_VT_T') or (debuff.ShadowWordPain(enemy).up and debuff.VampiricTouch(enemy).up))
                    and (debuff.ShadowWordPain(enemy).remains < 3*gcd or debuff.VampiricTouch(enemy).remains < 3*gcd)
                then
                    if cast.VampiricTouch(enemy,'aoe') then return true end
                end
            end
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if (swpCount < cr:UI('A_SWP_T') or debuff.ShadowWordPain(enemy).up)
                    and debuff.ShadowWordPain(enemy).remains < gcd
                then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
        if not talent.Misery.enabled
            and (activeEnemies <= cr:UI('A_AE_spin') or talent.AuspiciousSpirits.enabled or talent.ShadowyInsight.enabled or artifact.SphereOfInsanity.enabled)
            and debuff.ShadowWordPain().down
        then
            if cast.ShadowWordPain('target','aoe') then return true end
        end
    -- vampiric_touch,if=!talent.misery.enabled&!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
        if not talent.Misery.enabled
            and (activeEnemies <= cr:UI('A_AE_spin') or talent.Sanlayn.enabled or (talent.AuspiciousSpirits.enabled and artifact.UnleashTheShadows.enabled))
            and debuff.VampiricTouch().down
        then
            if cast.VampiricTouch('target','aoe') then return true end
        end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
        if not talent.Misery.enabled
            and swpCount < cr:UI('A_SWP_T')
            and (activeEnemies <= cr:UI('A_AE_spin') and (talent.AuspiciousSpirits.enabled or talent.ShadowyInsight.enabled))
            and not forceSingle
        then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if debuff.ShadowWordPain(enemy).down and ttd(enemy) > 10 then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- vampiric_touch,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
        if not talent.Misery.enabled
            and not forceSingle
            and (activeEnemies <= cr:UI('A_AE_spin') or talent.Sanlayn.enabled or (talent.AuspiciousSpirits.enabled and artifact.UnleashTheShadows.enabled))
            and vtCount < cr:UI('A_VT_T')
        then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if debuff.VampiricTouch(enemy).down and ttd(enemy) > 10 then
                    if cast.VampiricTouch(enemy,'aoe') then return true end
                end
            end
        end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
        if not talent.Misery.enabled
            and swpCount < cr:UI('A_SWP_T')
            and not forceSingle
            and activeEnemies <= cr:UI('A_AE_spin')
            and artifact.SphereOfInsanity.enabled
        then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if debuff.ShadowWordPain(enemy).down and ttd(enemy) > 10 then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(action.void_bolt.usable|(current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100&cooldown.shadow_word_death.charges>=1))
        if not game:IsCastingSpell(game.Spell.SpellInfo.MindFlay) then
            if cast.MindFlay('target','channel') then return true end
        end
    -- shadow_word_pain
        if cast.ShadowWordPain('target','aoe') then return true end
    end -- Action List VF End

    local ActionListS2M = function()

    end -- Action List VF End

    if buff.Voidform().up and buff.SurrenderToMadness().up then
        if ActionListS2M() then return true end
    end
    if buff.Voidform().up then
        if ActionListVF() then return true end
    end
    if ActionListMain() then return true end
end

local OutCombat = function()
    if CommonActionList() then return true end
    local t19 = XB.EquipSet:TierScan('T19')
    eq_t19_4pc = t19 >= 4
    eq_t19_2pc = t19 >= 2
    if cd.MindBlast().chargesMax >= 2 then s2mbeltcheckVar = 1 else s2mbeltcheckVar = 0 end
end

local OnLoad = function()
    XB.Interface:AddToggle({
        key = 'voidtorrent',
        name = L('VoidTorrent'),
        text = L('VoidTorrent_Des'),
        icon = game.Spell.SpellInfo.VoidTorrent,
        default = true
    })
    XB.Interface:AddToggle({
        key = 'voideruption',
        name = L('VoidEruption'),
        text = L('VoidEruption_Des'),
        icon = game.Spell.SpellInfo.VoidEruption,
        default = true
    })
end

local OnUnload = function()
end

local Pause = function()

    if XB.Game.Buff.Voidform().down then voidformStart = 0 voidformTimeStacks = 0 insanityDrainStacks = 0 end
    if voidformStart == 0 and XB.Game.Buff.Voidform().up then voidformStart = GetTime() end

    if voidformStart > 0 then
        local temp = XB.Core:Round(GetTime() - voidformStart, 0)

        if temp - voidformTimeStacks >=1 then
            voidformTimeStacks = voidformTimeStacks + 1
            if XB.Game.Buff.Dispersion().down and XB.Game.Buff.VoidTorrent().down then
                insanityDrainStacks = insanityDrainStacks + 1
            end
        end
    end

    XB.Interface:UpdateToggleText('voidtorrent',XB.Core:Round(ttd('target')))
    XB.Interface:UpdateToggleText('voideruption', insanityDrainStacks)

    if game:IsCasting() and not game:IsCastingSpell(game.Spell.SpellInfo.MindFlay) then return true end
    if InCombatLockdown() 
        and UnitExists('target')
        and not XB.Checker:IsValidEnemy('target')
        and not UnitIsFriend('player', 'target')
    then
        return true
    end
    return false
end

XB.CR:Add(258, '[XB] Priest - Shadow', InCombat, OutCombat, OnLoad, OnUnload, GUI, Pause, 40)
