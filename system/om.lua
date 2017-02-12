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
local ObjectIsType              = ObjectIsType or (function(_,type) return type == 1 end)
local ObjectTypes               = ObjectTypes or { Unit = 1,GameObject = 2}

XB.OM = {}

local OM_c = {
    Enemy    = {},
    Friendly = {},
    Dead     = {},
    Objects  = {}
}

function XB.OM:Get(ref)
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
    if ObjectIsType(Obj, ObjectTypes.Unit) then
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
        end
    elseif ObjectIsType(Obj, ObjectTypes.GameObject) then
        XB.OM:Insert(OM_c['Objects'], Obj, GUID)
    end
end

-- Regular
C_Timer.NewTicker(1, (function()
    XB.OM.Maker()
end), nil)

-- Gobals
XB.Globals.OM = {
    Add = XB.OM.Add,
    Get = XB.OM.Get
}
