if AICore == nil then
  AICore = class({})
end

-- Retrieve enemies to (unit) within (radius) at either the unit's position or (position)
function AICore:GetEnemiesInRange(unit, radius, position)
	position = position or unit:GetAbsOrigin() -- optional 3rd argument
	radius = radius or 0 -- fixes error while game is paused and creeps spawned
	local units = FindUnitsInRadius(unit:GetTeamNumber(),
								 	position,
									nil,
									radius,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
									FIND_CLOSEST,
									false)
	return units
end

-- Are at least (number) units surrounding (unit) within (radius)?
function AICore:AreEnemiesInRange(unit, radius, number)
	local units = self:GetEnemiesInRange(unit, radius)
	if units[number] then return true else return false end
end

-- Points of interests are derived from spawn points, courier spawns, and chest spawns
-- This function relieves the need to create separate spawn points for neutral creeps
function AICore:GetAllPointsOfInterest()
	local groupList = {
		"info_courier_spawn_radiant",
		"info_courier_spawn_dire",
		"info_player_start_goodguys",
		"info_player_start_badguys",
		"dota_item_spawner"
	}

	-- link the entity lists together into a master list
	local masterList = {}
	for _,group in pairs(groupList) do
		local groupList = Entities:FindAllByClassname(group)
		masterList = JoinTables(masterList, groupList)
	end

	return masterList
end

-- Choose a random point of interest, optionally a minimum distance away from another point
function AICore:ChooseRandomPointOfInterest( vector, minDistanceFrom )
	entity = entity or nil
	minDistanceFrom = minDistanceFrom or nil

	local masterList = self:GetAllPointsOfInterest()

	-- choose a random point from the master list and check that it's valid
	local loc = nil
	local validPOI = false
	while not validPOI do
		local r = RandomInt(1, #masterList)
		local poi = masterList[r]
		loc = poi:GetAbsOrigin()
		
		if vector and minDistanceFrom and Length2DBetweenVectors(vector, loc) <= minDistanceFrom then
			--print(r .. " too close. Repicking.")
			validPOI = false
		else
			--print(r .. " chosen.")
			validPOI = true
		end
	end

	return loc
end

------------------------------------------------------------
-- HOLDOUT functions
------------------------------------------------------------
function AICore:RandomEnemyHeroInRange( entity, range )
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	if #enemies > 0 then
		local index = RandomInt( 1, #enemies )
		return enemies[index]
	else
		return nil
	end
end

function AICore:WeakestEnemyHeroInRange( entity, range )
	local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )

	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
		local HP = enemy:GetHealth()
		if enemy:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
			minHP = HP
			target = enemy
		end
	end

	return target
end