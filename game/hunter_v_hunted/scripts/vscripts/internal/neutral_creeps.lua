if HVHNeutralCreeps == nil then
	HVHNeutralCreeps = class({})

	RANGE_TYPICAL_MIN = 2600.0
	RANGE_TECHIES_MAX = 2000.0
	RANGE_TECHIES_MIN = 0.0
	TECHIES_MAX_MINES = 12

	NEUTRALCREEPS_EVENT_TECHIES_DEATH = 0
	NEUTRALCREEPS_EVENT_TECHIES_DEATH_NOMINES = 1
end

function HVHNeutralCreeps:Setup()
	ListenToGameEvent("last_hit", Dynamic_Wrap(self, "OnLastHit"), self)
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

-------------------------------------------------------------------
-- Spawn creeps
-------------------------------------------------------------------
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

-- returns a table of creeps, even if a single creep
function HVHNeutralCreeps:SpawnNeutrals(name, groupSize, location)
	local unitList = {}
	for i=1, groupSize do
		local unit = CreateUnitByName(name, location, true, nil, nil, DOTA_TEAM_NEUTRALS)
		table.insert(unitList, unit)
	end

	return unitList
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