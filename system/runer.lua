local n_name, XB = ...
XB.Runer   = {}

local WaitStart                 = 0
local Wait                      = 0
local Delay                     = 0

-- Local stuff for speed
local C_Timer                   = C_Timer
local GetNetStats               = GetNetStats
local GetNetStats               = GetNetStats
local GetSpellInfo              = GetSpellInfo
local GetTime                   = GetTime
local InCombatLockdown          = InCombatLockdown
local IsUsableSpell             = IsUsableSpell
local SecureCmdOptionParse      = SecureCmdOptionParse
local TimersTable               = {}
local UnitBuff                  = UnitBuff
local UnitCanAttack             = UnitCanAttack
local UnitExists                = ObjectExists or UnitExists
local UnitGUID                  = UnitGUID
local UnitIsDeadOrGhost         = UnitIsDeadOrGhost
local UnitIsFriend              = UnitIsFriend
local UnitIsUnit                = UnitIsUnit
local GetSpellInfo              = GetSpellInfo
local SpellStopCasting          = SpellStopCasting
local UnitAffectingCombat       = UnitAffectingCombat

-- Advanced APIs
local ClickPosition             = ClickPosition or (function() end)
local IsAoEPending              = IsAoEPending or (function() return false end)
local ObjectPosition            = ObjectPosition or (function() return 0,0,0 end)

local function IsMountedCheck()
    if XB.Checker:ByPassMounts() then
        return true
    end
    return (SecureCmdOptionParse("[overridebar][vehicleui][possessbar,@vehicle,exists][mounted]true")) ~= "true"
end

local TargetUnit = function(Unit)
    if XB.Unlocked then
        TargetUnit(Unit)
    end
end

--[[CastSpell(Unit,SpellID,FacingSkip,MovementSkip,SpamAllowed,KnownSkip)
Parameter       Value
First           UnitID              Enter valid UnitID
Second          SpellID             Enter ID of spell to use
Third           Facing              True to allow 360 degrees,false to use facing check
Fourth          MovementSkip       True to make sure player is standing to cast,false to allow cast while moving
Fifth           SpamAllowed         True to skip that check,false to prevent spells that we dont want to spam from beign recast for 1 second
Sixth           KnownSkip           True to skip isKnown check for some spells that are not managed correctly in wow's spell book.
Seventh         DeadCheck           True to skip checking for dead units. (IE: Resurrection Spells)
Eigth           DistanceSkip        True to skip range checking.
Ninth           usableSkip          True to skip usability checks.
Tenth           noCast              True to return True/False instead of casting spell.
eleventh        isChannel           该技能为引导技能，主要影响自动打断施法
]]
-- CastSpell("target",12345,true)
--                         ( 1  ,    2  ,     3    ,     4      ,      5    ,   6     ,   7     ,    8       ,   9      ,  10  ,    11   )
function XB.Runer:CastSpell(Unit,SpellID,FacingSkip,MovementSkip,SpamAllowed,KnownSkip,DeadCheck,DistanceSkip,usableSkip,noCast,isChannel)
    if not SpellID or not Unit then return false end
    local isChannel = isChannel or false
    if UnitExists(Unit) and not XB.Checker:ShouldStopCasting(SpellID, isChannel) and (not UnitIsDeadOrGhost(Unit) or DeadCheck) then
        -- define local var
        local FacingSkip = FacingSkip or false
        local MovementSkip = MovementSkip or false
        local KnownSkip = KnownSkip or false
        -- we create an usableSkip for some specific spells like hammer of wrath aoe mode
        if usableSkip == nil then usableSkip = false end
        -- stop if not enough power for that spell
        if not usableSkip and not IsUsableSpell(SpellID) then return false end
        -- default noCast to false
        if noCast == nil then nocast = false end
        -- make sure it is a known spell
        if not (KnownSkip or XB.Game:IsKnownSpell(SpellID)) then return false end
        if SpamAllowed == nil then SpamAllowed = false end
        if DistanceSkip == nil then DistanceSkip = false end
        -- Check unit,if it's player then we can skip facing
        if (Unit == nil or UnitIsUnit("player",Unit)) or -- Player
            (Unit ~= nil and UnitIsFriend("player",Unit)) or
            XB.Protected.IsHackEnabled("AlwaysFacing") then  -- Ally
            FacingSkip = true
        elseif not XB.Checker:IsSafeToAttack(Unit) then -- enemy
            return false
        end
        local castTime = XB.Game:GetCastTime(SpellID)
        -- if MovementSkip is false then we dont check it
        if MovementSkip or not XB.Game:IsMoving("player") or XB.Checker:ByPassMove() or (castTime == 0 and not isChannel) then
            -- if ability is ready and in range
            -- if getSpellCD(SpellID) < select(4,GetNetStats()) / 1000
            if (XB.Game:GetSpellCD(SpellID) < select(4,GetNetStats()) / 1000) and (DistanceSkip or XB.Game:IsInRange(SpellID,Unit)) then
                -- if spam is not allowed
                if not SpamAllowed then
                    -- get our last/current cast
                    if TimersTable[SpellID] == nil or TimersTable[SpellID] <= GetTime() -0.6 then
                        if (FacingSkip or XB.Protected.Infront("player",Unit)) and (UnitIsUnit("player",Unit) or XB.Protected.LineOfSight("player",Unit)) then
                            if noCast then 
                                return true
                            else 
                                TimersTable[SpellID] = GetTime()
                                XB.Runer.LastCast = SpellID
                                XB.Runer.LastTarget = Unit
                                XB.Interface:UpdateIcon('mastertoggle', SpellID)
                                XB.Protected.Cast(GetSpellInfo(SpellID),Unit)
                                if IsAoEPending() then
                                    local X,Y,Z = ObjectPosition(Unit)
                                    ClickPosition(X,Y,Z)
                                end
                                if castTime > 0 then XB.Runer:Delay() end
                                return true
                            end
                        end
                    end
                elseif (FacingSkip or XB.Protected.Infront("player",Unit)) and (UnitIsUnit("player",Unit) or XB.Protected.LineOfSight("player",Unit)) then
                    if noCast then
                        return true
                    else
                        TimersTable[SpellID] = GetTime()
                        XB.Runer.LastCast = SpellID
                        XB.Runer.LastTarget = Unit
                        XB.Interface:UpdateIcon('mastertoggle', SpellID)
                        XB.Protected.Cast(GetSpellInfo(SpellID),Unit)
                        if IsAoEPending() then
                            local X,Y,Z = ObjectPosition(Unit)
                            ClickPosition(X,Y,Z)
                        end
                        if castTime > 0 then XB.Runer:Delay() end
                        return true
                    end
                end
            end
        end
    end
    return false
end


function XB.Runer:CastGroundAtBestLocation(spellID, radius, minUnits, maxRange, minRange, spellType)
    -- begin
    if minRange == nil then minRange = 0 end
    local allUnitsInRange = {}
    -- Make function usable between enemies and friendlies
    local unitTable = XB.OM:Get(spellType)
    -- fill allUnitsInRange with data from enemiesEngine/healingEngine
    --Print("______________________1")
    -- for i=1,#unitTable do
    for k, v in pairs(unitTable) do
        local thisUnit = unitTable[k].key
        local thisDistance = XB.Protected.Distance(thisUnit)
        local hasThreat = XB.Checker:IsValidEnemy(thisUnit) or UnitIsFriend(thisUnit,"player")
        --Print(thisUnit.." - "..thisDistance)
        if thisDistance < maxRange and thisDistance >= minRange and hasThreat then
            --Print("distance passed")
            if not UnitIsDeadOrGhost(thisUnit) 
                and (XB.Protected.Infront("player",thisUnit) or UnitIsUnit(thisUnit,"player")) 
                and XB.Protected.LineOfSight(thisUnit) 
                and not XB.Game:IsMoving(thisUnit)
            then
                --Print("ghost passed")
                if UnitAffectingCombat(thisUnit) or (spellType == "Friendly" and XB.Game:GetHP(thisUnit) < 100) or XB.Checker:IsDummy(thisUnit) then
                    --Print("combat and dummy passed")
                    table.insert(allUnitsInRange,thisUnit)
                end
            end
        end
    end
    -- check units in allUnitsInRange against each them
    --Print("______________________2")
    local goodUnits = {}
    for i=1,#allUnitsInRange do
        local thisUnit = allUnitsInRange[i]
        local unitsAroundThisUnit = {}
        --Print("units around "..thisUnit..":")
        for j=1,#allUnitsInRange do
            local checkUnit = allUnitsInRange[j]
            --Print(checkUnit.."?")
            if XB.Protected.Distance(thisUnit,checkUnit) < radius then
                --Print(checkUnit.." added")
                table.insert(unitsAroundThisUnit,checkUnit)
            end
        end
        if #goodUnits <= #unitsAroundThisUnit then
            --Print("units around check: "..#unitsAroundThisUnit.." >= "..#goodUnits)
            if tonumber(minUnits) <= #unitsAroundThisUnit then
                --Print("enough units around: "..#unitsAroundThisUnit)
                goodUnits = unitsAroundThisUnit
            end
        end
    end
    -- where to cast
    --Print("______________________3")
    if #goodUnits > 0 then
        --Print("goodUnits > 0")
        if #goodUnits > 1 then
            --Print("goodUnits > 1")
            local mX, mY,mZ = 0,0,0
            for i=1,#goodUnits do
                local thisUnit = goodUnits[i]
                local thisX,thisY,thisZ = ObjectPosition(thisUnit)
                if mX == 0 or mY == 0 or mZ == 0 then
                    mX,mY,mZ = thisX,thisY,thisZ
                else
                    mX = 0.5*(mX + thisX)
                    mY = 0.5*(mY + thisY)
                    mZ = 0.5*(mZ + thisZ)
                end
            end
            --Print(mX.." "..mY.." "..mZ)
            if mX ~= 0 and mY ~= 0 and mZ ~= 0 then
                local spellName = GetSpellInfo(SpellID)
                XB.Runer.LastCast = SpellID
                XB.Interface:UpdateIcon('mastertoggle', SpellID)
                XB.Protected.Cast(spellName,Unit)
                ClickPosition(mX,mY,mZ)
                return true
            end
        else
            local thisX,thisY,thisZ = ObjectPosition(goodUnits[1])
            local spellName = GetSpellInfo(SpellID)
            XB.Runer.LastCast = SpellID
            XB.Interface:UpdateIcon('mastertoggle', SpellID)
            XB.Protected.Cast(spellName,Unit)
            ClickPosition(thisX,thisY,thisZ);
            return true
        end
    end
    return false
end

function XB.Runer:Wait(wait)
    local wait = wait or XB.Game:GCD()
    WaitStart = GetTime()
    Wait = wait
end

function XB.Runer:Delay(delay)
    local delay = delay or 1
    Delay = delay
end

function XB.Runer:Run(exe)
    if XB.CR.CR.range > 0 and XB.Config:Read(n_name..'_Settings', 'at', true) then
        if InCombatLockdown() and not XB.Checker:IsValidEnemy('target') and not UnitIsFriend('player','target') then
            local enemies = XB.Area:Enemies(XB.CR.CR.range)
            local enemy = nil
            for i = 1,#enemies do
                if XB.Runer.LastTarget and not UnitIsUnit(enemies[i].key,XB.Runer.LastTarget) or not XB.Runer.LastTarget then
                    enemy = enemies[i].key
                    break
                end
            end
            if enemy then
                TargetUnit(enemy)
            end
        end
    end
    if XB.CR.CR.pause() then return end
    if XB.Queuer:Execute() then return end
    return exe()
end

-- Delay until everything is ready
XB.Core:WhenInGame(function()

C_Timer.NewTicker(0.1, (function()
    --XB.Faceroll:Hide()
    if Delay > 0 then
        if not XB.Game:IsCasting() then Delay = Delay - 1 end
        return
    end
    if WaitStart + Wait >= GetTime() then
        return
    end
    if XB.Interface:GetToggle('mastertoggle') and not XB.CR.CRChanging and not IsAoEPending() then
        if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
            if XB.Checker:BetterStopCasting() then
                SpellStopCasting()
            end
            local exe = XB.CR.CR[InCombatLockdown()]
            XB.Runer:Run(exe)
        end
    end
end), nil)

end, 99)
