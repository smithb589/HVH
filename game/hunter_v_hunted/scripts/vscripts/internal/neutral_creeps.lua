if HVHNeutralCreeps == nil then
	HVHNeutralCreeps = class({})

	RANGE_TYPICAL_MIN = 2600.0
	RANGE_TECHIES_MAX = 2000.0
	RANGE_TECHIES_MIN = 0.0
	TECHIES_MAX_MINES = 8

	NEUTRALCREEPS_EVENT_TECHIES_DEATH           = 0
	NEUTRALCREEPS_EVENT_TECHIES_DEATH_NOMINES   = 1
	NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_SNIPERS = 2
	NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_NS      = 3
	NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_URSA    = 4
	NEUTRALCREEPS_EVENT_URSA_KILLED			     = 5 -- guilt of the cubs
	NEUTRALCREEPS_EVENT_TOWER_DESTROYED_BY_SNIPERS = 6
	NEUTRALCREEPS_EVENT_TOWER_DESTROYED_BY_NS 		= 7
	NEUTRALCREEPS_EVENT_BABY_ROSHAN_KILLED_BY_SNIPERS = 8
	NEUTRALCREEPS_EVENT_BABY_ROSHAN_KILLED_BY_NS 	= 9
end

-- for testing
function HVHNeutralCreeps:SpawnCreepsConvar()
	self:SpawnWarParty()
end

function HVHNeutralCreeps:Setup()
	ListenToGameEvent("last_hit", Dynamic_Wrap(self, "OnLastHit"), self)
	ListenToGameEvent("entity_killed", Dynamic_Wrap(self, "OnEntityKilled"), self) 
	ListenToGameEvent("npc_spawned", Dynamic_Wrap(self, "OnNPCSpawned"), self) 
	self.UnitKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")
	self.CurrentPoints = 0

	if not NEUTRAL_CREEPS then return end

	self.Units = {}
	for unitName,unitBlock in pairs(self.UnitKV) do
		local points = unitBlock["NeutralCreepPoints"]
		local weight = unitBlock["NeutralCreepWeight"]
		if points and points ~= 0 then
			self.Units[unitName] = {}
			self.Units[unitName]["value"] = unitName
			self.Units[unitName]["weight"] = weight
			self.Units[unitName]["points"] = points
		end
	end

	self.Randomizer = HVHRandomizer(self.Units)
	--self.Randomizer:DisplayProbabilties()

	Timers:CreateTimer(NEUTRAL_CREEPS_START_TIME, function()
		if self.CurrentPoints < NEUTRAL_CREEPS_UNIT_POINTS_MIN then
			self:SpawnRandomGroup()
		end

		return NEUTRAL_CREEPS_REPEAT_TIME
	end)
end

function HVHNeutralCreeps:SpawnRandomGroup()
	local value = self.Randomizer:GetRandomValue()
	--self.Randomizer:DisplayProbabilties()

	if value == "npc_hvh_megacreep_melee" or
	   value == "npc_hvh_megacreep_ranged" or
	   value == "npc_hvh_megacreep_siege" then
		self:SpawnSoloCreep()
	elseif value == "npc_hvh_tower" then
		self:SpawnWarParty()
	elseif (value == "npc_hvh_ursa" or value == "npc_hvh_roshan") and
		   not self:DoUrsaOrRoshanExist() then
		self:SpawnUrsaAndRoshan()
	elseif value == "npc_hvh_enigma" then
		self:SpawnEnigmaEidolons()
	elseif value == "npc_hvh_hellbear" then
		self:SpawnHellbears()
	elseif value == "npc_hvh_tiny" then
		self:SpawnTiny()
	elseif value == "npc_hvh_enigma" then
		self:SpawnEnigmaEidolons()
	elseif value == "npc_hvh_techies" then
		self:SpawnTechies()
	else
		--print(value .. " not found on ChooseRandomGroup")
	end
end

-------------------------------------------------------------------
-- Megacreeps
-------------------------------------------------------------------
function HVHNeutralCreeps:MegacreepDomination(player, tower)
	local team = player:GetTeam()
	if team == DOTA_TEAM_GOODGUYS then
		self:Notify(team, NEUTRALCREEPS_EVENT_TOWER_DESTROYED_BY_SNIPERS)	
	elseif team == DOTA_TEAM_BADGUYS then
		self:Notify(team, NEUTRALCREEPS_EVENT_TOWER_DESTROYED_BY_NS)
	end

	-- create a table of nearby megacreeps to control
	local seekRadius = 1024.0
	local entList = Entities:FindAllByClassnameWithin("npc_dota_creature", tower:GetAbsOrigin(), seekRadius)
	local megacreepList = {}
	for _,creature in pairs(entList) do
		local name = creature:GetUnitName()
		if name == "npc_hvh_megacreep_melee" or
	   	   name == "npc_hvh_megacreep_ranged" or
	   	   name == "npc_hvh_megacreep_siege" then
	   			table.insert(megacreepList, creature)
	   	end
	end

	-- switch creeps to player's team, destroy AI, and play animation
	local playerID = player:GetPlayerID()
	local team = player:GetTeam()
	for _,creep in pairs(megacreepList) do
		creep:Stop()
		StartAnimation(creep, {duration=6.0, activity=ACT_DOTA_VICTORY, rate=1.0}) -- not working consistently
		creep:SetControllableByPlayer(playerID, true)
		creep:SetTeam(team)
		creep.behaviorSystem = nil
	end
end

function HVHNeutralCreeps:RandomMegacreepModel()
	local r = RandomInt(0,1)

	if r == 0 then
		local altModelList = {} 
		altModelList["npc_hvh_megacreep_melee"]  = "models/creeps/lane_creeps/creep_bad_melee/creep_bad_melee_mega.mdl"
		altModelList["npc_hvh_megacreep_ranged"] = "models/creeps/lane_creeps/creep_bad_ranged/lane_dire_ranged_mega.mdl"
		altModelList["npc_hvh_megacreep_siege"]  = "models/creeps/lane_creeps/creep_bad_siege/creep_bad_siege.mdl"
		altModelList["npc_hvh_tower"]			 = "models/props_structures/tower_good.mdl"
		return altModelList
	else
		return nil
	end

end

function HVHNeutralCreeps:SetPermanentModel(unit, model_path)
	unit:SetOriginalModel(model_path)
	unit:SetModel(model_path)
end

-------------------------------------------------------------------
-- Event listeners
-------------------------------------------------------------------
function HVHNeutralCreeps:OnLastHit(keys)
	local entID = keys.EntKilled
	local playerID = keys.PlayerID
	local entity = EntIndexToHScript(entID)
	local player = PlayerResource:GetPlayer(playerID)
	if not player then return end
	local hero = player:GetAssignedHero()

	if entity:GetUnitName() == "npc_hvh_tower" then
		self:MegacreepDomination(player, entity)
		--print("PlayerID " .. playerID .. " last-hit a tower!")
	end

	if entity:GetUnitName() == "npc_hvh_roshan" then
		local team = player:GetTeam()
		if team == DOTA_TEAM_GOODGUYS then
			self:RoshanKilledBySnipers(entity, hero)
		elseif team == DOTA_TEAM_BADGUYS then
			self:RoshanKilledByNS(entity, hero)
		end
	end

end

-- TODO: hacky and looks shitty
function HVHNeutralCreeps:TowerOnDeath(tower)
	local modelName = tower:GetModelName()
	local destructionName = ""
	if modelName == "models/props_structures/tower_bad.vmdl" then
		destructionName = "models/props_structures/bad_tower_destruction_lev3.vmdl"
	else
		destructionName = "models/props_structures/tower_good3_dest_lvl3.vmdl"
	end
	self:SetPermanentModel(tower, destructionName)
	--StartAnimation(tower, {duration=6.0, activity=ACT_DOTA_DIE, rate=1.0})
end

function HVHNeutralCreeps:OnEntityKilled(keys)
	HVHNeutralCreeps:CleanDroppedGems()

	local unit = EntIndexToHScript(keys.entindex_killed)
	local attacker = EntIndexToHScript(keys.entindex_attacker)
	local attackerTeam = attacker:GetTeam()

	if unit and unit:GetUnitName() == "npc_hvh_techies" then
		self:TechiesOnDeath(unit, attacker)
	elseif unit and unit:GetUnitName() == "npc_hvh_roshan" and attacker:GetUnitName() == "npc_hvh_ursa" then
		self:RoshanKilledByUrsa(unit, attacker)
	elseif unit and unit:GetUnitName() == "npc_hvh_ursa" and attacker:GetUnitName() ~= "npc_hvh_ursa" then
		self:UrsaOnDeath(unit)
	elseif unit and unit:GetUnitName() == "npc_hvh_tower" then
		self:TowerOnDeath(unit)
	end

  	self:SubtractPoints(unit)
end

function HVHNeutralCreeps:OnNPCSpawned(keys)
  	local unit = EntIndexToHScript(keys.entindex)
  	self:AddPoints(unit)
end

-------------------------------------------------------------------
-- Points
-------------------------------------------------------------------
function HVHNeutralCreeps:AddPoints(unit)
  	local points = self:GetPoints(unit)
  	if points then 
	  	self.CurrentPoints = self.CurrentPoints + points
	end
	--print("Current points: " .. self.CurrentPoints)
end

function HVHNeutralCreeps:SubtractPoints(unit)
  	local points = self:GetPoints(unit)
  	if points then 
	  	self.CurrentPoints = self.CurrentPoints - points
	end
	--print("Current points: " .. self.CurrentPoints)
end

function HVHNeutralCreeps:GetPoints(unit)
	local unitName = unit:GetUnitName()
	local unitKV = self.UnitKV[unitName]
	if unitKV then
		local points = unitKV["NeutralCreepPoints"]
		if points then
			--print("Points: " .. points)
			return points
		else
			--print(unitName .. " found, but no Point value assigned.")
			return nil
		end
	else
		--print(unitName .. " not found in custom unit list.")
		return nil
	end
end

-------------------------------------------------------------------
-- Spawn creep functions
-------------------------------------------------------------------
function HVHNeutralCreeps:SpawnSoloCreep()
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local vec_end = AICore:ChooseRandomPointOfInterest(vec_start, RANGE_TYPICAL_MIN)
	local destinationList =	self:CreateDestinationList(vec_end, 2)

	local creepList = {"npc_hvh_megacreep_melee", "npc_hvh_megacreep_ranged", "npc_hvh_megacreep_siege"}
	local r = RandomInt(1, #creepList)

	local creep = self:SpawnNeutrals(creepList[r], 1, vec_start, DOTA_TEAM_CUSTOM_1)
	self:SetDestinationList(creep[1], destinationList)

	-- return list of models if we should switch, or nil if we shouldn't
	local alternateModels = self:RandomMegacreepModel()
	if alternateModels ~= nil then
		local name = creep[1]:GetUnitName()
		self:SetPermanentModel(creep[1], alternateModels[name])
	end
end

function HVHNeutralCreeps:SpawnTiny()
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local vec_end = AICore:ChooseRandomPointOfInterest(vec_start, RANGE_TYPICAL_MIN)
	local destinationList =	self:CreateDestinationList(vec_end, 4)

	local tiny = self:SpawnNeutrals("npc_hvh_tiny", 1, vec_start, DOTA_TEAM_CUSTOM_1)
	self:SetDestinationList(tiny[1], destinationList)
end

function HVHNeutralCreeps:SpawnHellbears()
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local vec_end = AICore:ChooseRandomPointOfInterest(vec_start, RANGE_TYPICAL_MIN)
	local destinationList =	self:CreateDestinationList(vec_end, 4)

	local hellbears = self:SpawnNeutrals("npc_hvh_hellbear", 2, vec_start, DOTA_TEAM_CUSTOM_1)

	for _,unit in pairs(hellbears) do
		self:SetDestinationList(unit, destinationList)
	end
end

function HVHNeutralCreeps:SpawnEnigmaEidolons()
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local vec_end = AICore:ChooseRandomPointOfInterest(vec_start, RANGE_TYPICAL_MIN)
	local destinationList =	self:CreateDestinationList(vec_end, 4)

	local enigma = self:SpawnNeutrals("npc_hvh_enigma", 1, vec_start, DOTA_TEAM_CUSTOM_1)
	local eidolons = self:SpawnNeutrals("npc_hvh_eidolon", 5, vec_start, DOTA_TEAM_CUSTOM_1)
	local unitsAll = JoinTables(enigma, eidolons)

	for _,unit in pairs(unitsAll) do
		self:SetDestinationList(unit, destinationList)
	end
end

function HVHNeutralCreeps:SpawnTechies()
	local start = AICore:ChooseRandomPointOfInterest()
	local destinationList =	self:CreateDestinationList(start, 1, RANGE_TECHIES_MIN, RANGE_TECHIES_MAX)

	local techies = self:SpawnNeutrals("npc_hvh_techies", 1, start, DOTA_TEAM_CUSTOM_1)
	--local techies = CreateUnitByName("npc_hvh_techies", start, true, nil, nil, DOTA_TEAM_NEUTRALS)
	self:SetDestinationList(techies[1], destinationList)
end

function HVHNeutralCreeps:SpawnUrsaAndRoshan()
	local ursaStartEntity = HVHGameMode:GetRandomTeamSpawn()
	local ursaStart = ursaStartEntity:GetAbsOrigin()
	local roshStart = HVHGameMode:GetMatchingTeamSpawn(ursaStartEntity):GetAbsOrigin()

	local rosh = self:SpawnNeutrals("npc_hvh_roshan", 1, roshStart, DOTA_TEAM_CUSTOM_2)
	local ursa = self:SpawnNeutrals("npc_hvh_ursa"  , 1, ursaStart, DOTA_TEAM_CUSTOM_1)
	
	Timers:CreateTimer(0.1, function()
		local roshVis = VisionDummy(rosh[1], "npc_dummy_reveal_roshan")
		local ursaVis = VisionDummy(ursa[1], "npc_dummy_reveal_ursa")
	end)
	--local rosh = CreateUnitByName("npc_hvh_roshan", roshStart:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
	--local ursa = CreateUnitByName("npc_hvh_ursa", ursaStart:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_CUSTOM_1)
	local destinationList =	self:CreateDestinationList(roshStart, 2)

	self:SetTarget(ursa[1], rosh[1])
	self:SetDestinationList(ursa[1], destinationList)

    -- play a random "I'm coming for you, Roshan" line
	local sounds = { "ursa_ursa_items_07", "ursa_ursa_items_09", "ursa_ursa_items_10", "ursa_ursa_items_11" }
	local r = RandomInt(1,#sounds)
	EmitGlobalSound(sounds[r])
end

function HVHNeutralCreeps:SpawnWarParty()
	local vec_start = AICore:ChooseRandomPointOfInterest()
	local vec_end = AICore:ChooseRandomPointOfInterest(vec_start, RANGE_TYPICAL_MIN)
	local destinationList =	self:CreateDestinationList(vec_end, 2)

	-- return list of models if we should switch, or nil if we shouldn't
	local alternateModels = self:RandomMegacreepModel()

	-- spawn the tower on a second neutral team and remove its invulnerability
	local tower = self:SpawnNeutrals("npc_hvh_tower", 1, vec_end, DOTA_TEAM_CUSTOM_2)
	tower = tower[1]
	--local tower = CreateUnitByName("npc_hvh_tower", vec_end, true, nil, nil, DOTA_TEAM_CUSTOM_1)
	tower:SetOrigin(GetGroundPosition(vec_end, tower))
	FindClearSpaceForUnit(tower, vec_end, true)
	tower:RemoveModifierByName("modifier_invulnerable")
	tower:AddNewModifier(tower, nil, "modifier_tower_truesight_aura", {})

	if alternateModels ~= nil then
		local name = tower:GetUnitName()
		self:SetPermanentModel(tower, alternateModels[name])
	end
	
	local unitsMelee  = self:SpawnNeutrals("npc_hvh_megacreep_melee", 4, vec_start, DOTA_TEAM_CUSTOM_1)
	local unitsRanged = self:SpawnNeutrals("npc_hvh_megacreep_ranged", 1, vec_start, DOTA_TEAM_CUSTOM_1)
	local unitsSiege  = self:SpawnNeutrals("npc_hvh_megacreep_siege", 1, vec_start, DOTA_TEAM_CUSTOM_1)
	local unitsAll = JoinTables(JoinTables(unitsMelee,unitsRanged), unitsSiege)

	for _,unit in pairs(unitsAll) do
		self:SetTarget(unit, tower)
		self:SetDestinationList(unit, destinationList)
		--print("Has destination list: " .. tostring(self:HasDestinationList(unit)))

		if alternateModels ~= nil then
			local name = unit:GetUnitName()
			self:SetPermanentModel(unit, alternateModels[name])
			--print("Using alternate models")
		else
			--print("Not using alts")
		end

	end
end

-- returns a table of creeps (even a single creep is in a table)
function HVHNeutralCreeps:SpawnNeutrals(name, groupSize, location, team)
	team = team or DOTA_TEAM_NEUTRALS

	local unitList = {}
	for i=1, groupSize do
		local unit = CreateUnitByName(name, location, true, nil, nil, team)
		table.insert(unitList, unit)
	end

	return unitList
end

------------------------------------------------------------------
-- Ursa/Roshan
-------------------------------------------------------------------
function HVHNeutralCreeps:DoUrsaOrRoshanExist()
	local creatureList = Entities:FindAllByClassname("npc_dota_creature")

	for _,creature in pairs(creatureList) do
		if creature:GetUnitName() == "npc_hvh_roshan" or creature:GetUnitName() == "npc_hvh_ursa" then
			--print("Rosh/Ursa exist, so skip their spawn")
			return true
		end
	end

	return false
end

function HVHNeutralCreeps:RoshanKilledByUrsa(roshan, ursa)
	self:GrantUrsaBuff(ursa)
	self:Notify(nil, NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_URSA)
end

function HVHNeutralCreeps:RoshanKilledBySnipers(roshan, sniper_killer)
	self:GrantAegis(sniper_killer)
	self:Notify(DOTA_TEAM_GOODGUYS, NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_SNIPERS)	
end

function HVHNeutralCreeps:RoshanKilledByNS(roshan, nightStalker)
	self:GrantAegis(nightStalker)
	self:Notify(DOTA_TEAM_BADGUYS, NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_NS)
end

function HVHNeutralCreeps:UrsaOnDeath(ursa)
	self:Notify(nil, NEUTRALCREEPS_EVENT_URSA_KILLED)
end

-- destroy all gems on the ground (item_physicals are world entities that contain items)
function HVHNeutralCreeps:CleanDroppedGems()
	local ents = Entities:FindAllByClassname("dota_item_drop")
	for _,ent in pairs(ents) do
		local containedItem = ent:GetContainedItem()
		if containedItem:GetName() == "item_gem" then
			ent:RemoveSelf()
		end
	end
end

function HVHNeutralCreeps:GrantUrsaBuff(ursa)
	ursa.killedRoshan = true
end

function HVHNeutralCreeps:GrantAegis(hero)
	hero:AddItemByName("item_aegis")
end

-------------------------------------------------------------------
-- Techies mines
-------------------------------------------------------------------
function HVHNeutralCreeps:TechiesOnDeath(unit, killer)
	local team = killer:GetTeam()
	if team == DOTA_TEAM_GOODGUYS or team == DOTA_TEAM_BADGUYS then
		local dummy = self:TransferOwnershipOfTechiesMines(unit, killer)
		local mineCount = self:CountTechiesMines(dummy)
		self:DestroyTechiesDummyThinker(dummy)
		if mineCount > 0 then 
			self:Notify(team, NEUTRALCREEPS_EVENT_TECHIES_DEATH, mineCount)
		else
			self:Notify(team, NEUTRALCREEPS_EVENT_TECHIES_DEATH_NOMINES)
		end
	else
		self:DestroyAllTechiesMines(unit)
	end
end

function HVHNeutralCreeps:CountTechiesMines(unit)
	local mines = self:GetTechiesMines(unit)
	--print("Techies mines found: " .. #mines)
	return #mines
end

function HVHNeutralCreeps:DestroyAllTechiesMines(unit)
	local mines = self:GetTechiesMines(unit)

    --print("Deleting " .. #mines .. " mines.")
    local mineLocations = {}
    for _,mine in pairs(mines) do
		table.insert(mineLocations, mine:GetAbsOrigin())
	    mine:ForceKill(false)
    end

    return mineLocations
end

-- Get all mines owned by a single unit
function HVHNeutralCreeps:GetTechiesMines(unit)
	local mines = Entities:FindAllByClassname("npc_dota_techies_mines")
	if mines == nil then return nil end

	local unitMines = {}
	for _,mine in pairs(mines) do
		if mine:GetOwner() == unit then
			table.insert(unitMines, mine)
		end
	end

	return unitMines
end

-- Destroy all mines, save their locations, and remake the mines for the newOwner's team with a dummy
-- Returns the dummy unit
function HVHNeutralCreeps:TransferOwnershipOfTechiesMines(unit, newOwner)
    local mineLocations = self:DestroyAllTechiesMines(unit)

	local team = newOwner:GetTeam()
	local dummy = CreateUnitByName("npc_dummy", Vector(0,0,0), true, nil, nil, team)
	local ability = dummy:AddAbility("techies_land_mines")
	ability:SetLevel(ability:GetMaxLevel())

    for _,location in pairs(mineLocations) do
		dummy:SetOrigin(location)
		dummy:SetCursorPosition(location)
		ability:EndCooldown()
		ability:OnSpellStart()
	end

	return dummy
end

-- Cleanup function (not strictly necessary)
function HVHNeutralCreeps:DestroyTechiesDummyThinker(dummy)
	local thinkInterval = 1.0
	Timers:CreateTimer(thinkInterval, function()
		local mines = self:CountTechiesMines(dummy)
		if mines > 0 then
			--print (mines .. " remaining...")
			return thinkInterval
		else
			dummy:ForceKill(false)
			--print("All mines gone. Destroying dummy.")
			return nil
		end
	end)
end

-------------------------------------------------------------------
-- Destination List
-------------------------------------------------------------------
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

-------------------------------------------------------------------
-- Targeting
-------------------------------------------------------------------
function HVHNeutralCreeps:GetTarget(unit)
	return unit.attackTarget
end

function HVHNeutralCreeps:SetTarget(unit, target)
	unit.attackTarget = target
end

-------------------------------------------------------------------
-- Notifications
-------------------------------------------------------------------
function HVHNeutralCreeps:Notify(team, event, parameters)
	parameters = parameters or nil
	local dur = 6.5

	local teamString = "Invalid_Team"
	if     team == DOTA_TEAM_GOODGUYS then teamString = "#DOTA_GoodGuys"
	elseif team == DOTA_TEAM_BADGUYS  then teamString = "#DOTA_BadGuys"
	end

	local heroIcon, abilityIcon, eventText, subEventText = nil,nil,nil,nil

	-- Techies was killed by a player team, and he had mines
	if event == NEUTRALCREEPS_EVENT_TECHIES_DEATH then
		heroIcon = "npc_dota_hero_techies"
		abilityIcon = "techies_land_mines"
		subEventText = parameters .. "x " -- parameters = mineCount
		if     team == DOTA_TEAM_GOODGUYS then eventText = "#Techies_MineDiscovery_GG"
		elseif team == DOTA_TEAM_BADGUYS  then eventText = "#Techies_MineDiscovery_BG"
		end

	-- Techies was killed by a player team, but he didn't have any mines
	elseif event == NEUTRALCREEPS_EVENT_TECHIES_DEATH_NOMINES then
		heroIcon = "npc_dota_hero_techies"
		if     team == DOTA_TEAM_GOODGUYS then eventText = "#Techies_NoMines_GG"
		elseif team == DOTA_TEAM_BADGUYS  then eventText = "#Techies_NoMines_BG"
		end
	elseif event == NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_SNIPERS then
		heroIcon = "npc_dota_hero_sniper"
		eventText = "#Roshan_KilledBy_GG"
	elseif event == NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_NS then
		heroIcon = "npc_dota_hero_night_stalker"
		eventText = "#Roshan_KilledBy_BG"
	elseif event == NEUTRALCREEPS_EVENT_ROSHAN_KILLED_BY_URSA then
		heroIcon = "npc_dota_hero_ursa"
		eventText = "#Roshan_KilledBy_Ursa"
	elseif event == NEUTRALCREEPS_EVENT_URSA_KILLED then
		heroIcon = "npc_dota_hero_ursa"
		eventText = "#Ursa_Killed"
	elseif event == NEUTRALCREEPS_EVENT_TOWER_DESTROYED_BY_SNIPERS then
		heroIcon = "npc_dota_hero_sniper"
		eventText = "#Tower_Destroyed_GG"
	elseif event == NEUTRALCREEPS_EVENT_TOWER_DESTROYED_BY_NS then
		heroIcon = "npc_dota_hero_night_stalker"
		eventText = "#Tower_Destroyed_BG"
	elseif event == NEUTRALCREEPS_EVENT_BABY_ROSHAN_KILLED_BY_SNIPERS then
		heroIcon = "npc_dota_hero_sniper"
		eventText = "#BabyRoshan_Killed_GG"
	elseif event == NEUTRALCREEPS_EVENT_BABY_ROSHAN_KILLED_BY_NS then
		heroIcon = "npc_dota_hero_night_stalker"
		eventText = "#BabyRoshan_Killed_BG"
	end

	local cssStyle_Text    = self:GetCSS_Text(team)
	local cssStyle_SubText = self:GetCSS_SubText(team)
	local cssStyle_Image   = self:GetCSS_AbilityImage()

	-- Example output:
	-- (HeroIcon) The Snipers discovered the location of Techies' mines! (AbilityIcon)
	if heroIcon  ~= nil then Notifications:TopToAll({hero=heroIcon,	 duration=dur }) end
	if eventText ~= nil then Notifications:TopToAll({text=eventText, duration=dur, continue=true, style=cssStyle_Text }) end
	if heroIcon  ~= nil then Notifications:TopToAll({hero=heroIcon,	 duration=dur, continue=true }) end
	if subEventText ~= nil then Notifications:TopToAll({text=subEventText, 	 duration=dur, style=cssStyle_SubText }) end
	if abilityIcon  ~= nil then Notifications:TopToAll({ability=abilityIcon, duration=dur, style=cssStyle_AbilityImage, continue=true }) end
end

function HVHNeutralCreeps:GetCSS_Text(team)
	local teamColor = GetTeamColorHex(team)
	local cssStyle = {
		["color"] = teamColor,
		["font-size"] = "28px",
		["background-color"] = "#000000", -- black
		["padding"] ="5px 20px 5px 20px",
		["border-radius"] = "10px"
	}
	return cssStyle
end

function HVHNeutralCreeps:GetCSS_SubText(team)
	local teamColor = GetTeamColorHex(team)
	local cssStyle = {
		["color"] = teamColor,
		["font-size"] ="48px",
		["text-shadow"] = "8px 8px 16px 6.0 black"
	}
	return cssStyle
end

function HVHNeutralCreeps:GetCSS_AbilityImage()
	local cssStyle = {
		["background-size"] = "80px 60px",
		["width"]  = "64px", -- doesn't seem to be doing anything
		["height"] = "64px"
	}
	return cssStyle
end