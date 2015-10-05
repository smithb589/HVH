--[[
Taken from the holdout example.

These are the valid orders, in case you want to use them (easier here than to find them in the C code):

DOTA_UNIT_ORDER_NONE
DOTA_UNIT_ORDER_MOVE_TO_POSITION 
DOTA_UNIT_ORDER_MOVE_TO_TARGET 
DOTA_UNIT_ORDER_ATTACK_MOVE
DOTA_UNIT_ORDER_ATTACK_TARGET
DOTA_UNIT_ORDER_CAST_POSITION
DOTA_UNIT_ORDER_CAST_TARGET
DOTA_UNIT_ORDER_CAST_TARGET_TREE
DOTA_UNIT_ORDER_CAST_NO_TARGET
DOTA_UNIT_ORDER_CAST_TOGGLE
DOTA_UNIT_ORDER_HOLD_POSITION
DOTA_UNIT_ORDER_TRAIN_ABILITY
DOTA_UNIT_ORDER_DROP_ITEM
DOTA_UNIT_ORDER_GIVE_ITEM
DOTA_UNIT_ORDER_PICKUP_ITEM
DOTA_UNIT_ORDER_PICKUP_RUNE
DOTA_UNIT_ORDER_PURCHASE_ITEM
DOTA_UNIT_ORDER_SELL_ITEM
DOTA_UNIT_ORDER_DISASSEMBLE_ITEM
DOTA_UNIT_ORDER_MOVE_ITEM
DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
DOTA_UNIT_ORDER_STOP
DOTA_UNIT_ORDER_TAUNT
DOTA_UNIT_ORDER_BUYBACK
DOTA_UNIT_ORDER_GLYPH
DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH
DOTA_UNIT_ORDER_CAST_RUNE
]]

require("hvh_utils")

AICore = {}

DESIRE_NONE   = 0
DESIRE_LOW    = 5
DESIRE_MEDIUM = 10
DESIRE_HIGH   = 15
DESIRE_MAX	  = 20

function AICore:AreEnemiesInRange(unit, radius, number)
	local units = FindUnitsInRadius(unit:GetTeamNumber(),
								 	unit:GetAbsOrigin(),
									nil,
									radius,
									DOTA_UNIT_TARGET_TEAM_ENEMY,
									DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
									DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,
									FIND_CLOSEST,
									false)
	if units[number] then return true end
end


function AICore:GetAllPointsOfInterest()
	-- the POIs are derived from spawn points, courier spawns, and chest spawns
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

function AICore:CreateBehaviorSystem( behaviors )
	local BehaviorSystem = {}

	BehaviorSystem.possibleBehaviors = behaviors
	BehaviorSystem.thinkDuration = 1.0
	BehaviorSystem.repeatedlyIssueOrders = true -- if you're paranoid about dropped orders, leave this true

	BehaviorSystem.currentBehavior =
	{
		endTime = 0,
		order = { OrderType = DOTA_UNIT_ORDER_NONE }
	}

	function BehaviorSystem:Think()
		if GameRules:GetGameTime() >= self.currentBehavior.endTime then
			local newBehavior = self:ChooseNextBehavior()
			if newBehavior == nil then 
				-- Do nothing here... this covers possible problems with ChooseNextBehavior
			elseif newBehavior == self.currentBehavior then
				self.currentBehavior:Continue()
			else
				if self.currentBehavior.End then self.currentBehavior:End() end
				self.currentBehavior = newBehavior
				self.currentBehavior:Begin()
			end
		end

		if self.currentBehavior.order and self.currentBehavior.order.OrderType ~= DOTA_UNIT_ORDER_NONE then
			if self.repeatedlyIssueOrders or
				self.previousOrderType ~= self.currentBehavior.order.OrderType or
				self.previousOrderTarget ~= self.currentBehavior.order.TargetIndex or
				self.previousOrderPosition ~= self.currentBehavior.order.Position then

				-- Keep sending the order repeatedly, in case we forgot >.<
				ExecuteOrderFromTable( self.currentBehavior.order )
				self.previousOrderType = self.currentBehavior.order.OrderType
				self.previousOrderTarget = self.currentBehavior.order.TargetIndex
				self.previousOrderPosition = self.currentBehavior.order.Position
			end
		end

		if self.currentBehavior.Think then self.currentBehavior:Think(self.thinkDuration) end

		return self.thinkDuration
	end

	function BehaviorSystem:ChooseNextBehavior()
		local result = nil
		local bestDesire = nil
		for _,behavior in pairs( self.possibleBehaviors ) do
			local thisDesire = behavior:Evaluate()
			if bestDesire == nil or thisDesire > bestDesire then
				result = behavior
				bestDesire = thisDesire
			end
		end

		HVHDebugPrint(string.format("Choosing behavior with score %d", bestDesire))
		HVHDebugPrintTable(result)

		return result
	end

	function BehaviorSystem:Deactivate()
		if self.currentBehavior.End then self.currentBehavior:End() end
	end

	return BehaviorSystem
end