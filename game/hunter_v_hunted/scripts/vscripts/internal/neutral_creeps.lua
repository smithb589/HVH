if HVHNeutralCreeps == nil then
	HVHNeutralCreeps = class({})
end

function HVHNeutralCreeps:Setup()
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local vec_end = AICore:ChooseRandomPointOfInterest(vec_start, 2600.0)

	self:SpawnNeutrals("npc_hvh_megacreep_ranged", vec_start, vec_end, 1)
	self:SpawnNeutrals("npc_hvh_megacreep_siege", vec_start, vec_end, 1)
	self:SpawnNeutrals("npc_hvh_megacreep_melee", vec_start, vec_end, 4)
    --self:SpawnNeutrals("npc_hvh_hellbear", vec_start, vec_end, 2)
	--self:SpawnNeutrals("npc_hvh_tiny", vec_start, vec_end, 1)
	--self:SpawnNeutrals("npc_hvh_enigma", vec_start, vec_end, 1)
	--self:SpawnNeutrals("npc_hvh_eidolon", vec_start, vec_end, 4)

	local tower = CreateUnitByName("npc_hvh_tower", vec_end, true, nil, nil, DOTA_TEAM_CUSTOM_1)
	tower:SetOrigin(GetGroundPosition(vec_end, tower))
	FindClearSpaceForUnit(tower, vec_end, true)
	tower:RemoveModifierByName("modifier_invulnerable")
end

function HVHNeutralCreeps:SpawnNeutrals(name, location, destination, groupSize)
	for i = 1, groupSize do
		local unit = CreateUnitByName(name, location, true, nil, nil, DOTA_TEAM_NEUTRALS)
		unit.destinationLoc = destination
	end
end