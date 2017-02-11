local _, XB = ...

-- Local stuff for speed
local UnitExists                = ObjectExists or UnitExists
local UnitIsDeadOrGhost         = UnitIsDeadOrGhost
local UnitCanAttack             = UnitCanAttack
local UnitIsFriend              = UnitIsFriend
local UnitGUID                  = UnitGUID
local UnitName                  = UnitName
local strsplit                  = strsplit
local select                    = select
local tonumber                  = tonumber
local pairs                     = pairs
local UnitInParty               = UnitInParty
local UnitInRaid                = UnitInRaid
local C_Timer                   = C_Timer

--Advanced
local ObjectIsType = ObjectIsType
local ObjectTypes  = ObjectTypes

XB.OM = {}

local OM_c = {
    Enemy    = {},
    Friendly = {},
    Dead     = {},
    Objects  = {}
}

local nPlates = {
    Friendly = {},
    Enemy = {}
}


-- This cleans/updates the tables and then returns it
-- Due to Generic OM, a unit can still exist (target) but no longer be the same unit,
-- To counter this we compare GUID's.

local function MergeTable(table, Obj, GUID)
    if not table[GUID]
    and UnitExists(Obj.key)
    and GUID == UnitGUID(Obj.key) then
        table[GUID] = Obj
        Obj.distance = XB.Protected.Distance('player', Obj.key)
    end
end

function XB.OM:Get(ref, want_plates)
    -- Hack for nameplates
    if want_plates and nPlates then
        local temp = {}
        for GUID, Obj in pairs(nPlates[ref]) do
            MergeTable(temp, Obj, GUID)
        end
        for GUID, Obj in pairs(OM_c[ref]) do
            MergeTable(temp, Obj, GUID)
        end
        return temp
    -- Normal
    else
        local tb = OM_c[ref]
        for GUID, Obj in pairs(tb) do
            -- remove invalid units
            if not UnitExists(Obj.key)
            or GUID ~= UnitGUID(Obj.key)
            or ref ~= 'Dead' and UnitIsDeadOrGhost(Obj.key) then
                tb[GUID] = nil
            end
        end
        return tb
    end
end

function XB.OM:Insert(Tbl, Obj, GUID)
    -- Dont add existing Objs (Update)
    local Test = Tbl[GUID]
    if not Test then
        local distance = XB.Protected.Distance('player', Obj)
        Tbl[GUID] = {
            key = Obj,
            name = UnitName(Obj),
            id = XB.Game:UnitID(Obj) or 0,
            guid = GUID
        }
    end
end

function XB.OM:Add(Obj)
    if not UnitExists(Obj) then return end
    local GUID = UnitGUID(Obj) or '0'
    -- Dead Units
    if UnitIsDeadOrGhost(Obj) then
        XB.OM:Insert(OM_c['Dead'], Obj, GUID)
    -- Friendly
    elseif UnitIsFriend('player', Obj) then
        XB.OM:Insert(OM_c['Friendly'], Obj, GUID)
    -- Enemie
    elseif UnitCanAttack('player', Obj) then
        XB.OM:Insert(OM_c['Enemy'], Obj, GUID)
    -- Objects
    elseif ObjectIsType and ObjectIsType(Obj, ObjectTypes.GameObject) then
        XB.OM:Insert(OM_c['Objects'], Obj, GUID)
    end
end

-- Regular
C_Timer.NewTicker(1, (function()
    XB.OM.Maker()
end), nil)

-- Nameplates (This gets killed once advanced)
C_Timer.NewTicker(1, (function(self)
    if not XB.AdvancedOM then
        wipe(nPlates.Friendly)
        wipe(nPlates.Enemy)
        for i=1, 40 do
            local Obj = 'nameplate'..i
            if UnitExists(Obj) then
                local GUID = UnitGUID(Obj) or '0'
                if UnitIsFriend('player',Obj) then
                    XB.OM:Insert(nPlates['Friendly'], Obj, GUID)
                else
                    XB.OM:Insert(nPlates['Enemy'], Obj, GUID)
                end
            end
        end
    -- remove nameplates when advanced
    elseif nPlates then
        nPlates = nil
        self:Cancel()
    end
end), nil)

-- Gobals
XB.Globals.OM = {
    Add = XB.OM.Add,
    Get = XB.OM.Get
}
