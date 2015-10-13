if HVHNeutralCreeps == nil then
	HVHNeutralCreeps = class({})
end

RANGE_TYPICAL_MIN = 2600.0
RANGE_TECHIES_MAX = 3200.0
RANGE_TECHIES_MIN = 0.0

function HVHNeutralCreeps:Setup()
	ListenToGameEvent("last_hit", Dynamic_Wrap(self, "OnLastHit"), self)
end

function HVHNeutralCreeps:SpawnCreeps()
	
	--[[
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local destinationList =	self:CreateDestinationList(vec_start, 3)
	local unitsAll = {}

	unitsAll = JoinTables(unitsAll, self:SpawnNeutrals("npc_hvh_megacreep_ranged", 1, vec_start))
	unitsAll = JoinTables(unitsAll, self:SpawnNeutrals("npc_hvh_megacreep_siege", 1, vec_start))
	unitsAll = JoinTables(unitsAll, self:SpawnNeutrals("npc_hvh_megacreep_melee", 4, vec_start))
    unitsAll = JoinTables(unitsAll, self:SpawnNeutrals("npc_hvh_hellbear", 2, vec_start))
	unitsAll = JoinTables(unitsAll, self:SpawnNeutrals("npc_hvh_tiny", 1, vec_start))
	unitsAll = JoinTables(unitsAll, self:SpawnNeutrals("npc_hvh_enigma", 1, vec_start))
	unitsAll = JoinTables(unitsAll, self:SpawnNeutrals("npc_hvh_eidolon", 4, vec_start))

	for _,unit in pairs(unitsAll) do
		self:SetDestinationList(unit, destinationList)
	end
	]]
	--self:SpawnWarParty()
	--self:SpawnUrsaAndRoshan()
	self:SpawnTechies()

end

function HVHNeutralCreeps:OnLastHit(keys)
	local entID = keys.EntKilled
	local playerID = keys.PlayerID
	local entity = EntIndexToHScript(entID)
	local player = PlayerResource:GetPlayer(playerID)

	if entity:GetUnitName() == "npc_hvh_tower" then
		print("PlayerID " .. playerID .. " last-hit a tower!")
	end
end

function HVHNeutralCreeps:SpawnTechies(keys)
	local start = AICore:ChooseRandomPointOfInterest()
	local destinationList =	self:CreateDestinationList(start, 1, RANGE_TECHIES_MIN, RANGE_TECHIES_MAX)

	local techies = CreateUnitByName("npc_hvh_techies", start, true, nil, nil, DOTA_TEAM_NEUTRALS)
	self:SetDestinationList(techies, destinationList)
end

function HVHNeutralCreeps:SpawnUrsaAndRoshan()
	local ursaStart = HVHGameMode:GetRandomTeamSpawn()
	local roshStart = HVHGameMode:GetMatchingTeamSpawn(ursaStart)

	local rosh = CreateUnitByName("npc_hvh_roshan", roshStart:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_CUSTOM_1)
	local ursa = CreateUnitByName("npc_hvh_ursa", ursaStart:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
	local destinationList =	self:CreateDestinationList(roshStart:GetAbsOrigin(), 3)

	self:SetTarget(ursa, rosh)
	self:SetDestinationList(ursa, destinationList)

	-- play a random "I'm coming for you, Roshan" line
	local sounds = { "ursa_ursa_items_07", "ursa_ursa_items_09", "ursa_ursa_items_10", "ursa_ursa_items_11" }
	local r = RandomInt(1,#sounds)
	EmitGlobalSound(sounds[r])
end

function HVHNeutralCreeps:SpawnWarParty()
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local vec_end = AICore:ChooseRandomPointOfInterest(vec_start, RANGE_TYPICAL_MIN)
	local destinationList =	self:CreateDestinationList(vec_end, 3)

	-- spawn the tower on a second neutral team and remove its invulnerability
	local tower = CreateUnitByName("npc_hvh_tower", vec_end, true, nil, nil, DOTA_TEAM_CUSTOM_1)
	tower:SetOrigin(GetGroundPosition(vec_end, tower))
	FindClearSpaceForUnit(tower, vec_end, true)
	tower:RemoveModifierByName("modifier_invulnerable")
	tower:AddNewModifier(tower, nil, "modifier_tower_truesight_aura", {})

	local unitsMelee  = self:SpawnNeutrals("npc_hvh_megacreep_melee", 4, vec_start)
	local unitsRanged = self:SpawnNeutrals("npc_hvh_megacreep_ranged", 1, vec_start)
	local unitsSiege  = self:SpawnNeutrals("npc_hvh_megacreep_siege", 1, vec_start)
	local unitsAll = JoinTables(JoinTables(unitsMelee,unitsRanged), unitsSiege)

	for _,unit in pairs(unitsAll) do
		self:SetTarget(unit, tower)
		self:SetDestinationList(unit, destinationList)
	end
end

function HVHNeutralCreeps:CountTechiesMines(unit)
	local mines = Entities:FindAllByClassname("npc_dota_techies_mines")

	local unitMines = {}
	for _,mine in pairs(mines) do
		if mine:GetOwner() == unit then
			table.insert(unitMines, mine)
		end
	end

	print("Techies mines found: " .. #unitMines)
	return #unitMines
end

function HVHNeutralCreeps:GetDestinationList(unit)
	return unit.destinationList
end

function HVHNeutralCreeps:SetDestinationList(unit, list)
	unit.destinationList = list
	unit.currentDestination = 1
end

function HVHNeutralCreeps:CreateDestinationList(startingLocation, destinationCount, minDistance, maxDistance)
	destinationCount = destinationCount or 1
	minDistance = minDistance or RANGE_TYPICAL_MIN
	maxDistance = maxDistance or nil

	local start = startingLocation
	local destinationArray = {}
	for i=1, destinationCount do
		destinationArray[i] = AICore:ChooseRandomPointOfInterest(start, minDistance, maxDistance)
		start = destinationArray[i]
	end
	return destinationArray
end

function HVHNeutralCreeps:AddDestination(unit, minDistance, maxDistance)
	minDistance = minDistance or RANGE_TYPICAL_MIN
	maxDistance = maxDistance or nil

	local location = unit:GetAbsOrigin()
	local newDestination = AICore:ChooseRandomPointOfInterest(location, minDistance, maxDistance)
	table.insert(unit.destinationList, newDestination)
end

function HVHNeutralCreeps:IsNextDestinationValid(unit)
	return unit.destinationList[unit.currentDestination+1] ~= nil
end

function HVHNeutralCreeps:NextDestination(unit)
	unit.currentDestination = unit.currentDestination + 1
end

function HVHNeutralCreeps:HasDestination(unit)
	if unit.destinationList[unit.currentDestination] ~= nil then
		return true
	else
		return false
	end
end

function HVHNeutralCreeps:GetDestination(unit)
	return unit.destinationList[unit.currentDestination]
end

function HVHNeutralCreeps:GetTarget(unit)
	--print(unit.attackTarget)
	return unit.attackTarget
end

function HVHNeutralCreeps:SetTarget(unit, target)
	unit.attackTarget = target
	--print(unit.attackTarget)
end

-- returns a table of creeps, even if a single creep
function HVHNeutralCreeps:SpawnNeutrals(name, groupSize, location)
	local unitList = {} 
	for i=1, groupSize do
		local unit = CreateUnitByName(name, location, true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(unitList, unit)
	end

	return unitList
end