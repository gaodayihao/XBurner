local _, XB                     = ...
XB.Game.Artifact                = {}
local UnitClass                 = UnitClass
local GetSpecializationInfo     = GetSpecializationInfo
local GetSpecialization         = GetSpecialization
local artifactListener          = {}
local LAD                       = LibStub("LibArtifactData-1.0")
local GetEquippedArtifactInfo   = C_ArtifactUI.GetEquippedArtifactInfo

-- checkes for perk rank
local function getPerk(spellID, data)
    if data.traits ~= nil then
        for i=1, #data.traits do
            if spellID == data.traits[i]["spellID"] then
                return true, data.traits[i]["currentRank"]
            end
        end
    end
    return false, 0
end

local function BuildArtifact()
    local classIndex = select(3,UnitClass('player'))
	local spec = GetSpecializationInfo(GetSpecialization())
    local artifacts = XB.Abilities:GetArtifactsTable(classIndex,spec)

    XB.Game.Artifact = {}
    local artifactId = select(1,GetEquippedArtifactInfo())
    local _, data = LAD:GetArtifactInfo(artifactId)
    for name, spellID in pairs(artifacts) do
        local hasPerk,perkRank = getPerk(spellID, data)
        XB.Game.Artifact[name] = function()
            return {enable = hasPerk, rank = perkRank}
        end
    end
end

function artifactListener:ARTIFACT_ADDED()
    BuildArtifact()
end

function artifactListener:ARTIFACT_EQUIPPED_CHANGED()
    BuildArtifact()
end

function artifactListener:ARTIFACT_DATA_MISSING()
    BuildArtifact()
end

function artifactListener:ARTIFACT_RELIC_CHANGED()
    BuildArtifact()
end

function artifactListener:ARTIFACT_TRAITS_CHANGED()
    BuildArtifact()
end

LAD.RegisterCallback(artifactListener, "ARTIFACT_ADDED")
LAD.RegisterCallback(artifactListener, "ARTIFACT_EQUIPPED_CHANGED")
LAD.RegisterCallback(artifactListener, "ARTIFACT_DATA_MISSING")
LAD.RegisterCallback(artifactListener, "ARTIFACT_RELIC_CHANGED")
LAD.RegisterCallback(artifactListener, "ARTIFACT_TRAITS_CHANGED")