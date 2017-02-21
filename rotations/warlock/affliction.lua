local _, XB                     = ...

-- func cache
local GetTime                   = GetTime
local UnitExists                = ObjectExists or UnitExists
local UnitIsFriend              = UnitIsFriend

-- local var
local artifact                  = XB.Game.Artifact
local buff                      = XB.Game.Buff
local cast                      = XB.Game.Spell.Cast
local cd                        = XB.Game.Spell.Cooldown
local debuff                    = XB.Game.Debuff
local eq_t19_2pc                = false
local eq_t19_4pc                = false
local game                      = XB.Game
local L                         = (function(key) return XB.Locale:TA('Affliction',key) end)
local talent                    = XB.Game.Talent
local ttd                       = (function(Unit) return XB.CombatTracker:TimeToDie(Unit) end)
local UI                        = (function(key) return XB.CR:UI(key) end)
local TargetRange               = 40
local ReapAndSowVar             = 0
local eqset                     = XB.EquipSet
local effigy                    = nil

local GUI = {
  {type = 'header', text = XB.Locale:TA('Any','Abiliteis'), align = 'center'},{type = 'spacer'},
  {type = 'spinner', text = L('AgonyMulTar'), key = 'A_Agony_T', default = 6,max = 10,min = 1,step = 1},
  {type = 'spinner', text = L('CorruptionMulTar'), key = 'A_Corruption_T', default = 3,max = 10,min = 1,step = 1},
  {type = 'spinner', text = L('SiphonLifeMulTar'), key = 'A_SiphonLife_T', default = 3,max = 10,min = 1,step = 1},

  {type = 'spacer'},{type = 'ruler'},
  {type = 'header', text = XB.Locale:TA('Any','CD'), align = 'center'},{type = 'spacer'},
}

local CommonActionList = function()
end

local InCombat = function()
    if CommonActionList() then return true end
    if not XB.Checker:IsValidEnemy('target') then return true end

    local activeUAs                     = 0
    local agonyCount                    = debuff.Agony().count()
    local corruptionCount               = debuff.Corruption().count()
    local siphonLifeCount               = debuff.SiphonLife().count()
    local gcd                           = game:GCD()
    local enemies                       = XB.Area:Enemies()
    local useCD                         = XB.Game:UseCooldown()
    local socTargets                    = #XB.Area:EnemiesT(8)
    local soulShards                    = XB.Game.Power.SoulShards().amount
    local mana                          = XB.Game.Power.Mana().percent
    local travelTime                    = XB.Protected.Distance('target') / 16

    for i=1,5 do
        if debuff['UnstableAffliction'..tostring(i)]().up then
            activeUAs = activeUAs + 1
        end
    end
    if talent.SoulEffigy.enabled and effigy == nil then
        for i = 1,#enemies do
            local unit = enemies[i].key
            if XB.Game:UnitID(unit) == 103679 then
                effigy = unit
                break
            end
        end
    end
    if talent.SoulEffigy.enabled and (not UnitExists(effigy) or XB.Protected.Distance(effigy) > 40) then
        effigy = nil
    end
-- reap_souls,if=!buff.deadwind_harvester.remains&(buff.soul_harvest.remains>5+equipped.144364*1.5&!talent.malefic_grasp.enabled&buff.active_uas.stack>1|buff.tormented_souls.react>=8|target.time_to_die<=buff.tormented_souls.react*5+equipped.144364*1.5|!talent.malefic_grasp.enabled&(trinket.proc.any.react|trinket.stacking_proc.any.react))
    if buff.DeadwindHarvester().down
        and (buff.SoulHarvest().remains > 5+ReapAndSowVar*1.5 and not talent.MaleficGrasp.enabled and activeUAs > 1
                or buff.TormentedSouls().stack >= 8
                or ttd('target') <= buff.TormentedSouls().stack * (5 + ReapAndSowVar * 1.5)
                or not talent.MaleficGrasp.enabled) 
        and buff.TormentedSouls().stack > 0
    then
        if cast.ReapSouls() then XB.Runer:Wait(0.15) return true end
    end
-- soul_effigy,if=!pet.soul_effigy.active
    if talent.SoulEffigy.enabled and XB.Runer.LastCast ~= game.Spell.SpellInfo.SoulEffigy and effigy == nil then
        if cast.SoulEffigy() then return true end
    end
-- agony,cycle_targets=1,if=remains<=tick_time+gcd
    for i = 1,#enemies do
        local enemy = enemies[i].key
        if debuff.Agony(enemy).remains < 2+gcd and (debuff.Agony(enemy).up or agonyCount < UI('A_Agony_T')) then
            if cast.Agony(enemy,'aoe') then return true end
        end
    end
-- service_pet,if=dot.corruption.remains&dot.agony.remains
    --TODO:
-- summon_doomguard,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal<=2&(target.time_to_die>180|target.health.pct<=20|target.time_to_die<30)
-- summon_infernal,if=!talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>2
-- summon_doomguard,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal=1&equipped.132379&!cooldown.sindorei_spite_icd.remains
-- summon_infernal,if=talent.grimoire_of_supremacy.enabled&spell_targets.summon_infernal>1&equipped.132379&!cooldown.sindorei_spite_icd.remains
-- berserking,if=prev_gcd.1.unstable_affliction|buff.soul_harvest.remains>=10
-- blood_fury
-- arcane_torrent
-- soul_harvest,if=buff.active_uas.stack>=3|!equipped.132394&!equipped.132457&(debuff.haunt.remains|talent.writhe_in_agony.enabled)
    if activeUAs >= 3 
        or not game:HasEquiped(eqset.HoodOfEternalDisdain) 
            and not game:HasEquiped(eqset.PowerCordOfLethtendris) 
            and (debuff.Haunt().up or talent.WritheInAgony.enabled)
    then
        if cast.SoulHarvest() then return true end
    end
-- potion,name=prolonged_power,if=!talent.soul_harvest.enabled&(trinket.proc.any.react|trinket.stack_proc.any.react|target.time_to_die<=70|!cooldown.haunt.remains|buff.active_uas.stack>2|buff.nefarious_pact.react)
-- potion,name=prolonged_power,if=talent.soul_harvest.enabled&buff.soul_harvest.remains&(trinket.proc.any.react|trinket.stack_proc.any.react|target.time_to_die<=70|!cooldown.haunt.remains|buff.active_uas.stack>2|buff.nefarious_pact.react)
-- corruption,if=remains<=tick_time+gcd&(spell_targets.seed_of_corruption<3&talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<4)&(buff.active_uas.stack<2&soul_shard=0|!talent.malefic_grasp.enabled)
    if debuff.Corruption().remains <= 2
        and (socTargets < 3 and talent.SowTheSeeds.enabled or socTargets < 4)
        and (activeUAs < 2 and soulShards == 0 or not talent.MaleficGrasp.enabled)
    then
        if cast.Corruption('target','aoe') then return true end
    end
-- corruption,cycle_targets=1,if=(talent.absolute_corruption.enabled|!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&active_enemies>1&remains<=tick_time+gcd&(spell_targets.seed_of_corruption<3&talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<4)
    if (talent.AbsoluteCorruption.enabled or not talent.MaleficGrasp.enabled or not talent.SoulEffigy.enabled) and (socTargets < 3 and talent.SowTheSeeds.enabled or socTargets < 4) then
        for i = 1,#enemies do
            local enemy = enemies[i].key
            if debuff.Corruption(enemy).remains < 2+gcd and (debuff.Corruption(enemy).up or corruptionCount < UI('A_Corruption_T')) then
                if cast.Corruption(enemy,'aoe') then return true end
            end
        end
    end
-- siphon_life,if=remains<=tick_time+gcd&(buff.active_uas.stack<2&soul_shard=0|!talent.malefic_grasp.enabled)
    if (talent.SiphonLife.enabled and activeUAs < 2 and soulShards == 0 or not talent.MaleficGrasp.enabled) and debuff.SiphonLife().remains < 2+gcd then
        if cast.SiphonLife('target','aoe') then return true end
    end
-- siphon_life,cycle_targets=1,if=(!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&active_enemies>1&remains<=tick_time+gcd
    if talent.SiphonLife.enabled and (not talent.MaleficGrasp.enabled or not talent.SoulEffigy.enabled) then
        for i = 1,#enemies do
            local enemy = enemies[i].key
            if debuff.SiphonLife(enemy).remains < 2+gcd and (debuff.SiphonLife(enemy).up or siphonLifeCount < UI('A_SiphonLife_T')) then
                if cast.SiphonLife(enemy,'aoe') then return true end
            end
        end
    end
-- life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<=gcd
    if talent.EmpoweredLifeTap.enabled and buff.EmpoweredLifeTap().remains <= gcd then
        if cast.LifeTap() then return true end
    end
-- phantom_singularity
    if talent.PhantomSingularity.enabled and cast.PhantomSingularity() then return true end
-- haunt
    if talent.Haunt.enabled and cast.Haunt() then return true end
-- agony,cycle_targets=1,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
-- agony,cycle_targets=1,if=remains<=duration*0.3&target.time_to_die>=remains&buff.active_uas.stack=0
    if not talent.MaleficGrasp.enabled or activeUAs == 0 then
        for i = 1,#enemies do
            local enemy = enemies[i].key
            if debuff.Agony(enemy).refresh and ttd(enemy) >= debuff.Agony(enemy).remains and (debuff.Agony(enemy).up or agonyCount < UI('A_Agony_T')) then
                if cast.Agony(enemy,'aoe') then return true end
            end
        end
    end
-- life_tap,if=talent.empowered_life_tap.enabled&buff.empowered_life_tap.remains<duration*0.3|talent.malefic_grasp.enabled&target.time_to_die>15&mana.pct<10
    if talent.EmpoweredLifeTap.enabled and buff.EmpoweredLifeTap().refresh or talent.MaleficGrasp.enabled and ttd('target') > 15 and mana < 10 then
        if cast.LifeTap() then return true end
    end
-- seed_of_corruption,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption>=3|spell_targets.seed_of_corruption>=4|spell_targets.seed_of_corruption=3&dot.corruption.remains<=cast_time+travel_time
    if talent.SowTheSeeds.enabled and socTargets >=3 
        or socTargets >= 4 
        or socTargets ==3 and debuff.Corruption().remains<= game:GetCastTime(game.Spell.SpellInfo.SeedOfCorruption) + travelTime 
    then
        if cast.SeedOfCorruption() then return true end
    end
-- corruption,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
-- corruption,if=remains<=duration*0.3&target.time_to_die>=remains&buff.active_uas.stack=0
    if (not talent.MaleficGrasp.enabled or activeUAs == 0) and debuff.Corruption().refresh and ttd('target') >= debuff.Corruption().remains then
        if cast.Corruption() then return true end
    end
-- corruption,cycle_targets=1,if=(talent.absolute_corruption.enabled|!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&remains<=duration*0.3&target.time_to_die>=remains
    if (talent.AbsoluteCorruption.enabled or not talent.MaleficGrasp.enabled or not talent.SoulEffigy.enabled) then
        for i = 1,#enemies do
            local enemy = enemies[i].key
            if debuff.Corruption(enemy).refresh and ttd(enemy) >= debuff.Corruption(enemy).remains and (debuff.Corruption(enemy).up or corruptionCount < UI('A_Corruption_T')) then
                if cast.Corruption(enemy,'aoe') then return true end
            end
        end
    end
-- siphon_life,if=!talent.malefic_grasp.enabled&remains<=duration*0.3&target.time_to_die>=remains
-- siphon_life,if=remains<=duration*0.3&target.time_to_die>=remains&buff.active_uas.stack=0
    if (not talent.MaleficGrasp.enabled or activeUAs == 0) and debuff.Corruption().refresh and ttd('target') >= debuff.Corruption().remains then
        if cast.Corruption() then return true end
    end
-- siphon_life,cycle_targets=1,if=(!talent.malefic_grasp.enabled|!talent.soul_effigy.enabled)&remains<=duration*0.3&target.time_to_die>=remains
    if not talent.MaleficGrasp.enabled or activeUAs == 0 then
        for i = 1,#enemies do
            local enemy = enemies[i].key
            if debuff.Agony(enemy).refresh and ttd(enemy) >= debuff.Agony(enemy).remains and (debuff.Agony(enemy).up or siphonLifeCount < UI('A_SiphonLife_T')) then
                if cast.Agony(enemy,'aoe') then return true end
            end
        end
    end
-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&talent.haunt.enabled&(soul_shard>=4|debuff.haunt.remains>6.5|target.time_to_die<30)
    if (not talent.SowTheSeeds.enabled or socTargets < 3) and talent.Haunt.enabled and (soulShards >=4 or debuff.Haunt().remains > 6.5 or ttd('target') < 30) then
        if cast.UnstableAffliction() then return true end
    end

-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.writhe_in_agony.enabled&talent.contagion.enabled&dot.unstable_affliction_1.remains<cast_time&dot.unstable_affliction_2.remains<cast_time&dot.unstable_affliction_3.remains<cast_time&dot.unstable_affliction_4.remains<cast_time&dot.unstable_affliction_5.remains<cast_time
    if (not talent.SowTheSeeds.enabled or socTargets < 3)
        and socTargets < 4
        and talent.WritheInAgony.enabled
        and talent.Contagion.enabled
        and debuff.UnstableAffliction1().remains < game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction)
        and debuff.UnstableAffliction2().remains < game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction)
        and debuff.UnstableAffliction3().remains < game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction)
        and debuff.UnstableAffliction4().remains < game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction)
        and debuff.UnstableAffliction5().remains < game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction)
    then
        if cast.UnstableAffliction() then return true end
    end
-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.writhe_in_agony.enabled&(soul_shard>=4|trinket.proc.intellect.react|trinket.stacking_proc.mastery.react|trinket.proc.mastery.react|trinket.proc.crit.react|trinket.proc.versatility.react|buff.soul_harvest.remains|buff.deadwind_harvester.remains|buff.compounding_horror.react=5|target.time_to_die<=20)
    if (not talent.SowTheSeeds.enabled or socTargets < 3)
        and socTargets <4
        and talent.WritheInAgony.enabled
        and (soulShards >= 4 or buff.SoulHarvest().up or buff.DeadwindHarvester().up or buff.CompoundingHorror().stack == 5 or ttd('target') <= 20)
    then
        if cast.UnstableAffliction() then return true end
    end
-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&(target.time_to_die<30|prev_gcd.1.unstable_affliction&soul_shard>=4)
    if (not talent.SowTheSeeds.enabled or socTargets < 3)
        and socTargets <4
        and talent.MaleficGrasp.enabled
        and(ttd('target') < 30 or XB.Runer.LastCast == game.Spell.SpellInfo.UnstableAffliction and soulShards >=4)
    then
        if cast.UnstableAffliction() then return true end
    end
-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&(soul_shard=5|talent.contagion.enabled&soul_shard>=4)
    if (not talent.SowTheSeeds.enabled or socTargets < 3)
        and socTargets <4
        and talent.MaleficGrasp.enabled
        and (soulShards == 5 or talent.Contagion.enabled and soulShards >=4)
    then
        if cast.UnstableAffliction() then return true end
    end
-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&(talent.soul_effigy.enabled|equipped.132457)&!prev_gcd.3.unstable_affliction&prev_gcd.1.unstable_affliction
    if (not talent.SowTheSeeds.enabled or socTargets < 3)
        and socTargets <4
        and talent.MaleficGrasp.enabled
        and (talent.SoulEffigy.enabled or game:HasEquiped(eqset.PowerCordOfLethtendris))
        and XB.Runer.LastCast ~= game.Spell.SpellInfo.UnstableAffliction
    then
        if cast.UnstableAffliction() then return true end
    end
-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&equipped.132457&buff.active_uas.stack=0
    if (not talent.SowTheSeeds.enabled or socTargets < 3)
        and socTargets <4
        and talent.MaleficGrasp.enabled
        and game:HasEquiped(eqset.PowerCordOfLethtendris)
        and activeUAs == 0
    then
        if cast.UnstableAffliction() then return true end
    end
-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&talent.soul_effigy.enabled&!equipped.132457&buff.active_uas.stack=0&dot.agony.remains>cast_time*3+6.5&(!talent.soul_effigy.enabled|pet.soul_effigy.dot.agony.remains>cast_time*3+6.5)
    if (not talent.SowTheSeeds.enabled or socTargets < 3)
        and socTargets <4
        and talent.MaleficGrasp.enabled
        and talent.SoulEffigy.enabled
        and not game:HasEquiped(eqset.PowerCordOfLethtendris)
        and activeUAs == 0
        and debuff.Agony().remains > game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction) * 3 + 6.5
        and effigy ~= nil and debuff.Agony(effigy).remains > game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction) * 3 + 6.5
    then
        if cast.UnstableAffliction() then return true end
    end
-- unstable_affliction,if=(!talent.sow_the_seeds.enabled|spell_targets.seed_of_corruption<3)&spell_targets.seed_of_corruption<4&talent.malefic_grasp.enabled&!talent.soul_effigy.enabled&!equipped.132457&!prev_gcd.3.unstable_affliction&dot.agony.remains>cast_time*3+6.5&(dot.corruption.remains>cast_time+6.5|talent.absolute_corruption.enabled)
    if (not talent.SowTheSeeds.enabled or socTargets < 3)
        and socTargets < 4
        and talent.MaleficGrasp.enabled
        and not talent.SoulEffigy.enabled
        and not game:HasEquiped(eqset.PowerCordOfLethtendris)
        and debuff.Agony().remains > game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction) * 3 + 6.5
        and (debuff.Corruption().remains > game:GetCastTime(game.Spell.SpellInfo.UnstableAffliction) + 6.5 or talent.AbsoluteCorruption.enabled)
    then
        if cast.UnstableAffliction() then return true end
    end
-- reap_souls,if=!buff.deadwind_harvester.remains&buff.active_uas.stack>1&((!trinket.has_stacking_stat.any&!trinket.has_stat.any)|talent.malefic_grasp.enabled)
    if not buff.DeadwindHarvester().up and activeUAs > 1 and talent.MaleficGrasp.enabled and buff.TormentedSouls().stack > 0 then
        if cast.ReapSouls() then XB.Runer:Wait(0.15) return true end
    end
-- reap_souls,if=!buff.deadwind_harvester.remains&prev_gcd.1.unstable_affliction&((!trinket.has_stacking_stat.any&!trinket.has_stat.any)|talent.malefic_grasp.enabled)&buff.tormented_souls.react>1
    if not buff.DeadwindHarvester().up 
        and XB.Runer.LastCast == game.Spell.SpellInfo.UnstableAffliction
        and (talent.MaleficGrasp.enabled)
        and buff.TormentedSouls().stack > 1
    then
        if cast.ReapSouls() then XB.Runer:Wait(0.15) return true end
    end
-- life_tap,if=mana.pct<=10
    if mana <= 10 then
        if cast.LifeTap() then return true end
    end
-- drain_soul,chain=1,interrupt=1
    if game:IsCastingSpell(game.Spell.SpellInfo.DrainSoul)  then return true end
    if cast.DrainSoul('target','channel') then return true end
-- life_tap
    if mana <= 70 then
        if cast.LifeTap() then return true end
    end
end

local OutCombat = function()
    if game:HasEquiped(eqset.ReapAndSow) then ReapAndSowVar = 1 else ReapAndSowVar = 0 end
    if CommonActionList() then return true end
end

local OnLoad = function()
end

local OnUnload = function()
end

local Pause = function()
    if game:IsCasting() and not game:IsCastingSpell(game.Spell.SpellInfo.DrainSoul) then return true end
    return false
end

XB.CR:Add(265, L('Name'), InCombat, OutCombat, OnLoad, OnUnload, GUI, Pause, TargetRange)
