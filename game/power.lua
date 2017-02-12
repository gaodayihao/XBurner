local _, XB                     = ...
XB.Game.Power                 = {}
local GetTime                   = GetTime
local GetRuneCooldown           = GetRuneCooldown

XB.Core:WhenInGame(function()
    for name,id in pairs(XB.Abilities.PowerList) do
        if id == SPELL_POWER_RUNES then
            XB.Game.Power[name] = function()
                local runeCount = 0
                local next = 0
                for i = 1, 6 do
                    local start, duration, runeReady = GetRuneCooldown(i)
                    if runeReady then 
                        runeCount = runeCount + 1
                    elseif (GetTime() - start)/duration > next then
                        next = (GetTime() - start)/duration
                    end
                end
                
                return {amount = runeCount, max = 6, frac = runeCount + next}
            end
        else
            XB.Game.Power[name] = function()
                local amount,max,deficit,percent = XB.Game:GetUnitPower('player',id)
                return {amount = amount, max = max, deficit = deficit, percent = percent}
            end
        end
    end
end)