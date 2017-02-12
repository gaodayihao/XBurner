local _, XB = ...
XB.Runer   = {}

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
    if not SpellID then return false end
    local isChannel = isChannel or false
    if UnitExists(Unit) and not XB.Checker:ShouldStopCasting(SpellID, isChannel) and (not UnitIsDeadOrGhost(Unit) or DeadCheck) then
        -- define local var
        local FacingSkip = FacingSkip or false
        local MovementSkip = MovementSkip or false
        local KnownSkip = KnownSkip or false
        -- we create an usableSkip for some specific spells like hammer of wrath aoe mode
        if usableSkip == nil then usableSkip = false end
        -- stop if not enough power for that spell
        --print(-1)
        if not usableSkip and not IsUsableSpell(SpellID) then return false end
        -- default noCast to false
        if noCast == nil then nocast = false end
        -- make sure it is a known spell
        --print(0)
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
        --print(1)
        -- if MovementSkip is false then we dont check it
        if MovementSkip or not XB.Game:IsMoving("player") or XB.Checker:ByPassMove() or (XB.Game:GetCastTime(SpellID) == 0 and not isChannel) then
            -- print(2)
            -- if ability is ready and in range
            -- if getSpellCD(SpellID) < select(4,GetNetStats()) / 1000
            if (XB.Game:GetSpellCD(SpellID) < select(4,GetNetStats()) / 1000) and (DistanceSkip or XB.Game:IsInRange(SpellID,Unit)) then
            --print(3)
                -- if spam is not allowed
                if SpamAllowed == false then
            --print(4)
                    -- get our last/current cast
                    if TimersTable[SpellID] == nil or TimersTable[SpellID] <= GetTime() -0.6 then
                        if (FacingSkip or XB.Protected.Infront("player",Unit)) and (UnitIsUnit("player",Unit) or XB.Protected.LineOfSight("player",Unit)) then

            --print(5)
                            if noCast then 
                                return true
                            else 
                                TimersTable[SpellID] = GetTime()
                                local spellName = GetSpellInfo(SpellID)
                                XB.Runer.LastCast = SpellID
                                XB.Runer.LastTarget = Unit
                                XB.Interface:UpdateIcon('mastertoggle', SpellID)
                                XB.Protected.Cast(spellName,Unit)
                                if IsAoEPending() then
                                    local X,Y,Z = ObjectPosition(Unit)
                                    ClickPosition(X,Y,Z)
                                end
                                return true
                            end
                        end
                    end
                elseif (FacingSkip or XB.Protected.Infront("player",Unit)) and (UnitIsUnit("player",Unit) or XB.Protected.LineOfSight("player",Unit)) then
                    if noCast then
                        return true
                    else
                        TimersTable[SpellID] = GetTime()
                        local spellName = GetSpellInfo(SpellID)
                        XB.Runer.LastCast = SpellID
                        XB.Runer.LastTarget = Unit
                        XB.Interface:UpdateIcon('mastertoggle', SpellID)
                        XB.Protected.Cast(spellName,Unit)
                        if IsAoEPending() then
                            local X,Y,Z = ObjectPosition(Unit)
                            ClickPosition(X,Y,Z)
                        end
                        return true
                    end
                end
            end
        end
    end
    return false
end

function XB.Runer:Run(exe)
    return exe()
end

-- Delay until everything is ready
XB.Core:WhenInGame(function()

C_Timer.NewTicker(0.1, (function()
    --XB.Faceroll:Hide()
    if XB.Interface:GetToggle('mastertoggle') and not XB.CR.CRChanging then
        if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
            if XB.Checker:BetterStopCasting() then
                SpellStopCasting()
            end
            if XB.Queuer:Execute() then return end
            local exe = XB.CR.CR[InCombatLockdown()]
            XB.Runer:Run(exe)
        end
    end
end), nil)

end, 99)
