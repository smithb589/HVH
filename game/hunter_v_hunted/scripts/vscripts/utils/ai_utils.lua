if AICore == nil then
  AICore = class({})
end

function AICore:DebugDraw(start_vec, end_vec, rgb_vec, duration)
	local r,g,b = rgb_vec.x, rgb_vec.y, rgb_vec.z
	DebugDrawCircle(end_vec, Vector(r,g,b), 128.0, 128.0, true, duration)
	DebugDrawLine(start_vec, end_vec, r, g, b, true, duration)
	--local canFindPath = GridNav:CanFindPath(start_vec, end_vec)
	--local isBlocked = GridNav:IsBlocked(end_vec)
	--local isTraversable = GridNav:IsTraversable(end_vec)
	--print(string.format("CanFindPath: %s, IsBlocked: %s, IsTraversable: %s", tostring(canFindPath), tostring(isBlocked), tostring(isTraversable)))
end

-- DOTA_TEAM_NEUTRAL units seem to have flying vision
function AICore:CanSeeTarget(unit, target)
	--print("Can see target: " .. tostring(unit:CanEntityBeSeenByMyTeam(target)))
	return unit:CanEntityBeSeenByMyTeam(target)
end

function AICore:IsTargetValid(target)
	return target and not target:IsNull() and target:IsAlive()
end

function AICore:_InRange(range, min_range, max_range)
	min_range = min_range or 0
	max_range = max_range or 99999

	if (min_range and range >= min_range) and (max_range and range <= max_range) then
		return true
	else
		return false
	end
end

function AICore:IsVectorInRange(unit, vector, min_range, max_range)
	local range = Length2DBetweenVectors(unit:GetAbsOrigin(), vector)
	return self:_InRange(range, min_range, max_range)
end

function AICore:IsTargetInRange(unit, target, min_range, max_range)
	local range = unit:GetRangeToUnit(target)
	return self:_InRange(range, min_range, max_range)
end

-- Retrieve enemies to (unit) within (radius) at either the unit's position or (position)
function AICore:GetEnemiesInRange(unit, radius, fow_visible)
	--position = position or unit:GetAbsOrigin() -- optional argument (removed)
	radius = radius or 0 -- fixes error while game is paused and creeps spawned
	fow_visible = fow_visible or false

	local flags = DOTA_UNIT_TARGET_FLAG_NONE
	if fow_visible then
		flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS
	end

	local units = FindUnitsInRadius(unit:GetTeamNumber(),
								 	unit:GetAbsOrigin(),
									nil,
									radius,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									flags,
									FIND_CLOSEST,
									false)
	return units
end

-- Get the closest visible unit near (unit) within (radius)
function AICore:GetClosestVisibleEnemyInRange(unit, radius)
	local units = self:GetEnemiesInRange(unit, radius, true)
	--print(#units .. " in range.")
	if units[1] then return units[1] else return nil end
end

-- Are at least (number) units surrounding (unit) within (radius)?
function AICore:AreEnemiesInRange(unit, radius, number)
	local units = self:GetEnemiesInRange(unit, radius)
	--print(#units .. " in range.")
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
function AICore:ChooseRandomPointOfInterest( center, minDistanceFrom, maxDistanceFrom )
	center = center or nil
	minDistanceFrom = minDistanceFrom or nil
	maxDistanceFrom = maxDistanceFrom or nil

	local masterList = self:GetAllPointsOfInterest()

	-- add every valid point to the 
	local filteredList = {}
	for _,poi in pairs(masterList) do
		local loc = poi:GetAbsOrigin()
		if center then
			if (minDistanceFrom and Length2DBetweenVectors(center, loc) <= minDistanceFrom) or
			   (maxDistanceFrom and Length2DBetweenVectors(center, loc) >= maxDistanceFrom) then
				--print("Point too close or too far. Not valid.")
			else
				--print("Point is within specified parameters. Added.")
				table.insert(filteredList, poi)
			end
		else
			--print("No center specified, so any point is valid.")
			table.insert(filteredList, poi)
		end
	end

	-- choose a random point from the filtered list
	local r = RandomInt(1, #filteredList)
	local chosenPOI = filteredList[r]
	local chosenPOI_location = chosen

	--print(#filteredList .. " possible points of interest. Choosing: " .. r)
	return chosenPOI:GetAbsOrigin()
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