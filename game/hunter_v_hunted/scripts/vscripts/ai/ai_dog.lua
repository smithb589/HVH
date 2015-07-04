
require("ai/ai_core")
require("hvh_utils")

-- todo: not sure if this needs to be put on the entity since there are multiple
behaviorSystem = {}

function Spawn( entityKeyValues )

	thisEntity.Feed = function(feedDuration)
		thisEntity._FeedTime = GameRules:GetGameTime()
		thisEntity._FeedDuration = feedDuration
	end

	thisEntity._WanderingOrigin = Vector(0, 0)
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
	-- todo: Determine if not fed and is daytime
	return 2
end

function BehaviorWander:Initialize()

end

function BehaviorWander:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorWander:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorWander:End()
	self.endTime = GameRules:GetGameTime()
end

function BehaviorWander:Think(dt)

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
	-- todo: determine if fed and is daytime
	return 1
end

function BehaviorPursue:Initialize()

end

function BehaviorPursue:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorPursue:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorPursue:End()
	self.endTime = GameRules:GetGameTime()
end

function BehaviorPursue:Think(dt)

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
	self.endTime = GameRules:GetGameTime()
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