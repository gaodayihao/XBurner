local _, XB                     = ...
XB.Area                         = {}
local C_Timer                   = C_Timer
local wipe                      = wipe

local Cache = {}

C_Timer.NewTicker(1, (function()
    wipe(Cache)
end), nil)

function XB.Area:Enemies(distance,Unit,infront)
    local Unit = Unit or 'player'
    local distance = distance or 40
    local infront = infront or false
    local guid = UnitGUID(Unit)

    if Cache[guid] and Cache[guid][distance] and Cache[guid][distance][infront] then
        return Cache[guid][distance][infront]
    end

    if not Cache[guid] then Cache[guid] = {} end
    if not Cache[guid][distance] then  Cache[guid][distance] = {} end
    Cache[guid][distance][infront] = {}

    for _, Obj in pairs(NeP.OM:Get('Enemy')) do
        if XB.Checker:IsValidEnemy(Obj) and (not infront or XB.Protected.Infront(Unit,Obj)) and XB.Protected.Distance(Unit,Obj) <= distance then
            table.insert( Cache[guid][distance][infront], Obj )
        end
    end
    return Cache[guid][distance][infront]
end

function XB.Area:EnemiesT(distance,infront)
    return XB.Area:Enemies(distance,'target',infront)
end