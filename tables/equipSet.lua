local _, XB                 = ...

local UnitClass             = UnitClass
local GetInventoryItemID    = GetInventoryItemID

XB.EquipSet = {
    ["T19"] = {
        ["WARRIOR"] = {  -- Warrior
            [1]  = 138357, -- head
            [5]  = 138351, -- chest
            [3]  = 138363, -- shoulder
            [10] = 138354, -- hands
            [7]  = 138360, -- legs
            [15] = 138374, -- back
        },
        ["PALADIN"] = {  -- Paladin
            [1]  = 138356, -- head
            [5]  = 138350, -- chest
            [3]  = 138362, -- shoulder
            [10] = 138353, -- hands
            [7]  = 138359, -- legs
            [15] = 138369, -- back
        },
        ["HUNTER"] = { -- Hunter
            [1]  = 138342, -- head
            [5]  = 138339, -- chest
            [3]  = 138347, -- shoulder
            [10] = 138340, -- hands
            [7]  = 138344, -- legs
            [15] = 138368, -- back
        },
        ["ROGUE"] = { -- Rogue
            [1]  = 138332, -- head
            [5]  = 138326, -- chest
            [3]  = 138338, -- shoulder
            [10] = 138329, -- hands
            [7]  = 138335, -- legs
            [15] = 138371, -- back
        },
        ["PRIEST"] = {  -- Priest
            [1]  = 138313, -- head
            [5]  = 138319, -- chest
            [3]  = 138322, -- shoulder
            [10] = 138310, -- hands
            [7]  = 138316, -- legs
            [15] = 138370, -- back
        },
        ["DEATHKNIGHT"] = { -- DeathKnight
            [1]  = 138355, -- head
            [5]  = 138349, -- chest
            [3]  = 138361, -- shoulder
            [10] = 138352, -- hands
            [7]  = 138358, -- legs
            [15] = 138364, -- back
        },
        ["SHAMAN"] = {  -- Shaman
            [1]  = 138343, -- head
            [5]  = 138346, -- chest
            [3]  = 138348, -- shoulder
            [10] = 138341, -- hands
            [7]  = 138345, -- legs
            [15] = 138372, -- back
        },
        ["MAGE"] = {  -- Mage
            [1]  = 138312, -- head
            [5]  = 138318, -- chest
            [3]  = 138321, -- shoulder
            [10] = 138309, -- hands
            [7]  = 138315, -- legs
            [15] = 138365, -- back
        },
        ["WARLOCK"] = { -- Warlock
            [1]  = 138314, -- head
            [5]  = 138320, -- chest
            [3]  = 138323, -- shoulder
            [10] = 138311, -- hands
            [7]  = 138317, -- legs
            [15] = 138373, -- back
        },
        ["MONK"] = { -- Monk
            [1]  = 138331, -- head
            [5]  = 138325, -- chest
            [3]  = 138337, -- shoulder
            [10] = 138328, -- hands
            [7]  = 138334, -- legs
            [15] = 138367, -- back
        },
        ["DRUID"] = { -- Druid
            [1]  = 138330, -- head
            [5]  = 138324, -- chest
            [3]  = 138336, -- shoulder
            [10] = 138327, -- hands
            [7]  = 138333, -- legs
            [15] = 138366, -- back
        },
        ["DEMONHUNTER"] = { -- Demon Hunter
            [1]  = 138378, -- head
            [5]  = 138376, -- chest
            [3]  = 138380, -- shoulder
            [10] = 138377, -- hands
            [7]  = 138379, -- legs
            [15] = 138375, -- back
        },
    },
}

function XB.EquipSet:TierScan(thisTier)
    local equippedItems = 0;
    local _, classEnglishName, _ = UnitClass('player')
    local thisTier = string.upper(thisTier);
    if XB.EquipSet[thisTier] and XB.EquipSet[thisTier][classEnglishName] then
        for k,v in pairs(XB.EquipSet[thisTier][classEnglishName]) do
            if GetInventoryItemID('player', k) == v then
                equippedItems = equippedItems + 1;
            end
        end
    end
    return equippedItems;
end