local _, XB     = ...
XB.Core         = {}
XB.Globals.Core = XB.Core

-- Locals for speed
local BOOKTYPE_PET         = BOOKTYPE_PET
local BOOKTYPE_SPELL       = BOOKTYPE_SPELL
local GetFlyoutID          = GetFlyoutID
local GetFlyoutInfo        = GetFlyoutInfo
local GetFlyoutSlotInfo    = GetFlyoutSlotInfo
local GetItemInfo          = GetItemInfo
local GetNumFlyouts        = GetNumFlyouts
local GetSpellBookItemName = GetSpellBookItemName
local GetSpellInfo         = GetSpellInfo
local GetSpellTabInfo      = GetSpellTabInfo
local HasPetSpells         = HasPetSpells
local strsplit             = strsplit
local UnitClass            = UnitClass
local UnitExists           = ObjectExists or UnitExists
local UnitGUID             = UnitGUID

function XB.Core:Print(...)
    print('[|cff'..XB.Color..'XB|r]', ...)
end

local d_color = {
    hex = 'FFFFFF',
    rgb = {1,1,1}
}

function XB.Core:ClassColor(unit, type)
    type = type and type:lower() or 'hex'
    if UnitExists(unit) then
        local classid  = select(3, UnitClass(unit))
        if classid then
            return XB.ClassTable[classid][type]
        end
    end
    return d_color[type]
end

function XB.Core:Round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function XB.Core:GetSpellID(spell)
    local _type = type(spell)
    if not spell then
        return
    elseif _type == 'string' and spell:find('^%d') then
        return tonumber(spell)
    end
    local index, stype = XB.Core:GetSpellBookIndex(spell)
    local spellID = select(7, GetSpellInfo(index, stype))
    return spellID or spell
end

function XB.Core:GetSpellName(spell)
    if not spell or type(spell) == 'string' then return spell end
    local spellID = tonumber(spell)
    if spellID then
        return GetSpellInfo(spellID)
    end
    return spell
end

function XB.Core:GetItemID(item)
    if not item or type(item) == 'number' then return item end
    local itemID = string.match(select(2, GetItemInfo(item)) or '', 'Hitem:(%d+):')
    return tonumber(itemID) or item
end

function XB.Core:MergeTables(a, b)
	if a == nil then a = {} end
    if type(a) == 'table' and type(b) == 'table' then
        for k,v in pairs(b) do 
        	if type(v)=='table' and type(a[k] or false)=='table' then
        		XB.Core:MergeTables(a[k],v) 
        	else
        		a[k]=v 
        	end 
        end
    end
    return a
end

function XB.Core:GetSpellBookIndex(spell)
    local spellName = XB.Core:GetSpellName(spell)
    if not spellName then return end
    spellName = spellName:lower()

    for t = 1, 2 do
        local _, _, offset, numSpells = GetSpellTabInfo(t)
        for i = 1, (offset + numSpells) do
            if GetSpellBookItemName(i, BOOKTYPE_SPELL):lower() == spellName then
                return i, BOOKTYPE_SPELL
            end
        end
    end

    local numFlyouts = GetNumFlyouts()
    for f = 1, numFlyouts do
        local flyoutID = GetFlyoutID(f)
        local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID)
        if isKnown and numSlots > 0 then
            for g = 1, numSlots do
                local spellID, _, isKnownSpell = GetFlyoutSlotInfo(flyoutID, g)
                local name = XB.Core:GetSpellName(spellID)
                if name and isKnownSpell and name:lower() == spellName then
                    return spellID, nil
                end
            end
        end
    end

    local numPetSpells = HasPetSpells()
    if numPetSpells then
        for i = 1, numPetSpells do
            if string.lower(GetSpellBookItemName(i, BOOKTYPE_PET)) == spellName then
                return i, BOOKTYPE_PET
            end
        end
    end
end

local Run_Cache = {}
function XB.Core:WhenInGame(func, prio)
    if Run_Cache then
        Run_Cache[#Run_Cache+1] = {func = func, prio = prio or 10}
        table.sort(Run_Cache, function(a,b) return a.prio < b.prio end)
    else
        func()
    end
end

XB.Listener:Add("XB_CR2", "PLAYER_LOGIN", function()
    XB.Color = XB.Core:ClassColor('player', 'hex')
    for i=1, #Run_Cache do
        Run_Cache[i].func()
    end
    Run_Cache = nil
end)