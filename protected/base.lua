local _, XB        = ...
local IsInRaid           = IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local IsInGroup          = IsInGroup

XB.Protected.Cast = function(spell, target)
  XB.Faceroll:Set(spell, target)
end

XB.Protected.CastGround = function(spell, target)
  XB.Faceroll:Set(spell, target)
end

XB.Protected.Macro = function()
end

XB.Protected.UseItem = function()
end

XB.Protected.UseInvItem = function()
end

local rangeCheck = LibStub("LibRangeCheck-2.0")
XB.Protected.Distance = function(_, b)
  local minRange, maxRange = rangeCheck:GetRange(b)
  return maxRange or minRange
end

XB.Protected.Infront = function(_,b)
  return true
end

XB.Protected.UnitCombatRange = function(_,b)
  local minRange = rangeCheck:GetRange(b)
  return minRange
end

XB.Protected.LineOfSight = function(_,b)
  return true
end

local ValidUnits = {'player', 'mouseover', 'target', 'arena1', 'arena2', 'focus', 'pet'}
XB.OM.Maker = function()
  -- If in Group scan frames...
  if IsInGroup() or IsInRaid() then
    local prefix = (IsInRaid() and 'raid') or 'party'
    for i = 1, GetNumGroupMembers() do
      local object = prefix..i
      XB.OM:Add(object)
      XB.OM:Add(object..'target')
    end
  end
  -- Valid Units
  for i=1, #ValidUnits do
    local object = ValidUnits[i]
    XB.OM:Add(object)
    XB.OM:Add(object..'target')
  end
end
