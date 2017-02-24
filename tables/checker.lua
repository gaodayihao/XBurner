local n_name, XB                            = ...
XB.Checker                                  = {}
local GetInstanceLockTimeRemaining          = GetInstanceLockTimeRemaining
local GetInstanceLockTimeRemainingEncounter = GetInstanceLockTimeRemainingEncounter
local GetSpellInfo                          = GetSpellInfo
local GetTime                               = GetTime
local IsInInstance                          = IsInInstance
local UnitAffectingCombat                   = UnitAffectingCombat
local UnitCanAttack                         = UnitCanAttack
local UnitCastingInfo                       = UnitCastingInfo
local UnitChannelInfo                       = UnitChannelInfo
local UnitClassification                    = UnitClassification
local UnitCreatureType                      = UnitCreatureType
local UnitExists                            = ObjectExists or UnitExists
local UnitHealthMax                         = UnitHealthMax
local UnitHealth                            = UnitHealth
local UnitIsDeadOrGhost                     = UnitIsDeadOrGhost
local UnitIsFriend                          = UnitIsFriend
local UnitIsUnit                            = UnitIsUnit
local UnitIsVisible                         = UnitIsVisible
local UnitLevel                             = UnitLevel
local UnitName                              = UnitName

local Dummies = {
-- Misc/Unknown
    [79987]  = "Training Dummy",               -- Location Unknown
    [92169]  = "Raider's Training Dummy",     -- Tanking (Eastern Plaguelands)
    [96442]  = "Training Dummy",               -- Damage (Location Unknown)
    [109595] = "Training Dummy",              -- Location Unknown
    [113963] = "Raider's Training Dummy",       -- Damage (Location Unknown)
-- Level 1
    [17578]  = "Hellfire Training Dummy",     -- Lvl 1 (The Shattered Halls)
    [60197]  = "Training Dummy",              -- Lvl 1 (Scarlet Monastery)
    [64446]  = "Training Dummy",              -- Lvl 1 (Scarlet Monastery)
-- Level 3
    [44171]  = "Training Dummy",              -- Lvl 3 (New Tinkertown, Dun Morogh)
    [44389]  = "Training Dummy",              -- Lvl 3 (Coldridge Valley)
    [44848]  = "Training Dummy",               -- Lvl 3 (Camp Narache, Mulgore)
    [44548]  = "Training Dummy",              -- Lvl 3 (Elwynn Forest)
    [44614]  = "Training Dummy",              -- Lvl 3 (Teldrassil, Shadowglen)
    [44703]  = "Training Dummy",               -- Lvl 3 (Ammen Vale)
    [44794]  = "Training Dummy",               -- Lvl 3 (Dethknell, Tirisfal Glades)
    [44820]  = "Training Dummy",              -- Lvl 3 (Valley of Trials, Durotar)
    [44937]  = "Training Dummy",              -- Lvl 3 (Eversong Woods, Sunstrider Isle)
    [48304]  = "Training Dummy",              -- Lvl 3 (Kezan)
-- Level 55
    [32541]  = "Initiate's Training Dummy",   -- Lvl 55 (Plaguelands: The Scarlet Enclave)
    [32545]  = "Initiate's Training Dummy",   -- Lvl 55 (Eastern Plaguelands)
-- Level 60
    [32666]  = "Training Dummy",              -- Lvl 60 (Siege of Orgrimmar, Darnassus, Ironforge, ...)
-- Level 65
    [32542]  = "Disciple's Training Dummy",   -- Lvl 65 (Eastern Plaguelands)
-- Level 70
    [32667]  = "Training Dummy",              -- Lvl 70 (Orgrimmar, Darnassus, Silvermoon City, ...)
-- Level 75
    [32543]  = "Veteran's Training Dummy",    -- Lvl 75 (Eastern Plaguelands)
-- Level 80
    [31144]  = "Training Dummy",              -- Lvl 80 (Orgrimmar, Darnassus, Ironforge, ...)
    [32546]  = "Ebon Knight's Training Dummy",-- Lvl 80 (Eastern Plaguelands)
-- Level 85
    [46647]  = "Training Dummy",              -- Lvl 85 (Orgrimmar, Stormwind City)
-- Level 90
    [67127]  = "Training Dummy",              -- Lvl 90 (Vale of Eternal Blossoms)
-- Level 95
    [79414]  = "Training Dummy",              -- Lvl 95 (Broken Shore, Talador)
-- Level 100
    [87317]  = "Training Dummy",              -- Lvl 100 (Lunarfall, Frostwall) - Damage
    [87321]  = "Training Dummy",              -- Lvl 100 (Stormshield) - Healing
    [87760]  = "Training Dummy",              -- Lvl 100 (Frostwall) - Damage
    [88289]  = "Training Dummy",              -- Lvl 100 (Frostwall) - Healing
    [88316]  = "Training Dummy",              -- Lvl 100 (Lunarfall) - Healing
    [88835]  = "Training Dummy",              -- Lvl 100 (Warspear) - Healing
    [88906]  = "Combat Dummy",                -- Lvl 100 (Nagrand)
    [88967]  = "Training Dummy",              -- Lvl 100 (Lunarfall, Frostwall)
    [89078]  = "Training Dummy",              -- Lvl 100 (Frostwall, Lunarfall)
-- Levl 100 - 110
    [92164]  = "Training Dummy",               -- Lvl 100 - 110 (Dalaran) - Damage
    [92165]  = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 (Eastern Plaguelands) - Damage
    [92167]  = "Training Dummy",              -- Lvl 100 - 110 (The Maelstrom, Eastern Plaguelands, The Wandering Isle)
    [92168]  = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 (The Wandering Isles, Easter Plaguelands)
    [100440] = "Training Bag",                   -- Lvl 100 - 110 (The Wandering Isles)
    [100441] = "Dungeoneer's Training Bag",   -- Lvl 100 - 110 (The Wandering Isles)
    [102045] = "Rebellious Wrathguard",       -- Lvl 100 - 110 (Dreadscar Rift) - Dungeoneer
    [102048] = "Rebellious Felguard",         -- Lvl 100 - 110 (Dreadscar Rift)
    [102052] = "Rebellious Imp",               -- Lvl 100 - 110 (Dreadscar Rift) - AoE
    [103402] = "Lesser Bulwark Construct",    -- Lvl 100 - 110 (Hall of the Guardian)
    [103404] = "Bulwark Construct",           -- Lvl 100 - 110 (Hall of the Guardian) - Dungeoneer
    [107483] = "Lesser Sparring Partner",     -- Lvl 100 - 110 (Skyhold)
    [107555] = "Bound Void Wraith",           -- Lvl 100 - 110 (Netherlight Temple)
    [107557] = "Training Dummy",              -- Lvl 100 - 110 (Netherlight Temple) - Healing
    [108420] = "Training Dummy",              -- Lvl 100 - 110 (Stormwind City, Durotar)
    [111824] = "Training Dummy",               -- Lvl 100 - 110 (Azsuna)
    [113674] = "Imprisoned Centurion",        -- Lvl 100 - 110 (Mardum, the Shattered Abyss) - Dungeoneer
    [113676] = "Imprisoned Weaver",           -- Lvl 100 - 110 (Mardum, the Shattered Abyss)
    [113687] = "Imprisoned Imp",              -- Lvl 100 - 110 (Mardum, the Shattered Abyss) - Swarm
    [113858] = "Training Dummy",              -- Lvl 100 - 110 (Trueshot Lodge) - Damage
    [113859] = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 (Trueshot Lodge) - Damage
    [113862] = "Training Dummy",              -- Lvl 100 - 110 (Trueshot Lodge) - Damage
    [113863] = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 (Trueshot Lodge) - Damage
    [113871] = "Bombardier's Training Dummy", -- Lvl 100 - 110 (Trueshot Lodge) - Damage
    [113966] = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 - Damage
    [113967] = "Training Dummy",              -- Lvl 100 - 110 (The Dreamgrove) - Healing
    [114832] = "PvP Training Dummy",          -- Lvl 100 - 110 (Stormwind City)
    [114840] = "PvP Training Dummy",          -- Lvl 100 - 110 (Orgrimmar)
-- Level 102
    [87318]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Lunarfall) - Damage
    [87322]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Stormshield) - Tank
    [87761]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Frostwall) - Damage
    [88288]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Frostwall) - Tank
    [88314]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Lunarfall) - Tank
    [88836]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Warspear) - Tank
    [93828]  = "Training Dummy",              -- Lvl 102 (Hellfire Citadel)
    [97668]  = "Boxer's Trianing Dummy",      -- Lvl 102 (Highmountain)
    [98581]  = "Prepfoot Training Dummy",     -- Lvl 102 (Highmountain)
-- Level ??
    [24792]  = "Advanced Training Dummy",     -- Lvl ?? Boss (Location Unknonw)
    [30527]  = "Training Dummy",               -- Lvl ?? Boss (Location Unknonw)
    [31146]  = "Raider's Training Dummy",     -- Lvl ?? (Orgrimmar, Stormwind City, Ironforge, ...)
    [87320]  = "Raider's Training Dummy",     -- Lvl ?? (Lunarfall, Stormshield) - Damage
    [87329]  = "Raider's Training Dummy",     -- Lvl ?? (Stormshield) - Tank
    [87762]  = "Raider's Training Dummy",     -- Lvl ?? (Frostwall, Warspear) - Damage
    [88837]  = "Raider's Training Dummy",     -- Lvl ?? (Warspear) - Tank
    [92166]  = "Raider's Training Dummy",     -- Lvl ?? (The Maelstrom, Dalaran, Eastern Plaguelands, ...) - Damage
    [101956] = "Rebellious Fel Lord",         -- lvl ?? (Dreadscar Rift) - Raider
    [103397] = "Greater Bulwark Construct",   -- Lvl ?? (Hall of the Guardian) - Raider
    [107202] = "Reanimated Monstrosity",       -- Lvl ?? (Broken Shore) - Raider
    [107484] = "Greater Sparring Partner",    -- Lvl ?? (Skyhold)
    [107556] = "Bound Void Walker",           -- Lvl ?? (Netherlight Temple) - Raider
    [113636] = "Imprisoned Forgefiend",       -- Lvl ?? (Mardum, the Shattered Abyss) - Raider
    [113860] = "Raider's Training Dummy",     -- Lvl ?? (Trueshot Lodge) - Damage
    [113864] = "Raider's Training Dummy",     -- Lvl ?? (Trueshot Lodge) - Damage
    [70245]  = "Training Dummy",              -- Lvl ?? (Throne of Thunder)
    [113964] = "Raider's Training Dummy",     -- Lvl ?? (The Dreamgrove) - Tanking
}

local ByPassMounts = {
    164222,             -- frostwolf-war-wolf
    165803,             -- telaari-talbuk
    221595,             -- storms-reach-cliffwalker
    221671,             -- storms-reach-warbear
    221672,             -- storms-reach-greatstag
    221673,             -- storms-reach-worg
    221883,             -- divine-steed
    221887,             -- divine-steed
}

local ByPassMove = {
    79206,              -- Spiritwalker's Grace
    193223,             -- Surrender to Madness
}

local ByPassTarget = {
    [103679]       = '',  -- Soul Effigy
}

local SpecialUnitVerify = {
    [103679] = { func = function(theUnit) return not UnitIsFriend(theUnit,"player") end },     -- Soul Effigy
    [95887] = { func = function(theUnit)
        return not UnitIsDeadOrGhost(theUnit) and UnitCanAttack("player",theUnit) and XB.Game:GetUnitBuffAny(theUnit,194323) == nil
    end },     -- Glazer
    [95888] = { func = function(theUnit)
        return not UnitIsDeadOrGhost(theUnit) and UnitCanAttack("player",theUnit) and XB.Game:GetUnitBuffAny(theUnit,197422) == nil and XB.Game:GetUnitBuffAny(theUnit,205004) == nil
    end },     -- Cordana Felsong
    [105906] = { func = function(theUnit)
        return not UnitIsDeadOrGhost(theUnit) and UnitCanAttack("player",theUnit) and XB.Game:GetUnitBuffAny(theUnit,209915) == nil
    end },     -- Eye of Il'gynoth
    [105503] = { func = function(theUnit)
        return not UnitIsDeadOrGhost(theUnit) and UnitCanAttack("player",theUnit) and XB.Game:GetUnitBuffAny(theUnit,206516) == nil
    end },     -- Gul'dan
}

local ShouldContinue = {
    1022,           -- Hand of Protection
    31821,          -- Devotion
    104773,         -- Unending Resolve
}

local ForceStop = {
    208944,           -- Time Stop
}

local ShouldStop = {
    [137457]='',         -- Piercing Roar(Oondasta)
    [138763]='',         -- Interrupting Jolt(Dark Animus)
    [143343]='',         -- Deafening Screech(Thok)
    [158093]='',         -- Interrupting Shout (Twin Ogrons:Pol)
    [160838]='',         -- Disrupting Roar (Hans'gar and Franzok)

    -- 7.x legion
    [196543]='',         -- 震慑吼叫 (Fenryr)
}

function XB.Checker:ByPassMounts()
    for i=1, #ByPassMounts do
        if XB.Game:GetUnitBuffAny('player', ByPassMounts[i]) then
            return true
        end
    end
    return false
end

function XB.Checker:ByPassMove()
    for i=1, #ByPassMove do
        if XB.Game:GetUnitBuffAny('player', ByPassMove[i]) then
            return true
        end
    end
    return false
end

function XB.Checker:ByPassTarget(Unit)
    return ByPassTarget[XB.Game:UnitID(Unit)] ~= nil
end

function XB.Checker:IsSafeToAttack(Unit)
    return true
end

function XB.Checker:ShouldStopCasting(SpellID,isChannel)
    local isChannel = isChannel or false
    for i=1,5 do
        local boss = 'boss'..i
        if UnitExists(boss) then
            for k=1,#ShouldContinue do
                if XB.Game:GetUnitBuffAny('player',ShouldContinue[k]) then return false end
            end
            
            if not isChannel and XB.Game:GetCastTime(SpellID) == 0 then return false end

            local name, _, _, _, _, endTime, _, _, _, bossSpellID = UnitCastingInfo(boss)
            if name ~= nil and ShouldStop[bossSpellID]~=nil then
                if isChannel then
                    return XB.Game:GCD() + GetTime() + 100 > endTime
                else
                    return XB.Game:GetCastTime(SpellID) + GetTime() + 100 > endTime
                end
            end
        end
    end
    return false
end

function XB.Checker:BetterStopCasting()
    for i=1,5 do
        local boss = 'boss'..i
        if UnitExists(boss) then
            local name, _, _, _, _, endTime = UnitCastingInfo('player')
            if name == nil then name, _, _, _, _, endTime = UnitChannelInfo('player') end
            if name == nil then return false end
            for k=1,#ShouldContinue do
                if XB.Game:GetUnitBuffAny('player',ShouldContinue[k]) then return false end
            end
            local bossCast, _, _, _, _, bossEndTime, _, _, _, bossSpellID = UnitCastingInfo(boss)
            if bossCast ~= nil and ShouldStop[bossSpellID]~=nil then
                return endTime >= bossEndTime
            end
        end
    end
    return false
end

function XB.Checker.ForceStop()
    for i=1,#ForceStop do
        if XB.Game:GetUnitDebuffAny('player',ForceStop[i]) then return true end
    end
    return false
end

function XB.Checker:IsDummy(Unit)
    local Unit = Unit or 'target'
    if UnitExists(Unit) and Dummies[XB.Game:UnitID(Unit)] ~= nil then
        return true
    end
    return false
end

local function IsInstanceBoss(Unit)
    if IsInInstance() then
        local lockTimeleft,ipPreviousInstance,encountersTotal,encountersComplete = GetInstanceLockTimeRemaining();
        for i=1,encountersTotal do
            if UnitExists(Unit) then
                local bossName = GetInstanceLockTimeRemainingEncounter(i)
                local targetName = UnitName(Unit)
                if targetName == bossName then return true end
            end
        end
        for i = 1,5 do
            local bossNum = 'boss'..i
            if UnitExists(bossNum) and UnitIsUnit(Unit,bossNum) then return true end
        end
    end
    return false
end

function XB.Checker:IsBoss(Unit)
    local Unit = Unit or 'target'
    if UnitExists(Unit) then
        local bossCheck = IsInstanceBoss(Unit)
        if bossCheck or XB.Checker:IsDummy(Unit) then
            return true
        end
        local unitClassification = UnitClassification(Unit)
        local solo = XB.Game:IsSolo()
        if ((unitClassification == 'race' and UnitHealthMax(Unit) > (4*UnitHealthMax('player')) and solo)
            or unitClassification == "rareelite" and solo
            or unitClassification == "worldboss"
            or (unitClassification == 'elite' and UnitHealthMax(Unit) > (4*UnitHealthMax('player')) and solo)
            or UnitLevel(Unit) < 0
            or UnitLevel(Unit) >= 113) and not UnitIsTrivial(Unit)
        then
            return true
        end
    end
    return false
end

function XB.Checker:IsValidEnemy(Unit)
    if not UnitExists(Unit) or not UnitIsVisible(Unit) then
        return false
    end
    if SpecialUnitVerify[XB.Game:UnitID(Unit)] ~= nil then
        return SpecialUnitVerify[XB.Game:UnitID(Unit)].func(Unit)
    end
    local myTarget = UnitIsUnit(Unit,"target")
    local creatureType = UnitCreatureType(Unit)
    local trivial = creatureType == "Critter" or creatureType == "Non-combat Pet" or creatureType == "Gas Cloud" or creatureType == "Wild Pet"
    if UnitCanAttack("player",Unit) and not UnitIsDeadOrGhost(Unit) and not trivial and (creatureType ~= "Totem" or myTarget) then
        if UnitIsPlayer(Unit) and not XB.Config:Read(n_name..'_Settings', 'ap', false) and not IsInInstance() then return false end
        local range = 20
        local inRaid = select(2,IsInInstance()) == "raid"
        if inRaid then
            range = 40
        end
        local inAggroRange = XB.Protected.Distance(Unit) <= range
        local inCombat = UnitAffectingCombat("player")
        -- Only consider Units that are in 20yrs or I have targeted when not in Combat and not in an Instance.
        if not inCombat and not IsInInstance() and (inAggroRange or myTarget) then return true end
        local threat = XB.Game:HasThreat(Unit)
        -- Only consider Units that I have threat with or I am alone and have targeted when not in Combat and in an Instance.
        if not inCombat and IsInInstance() and (threat or (XB.Game:IsSolo() and myTarget)) then return true end
        -- Only consider Units that I have threat with or I can attack and have targeted or are dummies within 20yrds when in Combat.
        if inCombat and (threat or myTarget or (XB.Checker:IsDummy(Unit) and inAggroRange)) then return true end
    end
    return false
end