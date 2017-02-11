local _, XB                     = ...
XB.Checker                      = {}
local UnitExists                = ObjectExists or UnitExists
local UnitIsVisible             = UnitIsVisible
local UnitIsFriend              = UnitIsFriend
local UnitCanAttack             = UnitCanAttack
local UnitIsDeadOrGhost         = UnitIsDeadOrGhost
local UnitIsUnit                = UnitIsUnit
local UnitCreatureType          = UnitCreatureType
local IsInInstance              = IsInInstance
local UnitAffectingCombat       = UnitAffectingCombat
--[[
165803/telaari-talbuk
164222/frostwolf-war-wolf
221883/divine-steed
221887/divine-steed
221673/storms-reach-worg
221595/storms-reach-cliffwalker
221672/storms-reach-greatstag
221671/storms-reach-warbear
]]

local ByPassMounts = {
    165803,164222,221883,221887,
    221673,221595,221672,221671
}

local ByPassMove = {
    79206,              -- Spiritwalker's Grace
    193223,             -- Surrender to Madness
}

local SpecialUnitVerify = {
    [103679] = { func = function(theUnit) return not UnitIsFriend(theUnit,"player") end },     -- Soul Effigy
    [95887] = { func = function(theUnit)
        return not UnitIsDeadOrGhost(theUnit) and UnitCanAttack("player",theUnit) and XB.Game:GetUnitBuff(theUnit,194323) == nil
    end },     -- Glazer
    [95888] = { func = function(theUnit)
        return not UnitIsDeadOrGhost(theUnit) and UnitCanAttack("player",theUnit) and XB.Game:GetUnitBuff(theUnit,197422) == nil and XB.Game:GetUnitBuff(theUnit,205004) == nil
    end },     -- Cordana Felsong
    [105906] = { func = function(theUnit)
        return not UnitIsDeadOrGhost(theUnit) and UnitCanAttack("player",theUnit) and XB.Game:GetUnitBuff(theUnit,209915) == nil
    end },     -- Eye of Il'gynoth
}

function XB.Checker:ByPassMounts()
    for i=1, #ByPassMounts do
        if XB.Game:GetUnitBuff('player', ByPassMounts[i]) then
            return true
        end
    end
    return false
end

function XB.Checker:ByPassMove()
    for i=1, #ByPassMove do
        if XB.Game:GetUnitBuff('player', ByPassMove[i]) then
            return true
        end
    end
    return false
end

function XB.Checker:IsSafeToAttack(Unit)
    return true
end

function XB.Checker:ShouldStopCasting()
    return false
end

function XB.Checker:IsDummy(Unit)
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
        if not inCombat and IsInInstance() and (threat or (#br.friend == 1 and myTarget)) then return true end
        -- Only consider Units that I have threat with or I can attack and have targeted or are dummies within 20yrds when in Combat.
        if inCombat and (threat or myTarget or (XB.Checker:IsDummy(Unit) and inAggroRange)) then return true end
    end
    return false
end