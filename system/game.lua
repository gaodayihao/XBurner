local _, XB                     = ...
XB.Game                         = {}
local GetSpellBookItemInfo      = GetSpellBookItemInfo
local GetSpellCharges           = GetSpellCharges
local GetSpellCooldown          = GetSpellCooldown
local GetSpellInfo              = GetSpellInfo
local GetTime                   = GetTime
local GetUnitSpeed              = GetUnitSpeed
local IsCurrentSpell            = IsCurrentSpell
local IsPlayerSpell             = IsPlayerSpell
local IsSpellInRange            = IsSpellInRange
local UnitBuff                  = UnitBuff
local UnitDebuff                = UnitDebuff
local UnitExists                = ObjectExists or UnitExists
local UnitGUID                  = UnitGUID
local UnitHealth                = UnitHealth
local UnitHealthMax             = UnitHealthMax
local UnitInParty               = UnitInParty
local UnitInRaid                = UnitInRaid
local UnitIsFriend              = UnitIsFriend
local UnitIsUnit                = UnitIsUnit
local UnitPower                 = UnitPower
local UnitThreatSituation       = UnitThreatSituation
local GetItemSpell              = GetItemSpell
local GetItemCooldown           = GetItemCooldown
local PlayerHasToy              = PlayerHasToy
local GetInventoryItemID        = GetInventoryItemID
local UnitCastingInfo           = UnitCastingInfo
local UnitChannelInfo           = UnitChannelInfo
local UnitTarget                = UnitTarget or (function() return 'player' end)

local ItemSpamDelay             = 0

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
    return false
end

function XB.Game:GetHP(Unit)
    local hp = (UnitHealth(Unit) or 1) / (UnitHealthMax(Unit) or 1) * 100
    return hp
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

function XB.Game:IsSolo()
    return GetNumGroupMembers() == 0
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
    local _,_,_,_,minRange,maxRange = GetSpellInfo(SpellID)
    return IsSpellInRange(GetSpellInfo(SpellID),Unit) == 1 
            or (minRange ~= nil and minRange == 0 and maxRange ~= nil and maxRange == 0) 
            or (minRange ~= nil and XB.Protected.Distance(Unit) >= minRange and maxRange ~= nil and XB.Protected.Distance(Unit) <= maxRange)
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
        if (UnitInParty(thisUnit) or UnitInRaid(thisUnit)) and (UnitThreatSituation(thisUnit,Unit)~=nil or (UnitExists(UnitTarget(Unit)) and UnitIsUnit(UnitTarget(Unit),thisUnit))) then
            return true
        end
    end
    return false
end

function XB.Game:UseItem(ItemID)
    if GetTime() > ItemSpamDelay then
        if ItemID<=19 then
            if GetItemSpell(GetInventoryItemID("player",ItemID))~=nil then 
                local slotItemID = GetInventoryItemID("player",ItemID)
                if GetItemCooldown(slotItemID)==0 then
                    XB.Protected.UseInvItem(ItemID);
                    ItemSpamDelay = GetTime() + 1;
                    return true
                end
            end
        elseif ItemID>19 and (GetItemCount(ItemID) > 0 or PlayerHasToy(ItemID)) then
            if GetItemCooldown(ItemID)==0 then
                XB.Protected.UseItem(GetItemInfo(ItemID));
                ItemSpamDelay = GetTime() + 1;
                return true
            end
        end
    end
    return false
end

function XB.Game:HasEquiped(itemID)
    --Scan Armor Slots to see if specified item was equiped
    local foundItem = false
    for i=1, 19 do
        -- if there is an item in that slot
        if GetInventoryItemID("player", i) ~= nil then
            -- check if it matches 
            if GetInventoryItemID("player", i) == itemID then
                foundItem = true
                break
            end
        end
    end
    return foundItem;
end

function XB.Game:IsAttacking()
    return IsCurrentSpell(6603)
end

function XB.Game:GCD()
    local gcd = (1.5 / ((UnitSpellHaste("player")/100)+1)) --getSpellCD(61304)
    if gcd < 0.75 then
        return 0.75
    else
        return gcd
    end
end

function XB.Game:IsCastingSpell(spellID,unit)
    if unit == nil then unit = "player" end
    local name, _, _, _, _, _, _, _, _, spID = UnitCastingInfo(unit)
    if name == nil then
        name = UnitChannelInfo(unit)
        return name ~=nil and name == GetSpellInfo(spellID)
    end
    if spID == spellID then
        return true
    end
    return false
end

function XB.Game:UseCooldown()
    return XB.Interface:GetToggle('cooldowns') and (XB.Checker:IsBoss() or not XB.Interface:GetToggle('cooldownsonboss'))
end

function XB.Game:UseAoE()
    return XB.Interface:GetToggle('aoe')
end

function XB.Game:IsCasting(unit)
    if unit == nil then unit = "player" end
    local name = UnitCastingInfo(unit)
    if name == nil then
        name = UnitChannelInfo(unit)
    end
    return name ~= nil
end

function XB.Game:HasBloodLust()
    if XB.Game:GetUnitBuff("player",90355)              -- Ancient Hysteria
        or XB.Game:GetUnitBuff("player",2825)           -- Bloodlust
        or XB.Game:GetUnitBuff("player",146555)         -- Drums of Rage
        or XB.Game:GetUnitBuff("player",32182)          -- Heroism
        or XB.Game:GetUnitBuff("player",90355)          -- Netherwinds
        or XB.Game:GetUnitBuff("player",80353)          -- Timewarp
    then
        return true
    else
        return false
    end
end

function XB.Game:GetRace()
    return select(2,UnitRace('player'))
end

function XB.Game:GetRacial()
    local race = XB.Game:GetRace()
    local classEn = select(2, UnitClass("player"))
    local BloodElfRacial = 0
    if race == "BloodElf" then
        if classEn == "WARRIOR" then BloodElfRacial = 69179 end
        if classEn == "MONK" then BloodElfRacial = 129597 end
        if classEn == "MAGE" or self.class == "WARLOCK" then BloodElfRacial = 28730 end
        if classEn == "DEATHKNIGHT" then BloodElfRacial = 50613 end
        if classEn == "HUNTER" then BloodElfRacial = 80483 end
        if classEn == "PALADIN" then BloodElfRacial = 155145 end
        if classEn == "PRIEST" then BloodElfRacial = 232633 end
        if classEn == "ROGUE" then BloodElfRacial = 25046 end
        if classEn == "DEMONHUNTER" then BloodElfRacial = 202719 end
    end
    local racialSpells = {
        -- Alliance
        Dwarf    = 20594, -- Stoneform
        Gnome    = 20589, -- Escape Artist
        Draenei  = 59547, -- Gift of the Naaru
        Human    = 59752, -- Every Man for Himself
        NightElf = 58984, -- Shadowmeld
        Worgen   = 68992, -- Darkflight
        -- Horde
        BloodElf = BloodElfRacial, -- Arcane Torrent
        Goblin   = 69041, -- Rocket Barrage
        Orc      = 20572, -- Blood Fury
        Tauren   = 20549, -- War Stomp
        Troll    = 26297, -- Berserking
        Scourge  = 7744,  -- Will of the Forsaken
        -- Both
        Pandaren = 107079, -- Quaking Palm 
    }
    return racialSpells[race]
end
    
-- XB.Globals.Game = XB.Game
XB.Globals.Game = { 
    UnitID = XB.Game.UnitID,
    IsMoving = XB.Game.IsMoving
}