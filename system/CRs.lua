local _, XB                 = ...
XB.CR                       = {}
XB.CR.CRChanging            = false
XB.CR.CR                    = {}
local CRs                   = {}
local UnitClass             = UnitClass
local GetSpecialization     = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local noop                  = function() end
local ActiveSpec            = 0

function XB.CR:AddGUI(key, eval)
    local temp = {
        title = key,
        key = key,
        width = 200,
        height = 300,
        config = eval
    }
    XB.Interface:BuildGUI(temp):Hide()
    XB.Interface:AddCR_ST(key)
end

function XB.CR:UI(key)
    return XB.Config:Read(XB.CR.CR.Name,key)
end

function XB.CR:Add(SpecID, ...)
    local classIndex = select(3, UnitClass('player'))
    -- This only allows crs we can use to be registered
    if XB.ClassTable[classIndex][SpecID] or classIndex == SpecID then

        -- if no table for the spec, create it
        if not CRs[SpecID] then
            CRs[SpecID] = {}
        end

        -- Legacy stuff
        local ev, InCombat, OutCombat, ExeOnLoad, GUI, ExeOnUnLoad, Pause = ...
        if type(...) == 'string' then
            ev = {
                name = ev,
                ic = InCombat,
                ooc = OutCombat,
                load = ExeOnLoad,
                gui = GUI,
                unload = ExeOnUnLoad,
                pause = Pause
            }
        else
            ev = ...
        end

        -- do not load cr that dont have names
        if not ev.name then error('Tried to load a CR whitout and name') end

        -- This compiles the CR
        -- XB.Compiler:Iterate(ev.ic, ev.name)
        -- XB.Compiler:Iterate(ev.ooc, ev.name)

        --Create user GUI
        if ev.gui then XB.CR:AddGUI(ev.name, ev.gui) end

        -- store some ref to the crs
        CRs[SpecID][ev.name] = {}
        CRs[SpecID][ev.name].Name = ev.name
        CRs[SpecID][ev.name].load = ev.load or noop
        CRs[SpecID][ev.name].unload = ev.unload or noop
        CRs[SpecID][ev.name].pause = ev.pause or (function() return false end)
        CRs[SpecID][ev.name][true] = ev.ic or noop
        CRs[SpecID][ev.name][false] = ev.ooc or noop
    end
end

function XB.CR:Set(Spec, Name)
    if self.CR.unload then
        self.CR.unload()
    end
    local _, englishClass, classIndex  = UnitClass('player')
    local a, b = englishClass:sub(1, 1):upper(), englishClass:sub(2):lower()
    local classCR = '[XB] '..a..b..' - Basic'
    if not CRs[Spec] or not CRs[Spec][Name] then
        Name = classCR
        Spec = classIndex
    end
    self.CR = CRs[Spec][Name]
    XB.Config:Write('SELECTED', Spec, Name)
    XB.Interface:SetCheckedCR(Name)
    XB.Interface:ResetToggles()
    self.CR.load()
end

function XB.CR:GetList(Spec)
    local result = {}
    local classIndex = select(3, UnitClass('player'))
    if CRs[Spec] then
        for k in pairs(CRs[Spec]) do
            result[#result+1] = k
        end
    end
    for k in pairs(CRs[classIndex]) do
        result[#result+1] = k
    end
    return result
end

local function BuildCRs(Spec, Last)
    local CrList = XB.CR:GetList(Spec)
    for i=1, #CrList do
        local Name = CrList[i]
        XB.Interface:AddCR(Spec, Name, (Name == Last))
    end
end

local function SetCR()
    local Spec = ActiveSpec
    local englishClass  = select(2, UnitClass('player'))
    local a, b = englishClass:sub(1, 1):upper(), englishClass:sub(2):lower()
    local classCR = '[XB] '..a..b..' - Basic'
    local last = XB.Config:Read('SELECTED', Spec, classCR)
    BuildCRs(Spec, last)
    XB.CR:Set(Spec, last)
end

XB.Core:WhenInGame(function()
    ActiveSpec = GetSpecializationInfo(GetSpecialization())
    SetCR()
end)

local Run_Cache = {}
function XB.CR:WhenChangingCR(func, prio)
    Run_Cache[#Run_Cache+1] = {func = func, prio = prio or 10}
    table.sort(Run_Cache, function(a,b) return a.prio < b.prio end)
end

XB.Listener:Add("XB_CR", "PLAYER_SPECIALIZATION_CHANGED", function(unitID)
    if unitID ~= 'player' or ActiveSpec == GetSpecializationInfo(GetSpecialization()) then return end
    XB.CR.CRChanging = true
    for i=1, #Run_Cache do
        Run_Cache[i].func()
    end
    ActiveSpec = GetSpecializationInfo(GetSpecialization())
    XB.Interface:ResetCRs()
    SetCR()
    XB.CR.CRChanging = false
end)

--Globals
XB.Globals.CR = {
    Add = XB.CR.Add
}
