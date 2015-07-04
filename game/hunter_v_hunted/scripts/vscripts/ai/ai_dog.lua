
require("ai/ai_core")
require("hvh_utils")

-- todo: not sure if this needs to be put on the entity since there are multiple
behaviorSystem = {}

function Spawn( entityKeyValues )

	thisEntity.Feed = function(feedDuration)
		thisEntity._FeedTime = GameRules:GetGameTime()
		thisEntity._FeedDuration = feedDuration
	end

	thisEntity.IsFed = function()
		--local currentTime = GameRules:GetGameTime() 
		--return (thisEntity._FeedTime + thisEntity._FeedDuration) <= currentTime
		-- todo: placeholder for testing
		return true
	end

	-- This stores the location we started wandering from so the dog
	-- can't just run across the entire map.
	thisEntity._WanderingOrigin = Vector(0, 0)
	thisEntity._MaxWanderingDistance = 300

	thisEntity._FeedDuration = 0
	-- Arbitraryly age this so the dog doesn't start fed.
	thisEntity._FeedTime = GameRules:GetGameTime() - 60

	thisEntity:SetContextThink("ThinkDog", ThinkDog, 0.25)
	behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorWander,
		BehaviorPursue,
		BehaviorSleep
	})
	HVHDebugPrint(string.format("Starting AI for %s. Entity Index: %s", thisEntity:GetUnitName(), thisEntity:GetEntityIndex()))
end

function ThinkDog()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return behaviorSystem:Think()
end

--------------------------------------------------------------------------------------------------------
-- Waiting for game to start behavior

-- This doesn't seem necessary at the moment.
--[[
BehaviorWaitingForPlayers = 
{
	order = 
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
}

function BehaviorWaitingForPlayers:Evaluate()
	local gameState = Convars:GetInt("dota_gamestate")
	local waitingOrder = 1
	if gameState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		waitingOrder = 10
	end
	return waitingOrder
end

function BehaviorWaitingForPlayers:Initialize()
end

function BehaviorWaitingForPlayers:Begin()
	-- Indicate how long the behavior should last
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorWaitingForPlayers:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorWaitingForPlayers:End()
	-- nothing to do
end

function BehaviorWaitingForPlayers:Think(dt)
	-- nothing to do
end
]]

--------------------------------------------------------------------------------------------------------
-- Wander behavior

BehaviorWander = 
{
	order = 
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = thisEntity:GetAbsOrigin()
	}
}

function BehaviorWander:Evaluate()
	local isFed = thisEntity:IsFed()
	local wanderOrder = 3

	if GameRules:IsDaytime() and not isFed then
		wanderOrder = 3
	elseif GameRules:IsDaytime() then
		wanderOrder = 2
	end

	return wanderOrder
end

function BehaviorWander:Initialize()

end

function BehaviorWander:Begin()
	thisEntity._WanderingOrigin = thisEntity:GetAbsOrigin()

	-- Indicate how long the wander behavior should last
	self.endTime = GameRules:GetGameTime() + self:GetWanderDuration()
end

function BehaviorWander:Continue()
	self.endTime = GameRules:GetGameTime() + self:GetWanderDuration()
end

function BehaviorWander:End()
	-- nothing to do
end

function BehaviorWander:Think(dt)
	local wanderingDelta = RandomVector(thisEntity._MaxWanderingDistance)
	local wanderingDestination = thisEntity._WanderingOrigin + wanderingDelta
	thisEntity:MoveToPosition(wanderingDestination)
end

function BehaviorWander:GetWanderDuration()
	local duration = thisEntity._FeedDuration
	local deltaFeedTime = GameRules:GetGameTime() - thisEntity._FeedTime
	if deltaFeedTime < duration then
		duration = duration - deltaFeedTime
	end
	return duration
end

--------------------------------------------------------------------------------------------------------
-- Pursue behavior

BehaviorPursue = 
{
	order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,

		-- todo: this is a guess
		TargetIndex = nil
	}
}

function BehaviorPursue:Evaluate()
	local isFed = thisEntity:IsFed()
	local target = self:FindTarget()
	local pursueOrder = 1
	if GameRules:IsDaytime() and isFed and self:IsTargetValid(target) then
		pursueOrder = 3
	end

	return pursueOrder
end

function BehaviorPursue:Initialize()

end

function BehaviorPursue:Begin()
	local pursuitTarget = self:FindTarget()

	if self:IsTargetValid(pursuitTarget) then
		self.order.TargetIndex = pursuitTarget:GetEntityIndex()
	end

	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorPursue:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorPursue:End()
	self.order.TargetIndex = nil
end

function BehaviorPursue:Think(dt)
	-- No longer a valid target, so end this behavior.
	local pursuitTarget = EntIndexToHScript(self.order.TargetIndex)
	if self:IsTargetValid(pursuitTarget) then
		thisEntity:MoveToNPC(pursuitTarget)
	else
		self.endTime = GameRules:GetGameTime()
	end
end

function BehaviorPursue:FindTarget()
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
								 	thisEntity:GetAbsOrigin(),
									nil,
									FIND_UNITS_EVERYWHERE,
									DOTA_UNIT_TARGET_TEAM_FRIENDLY,
									DOTA_UNIT_TARGET_HERO,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_CLOSEST,
									false)
	return units[1]
end

function BehaviorPursue:IsTargetValid(target)
	return target and not target:IsNull() and target:IsAlive()
end

--------------------------------------------------------------------------------------------------------
-- Sleep behavior

BehaviorSleep = 
{
	order = 
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	}
}

function BehaviorSleep:Evaluate()
	-- todo: determine if night time
	return 1
end

function BehaviorSleep:Initialize()

end

function BehaviorSleep:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorSleep:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorSleep:End()

end

function BehaviorSleep:Think(dt)
end


--[[function ThinkDog()
	--print("Thinking...")
	if GameRules:IsDaytime() then

		if IsFed() then

			local target = AcquireTarget()
			if target then
				Pursue(target)
			else -- target dead or missing
				HVHDebugPrint("Target not found.")
				Wander()
			end

		else -- is not fed
			Wander()
		end

	else -- is night
		Sleep()
	end

	return 1
end

-- TODO: tie in with sniper ability
function IsFed()
	return 1
end

-- returns the closest badguy hero
function AcquireTarget()
	--HVHDebugPrint("Acquiring target...")
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
		 	thisEntity:GetAbsOrigin(),
			nil,
			FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,
			DOTA_UNIT_TARGET_HERO,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_CLOSEST,
			false)
	if units[1] ~= nil then
		return units[1]
	else
		return false
	end
end

function Pursue(target)
	--HVHDebugPrint("Pursuing " .. target:GetUnitName() .. "!")
	thisEntity:MoveToNPC(target)
end

-- TODO
function Disable(target)
end

-- TODO: actual wandering
function Wander()
	if not (thisEntity._IsWandering or false) and not thisEntity:IsIdle() then
		thisEntity._IsWandering = true
		local wanderPosition = thisEntity:GetAbsOrigin()
		local wanderDelta = RandomVector(300)
		wanderPosition = wanderPosition + wanderDelta

		--local finalDestination = FindClearSpaceForUnit(thisEntity, wanderPosition, false) 

		thisEntity:MoveToPosition(wanderPosition)
	else
		HVHDebugPrint("Already wandering.")
	end


	--HVHDebugPrint("Wandering...")
end

function Sleep()
	if not thisEntity:IsIdle() then
		thisEntity:Stop()
	end
	--HVHDebugPrint("Sleeping...")
end
]]