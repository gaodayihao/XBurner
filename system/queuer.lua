local _, XB               = ...
local GetSpellCooldown     = GetSpellCooldown
local IsUsableSpell        = IsUsableSpell
local GetSpellBookItemInfo = GetSpellBookItemInfo
local UnitExists           = UnitExists
local GetTime              = GetTime

XB.Queuer = {}
local Queue = {}

function XB.Queuer:Add(spell, target)
  if not spell then return end
  Queue[spell] = {
    time = GetTime(),
    target = target or UnitExists('target') and 'target' or 'player'
  }
end

--TODO
function XB.Queuer:Spell(spell)
  -- local skillType = GetSpellBookItemInfo(spell)
  -- local isUsable, notEnoughMana = IsUsableSpell(spell)
  -- if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
  --   local GCD = XB.DSL:Get('gcd')()
  --   if GetSpellCooldown(spell) <= GCD then
  --     return true
  --   end
  -- end
end

function XB.Queuer:Execute()
  -- for spell, v in pairs(Queue) do
  --   if (GetTime() - v.time) > 5 then
  --     Queue[spell] = nil
  --   elseif self:Spell(spell) then
  --     XB.Protected.Cast(spell, v.target)
  --     Queue[spell] = nil
  --     return true
  --   end
  -- end
end

XB.Globals.Queue = XB.Queuer.Add
