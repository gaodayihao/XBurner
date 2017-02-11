local _, XB                     = ...
XB.Game                         = {}
XB.Player                       = {}
local GetSpellBookItemInfo      = GetSpellBookItemInfo
local GetSpellCharges           = GetSpellCharges
local GetSpellCooldown          = GetSpellCooldown
local GetSpellInfo              = GetSpellInfo
local GetTime                   = GetTime
local GetUnitSpeed              = GetUnitSpeed
local IsPlayerSpell             = IsPlayerSpell
local UnitBuff                  = UnitBuff
local UnitDebuff                = UnitDebuff
local UnitExists                = ObjectExists or UnitExists
local UnitGUID                  = UnitGUID
local UnitInParty               = UnitInParty
local UnitInRaid                = UnitInRaid
local UnitIsFriend              = UnitIsFriend
local UnitIsUnit                = UnitIsUnit
local UnitPower                 = UnitPower
local UnitThreatSituation       = UnitThreatSituation

local function UnitBuffL(Target, SpellID, own)
    if Target == nil or not UnitExists(Target) then return nil end
    local spellName = GetSpellInfo(SpellID)
    local name,_,_,stack,_,duration,expires,caster,_,_,_,_,_,_,_,timeMod = UnitBuff(Target, spellName or spellName, nil, own and 'player')
    return name, duration, expires, caster, timeMod, stack
end

local function UnitDebuffL(Target, SpellID, own)
    if Target == nil or not UnitExists(Target) then return nil end
    local spellName = GetSpellInfo(SpellID)
    local name,_,_,stack,_,duration,expires,caster,_,_,_,_,_,_,_,timeMod = UnitDebuff(Target, spellName or spellName, nil, own and 'player')
    return name, duration, expires, caster, timeMod, stack
end

function XB.Game:GetUnitBuffAny(Target,SpellID)
    return UnitBuffL(Target, SpellID)
end

function XB.Game:GetUnitBuff(Target,SpellID)
    return UnitBuffL(Target, SpellID, true)
end

function XB.Game:GetUnitDebuffAny(Target,SpellID)
    return UnitDebuffL(Target, SpellID)
end

function XB.Game:GetUnitDebuff(Target,SpellID)
    return UnitDebuffL(Target, SpellID, true)
end

function XB.Game:IsMoving(Unit)
    if GetUnitSpeed(Unit) > 0 then
        return true
    else
        return false
    end
end

function XB.Game:UnitID(Unit)
    if Unit and UnitExists(Unit) then
        local guid = UnitGUID(Unit)
        if guid then
            local type, _, server_id,_,_, npc_id = strsplit("-", guid)
            if type == "Player" then
                return tonumber(server_id)
            elseif npc_id then
                return tonumber(npc_id)
            end
        end
    end
    return 0
end

function XB.Game:GetUnitPower(Target,powerType)
    local Target = Target or 'player'
    local powerType = powerType or UnitPowerType(Target)
    local amount,max,deficit,percent = 0,0,0,0

    amount = UnitPower(Target,powerType)
    max = UnitPowerMax(Target,powerType)
    deficit = max - amount
    percent = (amount/max)*100

    return amount,max,deficit,percent
end

function XB.Game:GetSpellCD(SpellID)
	if GetSpellCooldown(SpellID) == 0 then
		return 0
	else
		local Start ,CD = GetSpellCooldown(SpellID)
		local MyCD = Start + CD - GetTime()
		return MyCD
	end
end

function XB.Game:IsInRange(SpellID,Unit)
    return LibStub("SpellRange-1.0").IsSpellInRange(SpellID,Unit)
end

function XB.Game:GetCharges(SpellID)
    return select(1,GetSpellCharges(SpellID))
end

function XB.Game:GetChargesFrac(SpellID,chargeMax)
    local charges,maxCharges,start,duration = GetSpellCharges(SpellID)
    if chargeMax == nil then chargeMax = false end
    if maxCharges ~= nil then
        if chargeMax then 
            return maxCharges 
        else
            if start <= GetTime() then
                local endTime = start + duration
                local percentRemaining = 1 - (endTime - GetTime()) / duration
                return charges + percentRemaining
            else
                return charges
            end
        end
    end
    return 0
end

function XB.Game:GetRecharge(SpellID)
    local charges,maxCharges,chargeStart,chargeDuration = GetSpellCharges(SpellID)
    if charges then
        if charges < maxCharges then
            local chargeEnd = chargeStart + chargeDuration
            return chargeEnd - GetTime()
        end
        return 0
    end
end

function XB.Game:IsKnownSpell(SpellID)
    local spellName = GetSpellInfo(SpellID)
    if GetSpellBookItemInfo(spellName) ~= nil then
        return true
    end
    if IsPlayerSpell(tonumber(SpellID)) then
        return true
    end
    return false
end

function XB.Game:GetCastTime(SpellID)
    local castTime = select(4,GetSpellInfo(SpellID))/1000
    return castTime
end

function XB.Game:HasThreat(Unit,PlayerUnit)
    local Unit = Unit or 'target'
    local PlayerUnit = PlayerUnit or 'player'
    if UnitThreatSituation(PlayerUnit,Unit) ~= nil then return true end
    if UnitIsUnit(Unit,'target') and UnitIsEnemy('player','target') and UnitExists('targettarget') and (UnitInParty('targettarget') or UnitInRaid('targettarget')) then return true end
    local friend = XB.Healing:GetRoster()
    for guid,obj in pairs(friend) do
        local thisUnit = friend[guid].key
        if (UnitInParty(thisUnit) or UnitInRaid(thisUnit)) and UnitThreatSituation(thisUnit,Unit)~=nil then
            return true
        end
    end
    return false
end

XB.Globals.Game = XB.Game
XB.Globals.Player = XB.Player