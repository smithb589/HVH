require("ai/ai_dog_speech")
require("ai/ai_core")
require("hvh_utils")

behaviorSystem = {}

DESIRE_NONE   = 0
DESIRE_LOW    = 5
DESIRE_MEDIUM = 10
DESIRE_HIGH   = 15
DESIRE_MAX	  = 20

function Spawn( entityKeyValues )

	thisEntity.FedBy = function(self, lastFeeder, feedDuration, loyaltyDuration)
		if self._LastFeeder then
			RemoveLoyaltyBuff(self._LastFeeder)
		end

		self._LastFeeder = lastFeeder
		self._FeedDuration = feedDuration
		self._LoyaltyDuration = loyaltyDuration

		self._FeedTime = GameRules:GetGameTime()
		self._LoyaltyEndsAt = self._FeedTime + self._LoyaltyDuration

		ApplyLoyaltyBuff(lastFeeder)
		--print("LOYALTY ENDS AT: " .. self._LoyaltyEndsAt)
	end

	thisEntity.IsFed = function(self)
		local currentTime = GameRules:GetGameTime() 
		return (self._FeedTime + self._FeedDuration) > currentTime
	end

	-- This stores the location we started wandering from so the dog
	-- can't just run across the entire map.
	thisEntity._WanderingOrigin = Vector(0, 0)
	thisEntity._MaxWanderingDistance = 500.0 --150.0
	thisEntity._MaxDefendRange = thisEntity:GetNightTimeVisionRange()

	thisEntity._LastFeeder = nil
	thisEntity._LoyaltyDuration = 0
	thisEntity._FeedDuration = 0
	-- Arbitrarily age this so the dog doesn't start fed.
	thisEntity._FeedTime = GameRules:GetGameTime() - 60
	thisEntity._LoyaltyEndsAt = 0

	thisEntity._LastWarnTime = 0.0

	thisEntity:SetContextThink("ThinkDog", ThinkDog, 0.1)
	behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorWander,
		BehaviorWarn,
		BehaviorPursue,
		BehaviorSprint,
		BehaviorSleep,
		BehaviorFollow,
		BehaviorDefend
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

function FindNearestTarget(entity, fow_visible)
	local fow_visible = fow_visible or false -- overloaded

	local flags = DOTA_UNIT_TARGET_FLAG_NONE
	if fow_visible then
		flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	end

	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
								 	entity:GetAbsOrigin(),
									nil,
									FIND_UNITS_EVERYWHERE,
									DOTA_UNIT_TARGET_TEAM_FRIENDLY,
									DOTA_UNIT_TARGET_HERO,
									flags,
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

function ApplyLoyaltyBuff(target)
	local ability = target:FindAbilityByName("sniper_feed_dog")
	local buff = "modifier_feed_dog_loyalty"
	local dur = thisEntity._LoyaltyDuration
	ability:ApplyDataDrivenModifier(thisEntity, target, buff, { duration = dur })
end

function RemoveLoyaltyBuff(target)
	target:RemoveModifierByName("modifier_feed_dog_loyalty")
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

-- Nothing better to do, afraid, or Warn on cooldown? Might as well wander.
function BehaviorWander:Evaluate()
	local wanderDesire = DESIRE_NONE + 1 -- takes priority over other DESIRE_NONEs
	local nearestTarget = FindNearestTarget(thisEntity)

	-- affected by crippling fear
	if thisEntity:HasModifier("modifier_crippling_fear_dog_datadriven") or
	   thisEntity:HasModifier("modifier_crippling_fear_dog_aoe_datadriven") then
	   wanderDesire = DESIRE_MAX
	
	-- invis-wandering
	elseif IsInvisibleTargetInWanderRange(nearestTarget) then
		wanderDesire = DESIRE_MEDIUM
	end

	return wanderDesire
end

function BehaviorWander:Begin()
	self:_DetermineWanderOrigin()
	self.order.Position = self:GetWanderDestination()

	-- Indicate how long the wander behavior should last
	self.endTime = GameRules:GetGameTime() + self:GetWanderDuration()
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

	warnDuration = 1.0,
	delayBetweenWarns = 4.0 --2.0
}

-- (Day/night) Howl if invisible target is near and you haven't howled recently
function BehaviorWarn:Evaluate()
	local target = FindNearestTarget(thisEntity)
	local warnDesire = DESIRE_NONE
	if IsInvisibleTargetInWanderRange(target) and self:_CanWarn() then
		warnDesire = DESIRE_HIGH
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
	--thisEntity:StartGesture(ACT_DOTA_ATTACK)
	
	Timers:CreateTimer(SINGLE_FRAME_TIME, function()
		StartAnimation(thisEntity, {duration=self.warnDuration, activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1.0})
		thisEntity:EmitSound("Lycan_Wolf.PreAttack")
	end)
	
	thisEntity._LastWarnTime = GameRules:GetGameTime()
end

function BehaviorWarn:_CanWarn()
	-- Only try to warn every few seconds.
	return thisEntity._LastWarnTime < (GameRules:GetGameTime() - self.delayBetweenWarns)
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

-- During the day, pursue the nearest valid enemy target
function BehaviorPursue:Evaluate()
	local target = FindNearestTarget(thisEntity)
	local pursueDesire = DESIRE_NONE
	if GameRules:IsDaytime() and IsTargetValid(target) then
		pursueDesire = DESIRE_LOW
	end

	return pursueDesire
end

function BehaviorPursue:Begin()
	local pursuitTarget = FindNearestTarget(thisEntity)

	if IsTargetValid(pursuitTarget) then
		self.order.TargetIndex = pursuitTarget:GetEntityIndex()
		self.order.Position = pursuitTarget:GetAbsOrigin()
	end

	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorPursue:Continue()
	-- important to constantly re-evaluate the closest target (illusions, etc.)
	local pursuitTarget = FindNearestTarget(thisEntity)

	if IsTargetValid(pursuitTarget) then
		self.order.TargetIndex = pursuitTarget:GetEntityIndex()
		self.order.Position = pursuitTarget:GetAbsOrigin()

		-- mostly fixes error 27 (Invalid order: Target is invisible and is not on the unit's team.)
		if not thisEntity:CanEntityBeSeenByMyTeam(pursuitTarget) then
			self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION
		else
			self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
		end
	end

	self.endTime = GameRules:GetGameTime() + 0.1
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

-- If isDaytime/isFed/isOutsideMinRange(unused)/canCastSprint, then use Sprint ability
function BehaviorSprint:Evaluate()
	self.sprintAbility = thisEntity:FindAbilityByName("dog_sprint")
	self.order.AbilityIndex = self.sprintAbility:entindex()
	local sprintDesire = DESIRE_NONE

	if self:CanSprint() then
		sprintDesire = DESIRE_MAX
	end

	return sprintDesire
end

function BehaviorSprint:Begin()
	self.endTime = GameRules:GetGameTime()
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
		OrderType = DOTA_UNIT_ORDER_HOLD_POSITION,
		AbilityIndex = nil
	}
}

-- Stop moving at night if there's nothing better to do
function BehaviorSleep:Evaluate()
	local sleepPriority = DESIRE_NONE
	if not GameRules:IsDaytime() then
		sleepPriority = DESIRE_LOW
	end
	return sleepPriority
end

function BehaviorSleep:Begin()
	--print("Begin sleep")
	local sleepAbility = thisEntity:FindAbilityByName("dog_sleep")
	local fade_delay = sleepAbility:GetSpecialValueFor("fade_delay")
	self.order.AbilityIndex = sleepAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_HOLD_POSITION

	StartAnimation(thisEntity, {duration=fade_delay, activity=ACT_DOTA_IDLE_RARE, rate=1.0})
	sleepAbility:ApplyDataDrivenModifier(thisEntity, thisEntity, "modifier_sleep_fade", {})

	self.endTime = GameRules:GetGameTime() + fade_delay
end

function BehaviorSleep:Continue()
	-- Without this, the animation will keep restarting similar to 
	-- spamming hold position on a hero.
	--print("Continue sleep")
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorSleep:End()
	--print("Remove sleep")
	self.order.OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	
	if thisEntity:HasModifier("modifier_sleep") then
		thisEntity:RemoveModifierByName("modifier_sleep")
	end
end

function BehaviorSleep:Think(dt)
end

--------------------------------------------------------------------------------------------------------
-- Follow behavior

BehaviorFollow = 
{
	order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
		TargetIndex = nil
	}
}

-- If it's night and someone fed the dog recently, then follow that man
-- (The "last feeder" is the Sniper who most recently fed the dog)
function BehaviorFollow:Evaluate()
	local followDesire = DESIRE_NONE
	local lastFeeder = thisEntity._LastFeeder

	if not GameRules:IsDaytime() and IsTargetValid(lastFeeder) and self:IsStillLoyalTo(lastFeeder) then
		followDesire = DESIRE_MEDIUM + 1 -- takes priority over invis-wandering
	end

	return followDesire
end

function BehaviorFollow:Begin()
	--print("Begin follow")
	local lastFeeder = thisEntity._LastFeeder
	self.order.TargetIndex = lastFeeder:GetEntityIndex()

	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorFollow:Continue()
	--print("Continue follow @" .. GameRules:GetGameTime())
	local lastFeeder = thisEntity._LastFeeder
	local lastFeederIndex = lastFeeder:GetEntityIndex()

	-- if the last feeder is no longer our move-to target, then switch feeder
	if lastFeederIndex ~= self.order.TargetIndex then
		self:SwitchFeeder(lastFeederIndex)
	end

	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorFollow:End()
	self.order.TargetIndex = nil
end

function BehaviorFollow:Think(dt)
end

-- update target of move-to command and reset loyalty timer
function BehaviorFollow:SwitchFeeder(newTargetIndex)
	--print("SWITCH FEEDER")
	self.order.TargetIndex = newTargetIndex
	--thisEntity._LoyaltyEndsAt = GameRules:GetGameTime() + thisEntity._LoyaltyDuration
end

function BehaviorFollow:IsStillLoyalTo(target)
	return GameRules:GetGameTime() <= thisEntity._LoyaltyEndsAt
end

--------------------------------------------------------------------------------------------------------
-- Defend behavior

BehaviorDefend = 
{
	order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_NONE,
		TargetIndex = nil
	}
}

-- During the night, attack nearest visible enemy
function BehaviorDefend:Evaluate()
	local defendDesire = DESIRE_NONE
	local target = FindNearestTarget(thisEntity, true)

	if not GameRules:IsDaytime() and self:CanDefendAgainst(target) then
		defendDesire = DESIRE_HIGH
	end

	return defendDesire
end

function BehaviorDefend:Begin()
	--print("Begin/continue defend")
	local target = FindNearestTarget(thisEntity, true)

	if self:CanDefendAgainst(target) then
		self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
		self.order.TargetIndex = target:GetEntityIndex()
	end

	self.endTime = GameRules:GetGameTime() + 0.1
end

-- Continuing this behavior is the same as just beginning it
BehaviorDefend.Continue = BehaviorDefend.Begin

function BehaviorDefend:End()
	--print("End defend")
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.order.TargetIndex = nil
end

function BehaviorDefend:Think(dt)
end

function BehaviorDefend:IsTargetInDefendRange(target)
	return thisEntity:GetRangeToUnit(target) <= thisEntity._MaxDefendRange
end

function BehaviorDefend:CanSeeTarget(target)
	return thisEntity:CanEntityBeSeenByMyTeam(target)
end

function BehaviorDefend:CanDefendAgainst(target)
	return IsTargetValid(target) and self:CanSeeTarget(target) and self:IsTargetInDefendRange(target)
end
