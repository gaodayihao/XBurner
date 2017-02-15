local _, XB                     = ...
XB.Area                         = {}
local C_Timer                   = C_Timer
local wipe                      = wipe
local UnitHealth                = UnitHealth
local UnitExists                = ObjectExists or UnitExists

local Cache = {}

C_Timer.NewTicker(1, (function()
    wipe(Cache)
end), nil)

function XB.Area:Enemies(distance,Unit,infront)
    local distance = distance or 40
    local Unit = Unit or 'player'
    local infront = infront or false
    local guid = UnitGUID(Unit)

    if not UnitExists(Unit) then return {} end

    if Cache[guid] and Cache[guid][distance] and Cache[guid][distance][infront] then
        table.sort(Cache[guid][distance][infront], function(a,b) return UnitHealth(a.key) > UnitHealth(b.key) end)
        return Cache[guid][distance][infront]
    end

    if not Cache[guid] then Cache[guid] = {} end
    if not Cache[guid][distance] then  Cache[guid][distance] = {} end
    Cache[guid][distance][infront] = {}

    for _, Obj in pairs(XB.OM:Get('Enemy')) do
        if XB.Checker:IsValidEnemy(Obj.key) and (not infront or XB.Protected.Infront(Unit,Obj.key)) and XB.Protected.Distance(Unit,Obj.key) <= distance then
            table.insert(Cache[guid][distance][infront], Obj)
        end
    end
    table.sort(Cache[guid][distance][infront], function(a,b) return UnitHealth(a.key) > UnitHealth(b.key) end)
    return Cache[guid][distance][infront]
end

function XB.Area:EnemiesT(distance,infront)
    return XB.Area:Enemies(distance,'target',infront)
end

function XB.Area:Debuff(SpellID,Any)
    local Any = Any or false
    local enemies = XB.Area:Enemies()
    local count = 0
    for i=1,#enemies do
        local enemy = enemies[i]
        if Any and XB.Game:GetUnitDebuffAny(enemy,SpellID) then
            count = count + 1
        elseif not Any and XB.Game:GetUnitDebuff(enemy,SpellID) then
            count = count + 1
        end
    end
    return count
end