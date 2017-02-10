local _, XB                     = ...
XB.Game                         = {}
XB.Player                       = {}
local GetSpellCharges           = GetSpellCharges
local GetSpellCooldown          = GetSpellCooldown
local GetSpellInfo              = GetSpellInfo
local GetTime                   = GetTime
local UnitBuff                  = UnitBuff
local UnitDebuff                = UnitDebuff
local UnitExists                = ObjectExists or UnitExists
local UnitPower                 = UnitPower

local function UnitBuffL(target, spellID, own)
    if target == nil or not UnitExists(target) then return nil end
    local spellName = GetSpellInfo(spellID)
    local name,_,_,count,_,duration,expires,caster,_,_,_,_,_,_,_,timeMod = UnitBuff(target, spellName or spellName, nil, own and 'player')
    return name, duration, expires, caster, timeMod
end

local function UnitDebuffL(target, spellID, own)
    if target == nil or not UnitExists(target) then return nil end
    local spellName = GetSpellInfo(spellID)
    local name,_,_,count,_,duration,expires,caster,_,_,_,_,_,_,_,timeMod = UnitDebuff(target, spellName or spellName, nil, own and 'player')
    return name, duration, expires, caster, timeMod
end

function XB.Game:GetUnitBuffAny(target,spellID)
    return UnitBuffL(target, spellID)
end

function XB.Game:GetUnitBuff(target,spellID)
    return UnitBuffL(target, spellID, true)
end

function XB.Game:GetUnitDebuffAny(target,spellID)
    return UnitDebuffL(target, spellID)
end

function XB.Game:GetUnitDebuff(target,spellID)
    return UnitDebuffL(target, spellID, true)
end

function XB.Game:GetUnitPower(target,powerType)
    local target = target or 'player'
    local powerType = powerType or UnitPowerType(target)
    local amount,max,deficit,percent = 0,0,0,0

    amount = UnitPower(target,powerType)
    max = UnitPowerMax(target,powerType)
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

function XB.Game:GetCharges(spellID)
    return select(1,GetSpellCharges(spellID))
end

function XB.Game:GetChargesFrac(spellID,chargeMax)
    local charges,maxCharges,start,duration = GetSpellCharges(spellID)
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

function XB.Game:GetRecharge(spellID)
    local charges,maxCharges,chargeStart,chargeDuration = GetSpellCharges(spellID)
    if charges then
        if charges < maxCharges then
            local chargeEnd = chargeStart + chargeDuration
            return chargeEnd - GetTime()
        end
        return 0
    end
end

XB.Globals.Game = XB.Game
XB.Globals.Player = XB.Player