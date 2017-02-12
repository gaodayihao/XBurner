local _, XB                     = ...
XB.Game.Talent                  = {}
local GetSpecialization         = GetSpecialization
local GetSpecializationInfo     = GetSpecializationInfo
local UnitClass                 = UnitClass
local GetTalentInfo             = GetTalentInfo
local GetActiveSpecGroup        = GetActiveSpecGroup

local function BuildTalent()
    local classIndex = select(3,UnitClass('player'))
    local spec = GetSpecializationInfo(GetSpecialization())
    local talents = XB.Abilities:GetTalentsTable(classIndex,spec)

    local tempTalents = {}
    for r = 1, 7 do --search each talent row
        for c = 1, 3 do -- search each talent column
        -- Cache Talent IDs for talent checks
            local _,_,_,selected,_,talentID = GetTalentInfo(r,c,GetActiveSpecGroup())
            table.insert(tempTalents,talentID,selected)
        end
    end
    wipe(XB.Game.Talent)
    for name, spellID in pairs(talents) do
        XB.Game.Talent[name] = {
            enable = not not tempTalents[spellID]
        }
    end
end

XB.Core:WhenInGame(function () 
    BuildTalent()
    
    XB.Listener:Add('XB_Talent','PLAYER_TALENT_UPDATE', function()
        BuildTalent()
    end)
end,20)
