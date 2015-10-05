if HVHNeutralCreeps == nil then
	HVHNeutralCreeps = class({})
end

function HVHNeutralCreeps:Setup()
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local vec_end = AICore:ChooseRandomPointOfInterest(vec_start, 2600.0)

	self:SpawnTiny(vec_start, vec_end)
	--self:SpawnMegacreeps(vec_start, vec_end)
	--self:SpawnHellbears(vec_start, vec_end)
end

function HVHNeutralCreeps:SpawnMegacreeps(vec_start, vec_end)
	local groupSize = 5
	for i=1, groupSize do
		local unit = self:SpawnNeutral("npc_hvh_megacreep_melee", vec_start)
		unit.destinationLoc = vec_end
	end
end

function HVHNeutralCreeps:SpawnHellbears(vec_start, vec_end)
	local groupSize = 2
	for i=1, groupSize do
		local unit = self:SpawnNeutral("npc_hvh_hellbear", vec_start)
		unit.destinationLoc = vec_end
	end
end

function HVHNeutralCreeps:SpawnTiny(vec_start, vec_end)
	local groupSize = 1
	for i=1, groupSize do
		local unit = self:SpawnNeutral("npc_hvh_tiny", vec_start)
		unit.destinationLoc = vec_end
	end
end

function HVHNeutralCreeps:SpawnNeutral(name, location)
	return CreateUnitByName(name, location, true, nil, nil, DOTA_TEAM_NEUTRALS)
end