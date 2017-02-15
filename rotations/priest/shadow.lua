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
local eq_t19_4pc                = false
local ttd                       = (function(Unit) return XB.CombatTracker:TimeToDie(Unit) end)
local debuff                    = XB.Game.Debuff
local cd                        = XB.Game.Spell.Cooldown
local artifact                  = XB.Game.Artifact
local UnitExists                = ObjectExists or UnitExists
local UnitIsFriend              = UnitIsFriend

local GUI = {
  {type = 'header', text = 'Abiliteis', align = 'center'},
  {type = 'checkspin', text = 'Body And Soul', key = 'A_BaS', default_check = true, default_spin = 1.5,max = 5,min = 0,step = 0.5},
  {type = 'spinner', text = 'S2M Check', key = 'A_S2MCheck', default = 90,max = 130,min = 50,step = 5},
  {type = 'spinner', text = 'SWP Targets Num', key = 'A_SWP_T', default = 6,max = 10,min = 1,step = 1},
  {type = 'spinner', text = 'VT Targets Num', key = 'A_VT_T', default = 3,max = 10,min = 1,step = 1},
  {type = 'checkbox', text = 'Shadow Crash', key = 'A_SC', default = true},
  {type = 'checkspin', text = 'Active Enemies', key = 'A_AE', default_check = false, default_spin = 5,max = 10,min = 1,step = 1},

  {type = 'ruler'},{type = 'spacer'},
  {type = 'header', text = 'CoolDown', align = 'center'},
  {type = 'text', text = 'comming soon'},
}

local CommonActionList = function()
    if cr:UI('A_BaS_check')
        and not buff.BodyAndSoul().up
        and game:IsMoving('player')
        and not buff.SurrenderToMadness().up
        and talent.BodyAndSoul.enabled
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

-- function var
    local gcd                           = game:GCD()
    local swpCount                      = debuff.ShadowWordPain().count()
    local vtCount                       = debuff.VampiricTouch().count()
    local forceSingle                   = false
    local enemies                       = XB.Area:Enemies()
    local insanity                      = XB.Game.Power.Insanity
    local activeEnemies                 = #XB.Area:EnemiesT(8) if cr:UI('A_AE_check') then activeEnemies = 1 end
    local reaperOfSoulsVar              = 0 if talent.ReaperOfSouls.enabled then reaperOfSoulsVar = 1 end

-- Action List Main
    local ActionListMain = function()
    -- surrender_to_madness,if=talent.surrender_to_madness.enabled&target.time_to_die<=variable.s2mcheck
        -- Never automatic use S2M
    -- mindbender,if=talent.mindbender.enabled&((talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck+60)|!talent.surrender_to_madness.enabled)
        if talent.Mindbender.enabled and ((talent.SurrenderToMadness.enabled and ttd('target') > cr:UI('A_S2MCheck') + 60) or not talent.SurrenderToMadness.enabled) then
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
        if insanity().amount >= 70 or (talent.AuspiciousSpirits.enabled and insanity().amount >=65) or eq_t19_4pc then
            if cast.VoidEruption('player') then return true end
        end
    -- shadow_crash,if=talent.shadow_crash.enabled
        if talent.ShadowCrash.enabled and cr:UI('A_SC') then
            if cast.ShadowCrash('target','best') then return true end
        end
    -- mindbender,if=talent.mindbender.enabled&set_bonus.tier18_2pc
        -- T18????
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&talent.legacy_of_the_void.enabled&insanity>=70,cycle_targets=1
        if not talent.Misery.enabled and talent.LegacyOfTheVoid.enabled and insanity().amount >= 70 then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if swpCount < cr:UI('A_SWP_T') and debuff.ShadowWordPain(enemy).down then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- vampiric_touch,if=!talent.misery.enabled&!ticking&talent.legacy_of_the_void.enabled&insanity>=70,cycle_targets=1
        if not talent.Misery.enabled and talent.LegacyOfTheVoid.enabled and insanity().amount >= 70 then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if vtCount < cr:UI('A_VT_T') and debuff.VampiricTouch(enemy).down then
                    if cast.VampiricTouch(enemy,'aoe') then return true end
                end
            end
        end
    -- shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2&insanity<=(90-20*talent.reaper_of_souls.enabled)
        if activeEnemies <= cr:UI('A_AE_spin')
            and cd.ShadowWordDeath().charges == 2
            and insanity().amount <= (90-20*reaperOfSoulsVar)
        then
            if cast.ShadowWordDeath('target','aoe') then return true end
        end
    -- mind_blast,if=active_enemies<=4&talent.legacy_of_the_void.enabled&(insanity<=81|(insanity<=75.2&talent.fortress_of_the_mind.enabled))
        if activeEnemies <= cr:UI('A_AE_spin') and talent.LegacyOfTheVoid.enabled and (insanity().amount<=81 or (insanity().amount <= 75.2 and talent.FortressOfTheMind.enabled)) then
            if cast.MindBlast() then return true end
        end
    -- mind_blast,if=active_enemies<=4&!talent.legacy_of_the_void.enabled|(insanity<=96|(insanity<=95.2&talent.fortress_of_the_mind.enabled))
        if activeEnemies <= cr:UI('A_AE_spin') and not talent.LegacyOfTheVoid.enabled or (insanity().amount<=96 or (insanity().amount <= 95.2 and talent.FortressOfTheMind.enabled)) then
            if cast.MindBlast() then return true end
        end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
        if not talent.Misery.enabled 
            and activeEnemies < cr:UI('A_AE_spin') 
            and (talent.AuspiciousSpirits.enabled or talent.ShadowyInsight.enabled)
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
        then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if vtCount < cr:UI('A_VT_T') and debuff.VampiricTouch(enemy).down and ttd(enemy) > 10 then
                    if cast.VampiricTouch(enemy,'aoe') then return true end
                end
            end
        end
    -- shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
        if not talent.Misery.enabled and (activeEnemies < cr:UI('A_AE_spin') and artifact.SphereOfInsanity.enabled) then
            for i = 1,#enemies do
                local enemy = enemies[i].key
                if swpCount < cr:UI('A_SWP_T') and debuff.ShadowWordPain(enemy).down and ttd(enemy) > 10 then
                    if cast.ShadowWordPain(enemy,'aoe') then return true end
                end
            end
        end
    -- shadow_word_void,if=talent.shadow_word_void.enabled&(insanity<=70&talent.legacy_of_the_void.enabled)|(insanity<=85&!talent.legacy_of_the_void.enabled)
        if talent.ShadowWordVoid.enabled and ((insanity().amount <= 70 and talent.LegacyOfTheVoid.enabled) or (insanity().amount <= 85 and not talent.LegacyOfTheVoid.enabled)) then
            if cast.ShadowWordVoid() then return true end
        end
    -- mind_flay,interrupt=1,chain=1
        if not game:IsCastingSpell(game.Spell.SpellInfo.MindFlay) then
            if cast.MindFlay() then return true end
        end
    -- shadow_word_pain
        if cast.ShadowWordPain('target','aoe') then return true end
    end -- Action List Main End

-- Action List VF
    local ActionListVF = function()
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
    eq_t19_4pc = XB.EquipSet:TierScan('T19') >= 4
end

local OnLoad = function()
end

local OnUnload = function()
end

local Pause = function()
    if game:IsCasting() and not game:IsCastingSpell(game.Spell.SpellInfo.MindFlay) then return true end
    if UnitExists('target') and (not XB.Checker:IsValidEnemy('target') and not UnitIsFriend('target')) then return true end
    return false
end

XB.CR:Add(258, '[XB] Priest - Shadow', InCombat, OutCombat, OnLoad, OnUnload, GUI, Pause, 40)
