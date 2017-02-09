local _, XB                   = ...
XB.Game                       = {}
XB.Player                     = {}
local UnitBuff                = UnitBuff
local UnitDebuff              = UnitDebuff
local UnitExists              = ObjectExists or UnitExists
local GetSpellInfo            = GetSpellInfo
local UnitPower               = UnitPower

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

function XB.Game:UnitBuffAny(target,spellID)
    return UnitBuffL(target, spellID)
end

function XB.Game:UnitBuff(target,spellID)
    return UnitBuffL(target, spellID, true)
end

function XB.Game:UnitDebuffAny(target,spellID)
    return UnitDebuffL(target, spellID)
end

function XB.Game:UnitDebuff(target,spellID)
    return UnitDebuffL(target, spellID, true)
end

function XB.Game:UnitPower(target,powerType)
    local target = target or 'player'
    local powerType = powerType or UnitPowerType(target)
    local amount,max,deficit,percent = 0,0,0,0

    amount = UnitPower(target,powerType)
    max = UnitPowerMax(target,powerType)
    deficit = max - amount
    percent = (amount/max)*100

    return amount,max,deficit,percent
end

XB.Globals.Game = XB.Game
XB.Globals.Player = XB.Player