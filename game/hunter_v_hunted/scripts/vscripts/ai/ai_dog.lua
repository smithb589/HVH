require("ai/ai_dog_speech")
require("ai/ai_core")
require("hvh_utils")

behaviorSystem = {}

function Spawn( entityKeyValues )

	thisEntity.Feed = function(self, feedDuration)
		self._FeedTime = GameRules:GetGameTime()
		self._FeedDuration = feedDuration
	end

	thisEntity.IsFed = function(self)
		local currentTime = GameRules:GetGameTime() 
		return (self._FeedTime + self._FeedDuration) > currentTime
	end

	-- This stores the location we started wandering from so the dog
	-- can't just run across the entire map.
	thisEntity._WanderingOrigin = Vector(0, 0)
	thisEntity._MaxWanderingDistance = 150.0

	thisEntity._FeedDuration = 0
	-- Arbitrarily age this so the dog doesn't start fed.
	thisEntity._FeedTime = GameRules:GetGameTime() - 60

	thisEntity._LastWarnTime = 0.0

	thisEntity:SetContextThink("ThinkDog", ThinkDog, 0.1)
	behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorWander,
		BehaviorWarn,
		BehaviorPursue,
		BehaviorSprint,
		BehaviorSleep
	})
	behaviorSystem.thinkDuration = 0.1
	HVHDebugPrint(string.format("Starting AI for %s. Entity Index: %s", thisEntity:GetUnitName(), thisEntity:GetEntityIndex()))
end

function ThinkDog()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return behaviorSystem:Think()
end

function FindNearestTarget(entity)
	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
								 	entity:GetAbsOrigin(),
									nil,
									FIND_UNITS_EVERYWHERE,
									DOTA_UNIT_TARGET_TEAM_FRIENDLY,
									DOTA_UNIT_TARGET_HERO,
									DOTA_UNIT_TARGET_FLAG_NONE,
									FIND_CLOSEST,
									false)
	return units[1]
end

function IsTargetValid(target)
	return target and not target:IsNull() and target:IsAlive()
end

function IsInvisibleTargetInWanderRange(target)
	local targetInWanderRange = false
	local targetValid = IsTargetValid(target)

	if targetValid then
		local rangeToTarget = thisEntity:GetRangeToUnit(target)
		targetInWanderRange = rangeToTarget < thisEntity._MaxWanderingDistance
	end
	
	return targetValid and targetInWanderRange and target:IsInvisible()
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
	local wanderDesire = 1

	local nearestTarget = FindNearestTarget(thisEntity)
	if IsInvisibleTargetInWanderRange(nearestTarget) then
		HVHDebugPrint("The hound found Night Stalker, but cannot target him.")
		wanderDesire = 10
	end

	return wanderDesire
end

function BehaviorWander:Initialize()

end

function BehaviorWander:Begin()
	self:_DetermineWanderOrigin()

	self.order.Position = self:GetWanderDestination()

	-- Indicate how long the wander behavior should last
	self.endTime = GameRules:GetGameTime() + self:GetWanderDuration()

	--thisEntity:AddSpeechBubble(SPEECH_ID, SPEECH_WANDER_BEGIN, SPEECH_DUR, SP_X, SP_Y)
end

function BehaviorWander:Continue()
	self.order.Position = self:GetWanderDestination()
	self.endTime = GameRules:GetGameTime() + self:GetWanderDuration()
end

function BehaviorWander:End()
	-- nothing to do
end

function BehaviorWander:Think(dt)
	-- Nothing to do
end

function BehaviorWander:GetWanderDuration()
	local moveSpeed = thisEntity:GetMoveSpeedModifier(thisEntity:GetBaseMoveSpeed())
	local wanderDuration = thisEntity._MaxWanderingDistance / moveSpeed
	return wanderDuration
end

function BehaviorWander:GetWanderDestination()
	local wanderingDelta = RandomVector(thisEntity._MaxWanderingDistance)
	local wanderingDestination = thisEntity._WanderingOrigin + wanderingDelta
	return wanderingDestination
end

function BehaviorWander:_DetermineWanderOrigin()
	-- This should maybe be a different behavior since it branches...
	local nearestTarget = FindNearestTarget(thisEntity)
	if IsTargetValid(nearestTarget) and nearestTarget:IsInvisible() then
		thisEntity._WanderingOrigin = nearestTarget:GetAbsOrigin()
	else
		thisEntity._WanderingOrigin = thisEntity:GetAbsOrigin()
	end
end

--------------------------------------------------------------------------------------------------------
-- Warn behavior

BehaviorWarn = 
{
	order = 
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_NONE
	},

	warnDuration = 1
}

function BehaviorWarn:Evaluate()
	local target = FindNearestTarget(thisEntity)
	local warnDesire = 0
	if IsInvisibleTargetInWanderRange(target) and self:_CanWarn() then
		warnDesire = 13
	end

	return warnDesire
end

function BehaviorWarn:Begin()
	self:_DoWarn()

	self.endTime = GameRules:GetGameTime() + self.warnDuration
end


function BehaviorWarn:Continue()
	self:_DoWarn()

	self.endTime = GameRules:GetGameTime() + self.warnDuration
end

function BehaviorWarn:End()

end

function BehaviorWarn:_DoWarn()
	thisEntity:Stop()
	thisEntity:StartGesture(ACT_DOTA_ATTACK)
	thisEntity:EmitSound("Lycan_Wolf.PreAttack")
	thisEntity._LastWarnTime = GameRules:GetGameTime()
end

function BehaviorWarn:_CanWarn()
	-- Only try to warn every 2 seconds.
	return thisEntity._LastWarnTime < (GameRules:GetGameTime() - 2)
end

--------------------------------------------------------------------------------------------------------
-- Pursue behavior

BehaviorPursue = 
{
	order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = thisEntity:GetAbsOrigin(),
		TargetIndex = nil
	}
}

function BehaviorPursue:Evaluate()
	local target = FindNearestTarget(thisEntity)
	local pursueOrder = 0
	if GameRules:IsDaytime() and IsTargetValid(target) then
		pursueOrder = 5
	end

	return pursueOrder
end

function BehaviorPursue:Initialize()

end

function BehaviorPursue:Begin()
	local pursuitTarget = FindNearestTarget(thisEntity)

	if IsTargetValid(pursuitTarget) then
		self.order.TargetIndex = pursuitTarget:GetEntityIndex()
		self.order.Position = pursuitTarget:GetAbsOrigin()
	end

	self.endTime = GameRules:GetGameTime() + 0.1

	--thisEntity:AddSpeechBubble(SPEECH_ID, SPEECH_PURSUE_BEGIN, SPEECH_DUR, SP_X, SP_Y)
end

function BehaviorPursue:Continue()
	-- important to constantly re-evaluate the closest target (illusions, etc.)
	local pursuitTarget = FindNearestTarget(thisEntity)

	if IsTargetValid(pursuitTarget) then
		self.order.TargetIndex = pursuitTarget:GetEntityIndex()
		self.order.Position = pursuitTarget:GetAbsOrigin()

		-- mostly fixes error 27 (Invalid order: Target is invisible and is not on the unit's team.)
		if pursuitTarget:HasModifier("modifier_invisible") then
			self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION		
		else
			self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
		end
	end

	self.endTime = GameRules:GetGameTime() + 0.1

	--local distance = math.ceil(thisEntity:GetRangeToUnit(pursuitTarget) - 0.5) -- round to nearest int
	--local speech = string.format(SPEECH_PURSUE_CONTINUE, distance)
	--thisEntity:AddSpeechBubble(SPEECH_ID, speech, SPEECH_DUR_PURSUE, SP_X, SP_Y)
end

function BehaviorPursue:End()
	self.order.TargetIndex = nil
end

function BehaviorPursue:Think(dt)
	-- No longer a valid target, so end this behavior.
	local pursuitTarget = EntIndexToHScript(self.order.TargetIndex)
	if not IsTargetValid(pursuitTarget) then
		self.endTime = GameRules:GetGameTime()
	end
end

--------------------------------------------------------------------------------------------------------
-- Attack behavior

--[[
BehaviorAttack = 
{
	order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = nil
	}
}

function BehaviorAttack:Evaluate()
	local target = FindNearestTarget(thisEntity)
	local attackDesire = 0
	if GameRules:IsDaytime() and IsTargetValid(target) not not target:IsInvisible() then
		attackDesire = 5
	end

	return attackDesire
end

function BehaviorAttack:Initialize()

end

function BehaviorAttack:Begin()
	local target = FindNearestTarget(thisEntity)

	if IsTargetValid(target) then
		self.order.TargetIndex = target:GetEntityIndex()
		self.order.Position = target:GetAbsOrigin()
	end

	self.endTime = GameRules:GetGameTime() + 0.1

	--thisEntity:AddSpeechBubble(SPEECH_ID, SPEECH_PURSUE_BEGIN, SPEECH_DUR, SP_X, SP_Y)
end

function BehaviorAttack:Continue()
	-- important to constantly re-evaluate the closest target (illusions, etc.)
	local target = FindNearestTarget(thisEntity)

	if IsTargetValid(target) then
		self.order.TargetIndex = target:GetEntityIndex()
		self.order.Position = target:GetAbsOrigin()

		-- mostly fixes error 27 (Invalid order: Target is invisible and is not on the unit's team.)
		if target:HasModifier("modifier_invisible") then
			self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION		
		else
			self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
		end
	end

	self.endTime = GameRules:GetGameTime() + 0.1

	--local distance = math.ceil(thisEntity:GetRangeToUnit(target) - 0.5) -- round to nearest int
	--local speech = string.format(SPEECH_PURSUE_CONTINUE, distance)
	--thisEntity:AddSpeechBubble(SPEECH_ID, speech, SPEECH_DUR_PURSUE, SP_X, SP_Y)
end

function BehaviorAttack:End()
	self.order.TargetIndex = nil
end

function BehaviorAttack:Think(dt)
	-- No longer a valid target, so end this behavior.
	local target = EntIndexToHScript(self.order.TargetIndex)
	if not IsTargetValid(target) or target:IsInvisible() then
		self.endTime = GameRules:GetGameTime()
	else
		self.endTime = GameRules:GetGameTime() + 0.5
	end
end
]]

--------------------------------------------------------------------------------------------------------
-- Sprint behavior

BehaviorSprint = 
{
	order = 
	{
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = nil -- This will be filled in later
	}
}

function BehaviorSprint:Evaluate()
	self.sprintAbility = thisEntity:FindAbilityByName("dog_sprint")
	self.order.AbilityIndex = self.sprintAbility:entindex()
	local sprintDesire = 0

	if self:CanSprint() then
		sprintDesire = 10
	end

	return sprintDesire
end

function BehaviorSprint:Initialize()

end

function BehaviorSprint:Begin()
	--thisEntity:CastAbilityNoTarget(self.sprintAbility, -1)
	-- Indicate how long the wander behavior should last
	self.endTime = GameRules:GetGameTime()
	--thisEntity:AddSpeechBubble(SPEECH_ID, SPEECH_SPRINT_BEGIN, SPEECH_DUR, SP_X, SP_Y)
end

-- Continuing this behavior is the same as just beginning it
BehaviorSprint.Continue = BehaviorSprint.Begin

function BehaviorSprint:End()
	-- nothing to do
end

function BehaviorSprint:Think(dt)
	-- Nothing to do
end

function BehaviorSprint:CanSprint()
	local isDaytime = GameRules:IsDaytime()
	local isFed = thisEntity:IsFed()
	local isOutsideMinRange = self:IsOutsideMinRange()
	local canCastSprint = self.sprintAbility:IsFullyCastable() and (thisEntity:FindModifierByName("modifier_dog_sprint") == nil)

	return isDaytime and isFed and isOutsideMinRange and canCastSprint
end

function BehaviorSprint:IsOutsideMinRange()
	local range = 0
	local pursuitTarget = FindNearestTarget(thisEntity)

	if IsTargetValid(pursuitTarget) then
		range = thisEntity:GetRangeToUnit(pursuitTarget)
	end

	return range > self.sprintAbility:GetSpecialValueFor("min_range")
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
	local sleepPriority = 1
	if not GameRules:IsDaytime() then
		sleepPriority = 15
	end
	return sleepPriority
end

function BehaviorSleep:Initialize()

end

function BehaviorSleep:Begin()
	self.order.OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	self.endTime = GameRules:GetGameTime() + 1
	--thisEntity:AddSpeechBubble(SPEECH_ID, SPEECH_SLEEP_BEGIN, SPEECH_DUR, SP_X, SP_Y)
end

function BehaviorSleep:Continue()
	-- Without this, the animation will keep restarting similar to 
	-- spamming hold position on a hero.
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorSleep:End()
	self.order.OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
end

function BehaviorSleep:Think(dt)
end
