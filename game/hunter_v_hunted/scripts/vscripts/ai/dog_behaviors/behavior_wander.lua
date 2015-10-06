--------------------------------------------------------------------------------------------------------
-- Wander behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorWander == nil then
	BehaviorWander = DeclareClass(Behavior, function(self, entity, desireWhenAfraid, desireWhenInvisEnemyIsNear)
		self.unit = entity
		self.desireWhenAfraid = desireWhenAfraid or DESIRE_MAX
		self.desireWhenInvisEnemyIsNear = desireWhenInvisEnemyIsNear or DESIRE_MEDIUM
		Behavior.init(self)
	end)
end

function BehaviorWander:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION
	self.order.Position  = self.unit:GetAbsOrigin()
end

-- Nothing better to do, afraid, or Warn on cooldown? Might as well wander.
function BehaviorWander:Evaluate()
	local wanderDesire = DESIRE_NONE + 1 -- takes priority over other DESIRE_NONEs
	local nearestTarget = HVHDogUtils:FindNearestTarget(self.unit)

	-- affected by crippling fear
	if self.unit:HasModifier("modifier_crippling_fear_dog_datadriven") or
	   self.unit:HasModifier("modifier_crippling_fear_dog_aoe_datadriven") then
	   wanderDesire = self.desireWhenAfraid --DESIRE_MAX
	
	-- invis-wandering
	elseif HVHDogUtils:IsInvisibleTargetInWanderRange(self.unit, nearestTarget) then
		wanderDesire = self.desireWhenInvisEnemyIsNear --DESIRE_MEDIUM
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
	local moveSpeed = self.unit:GetMoveSpeedModifier(self.unit:GetBaseMoveSpeed())
	local wanderDuration = self.unit._MaxWanderingDistance / moveSpeed
	return wanderDuration
end

function BehaviorWander:GetWanderDestination()
	local wanderingDelta = RandomVector(self.unit._MaxWanderingDistance)
	local wanderingDestination = self.unit._WanderingOrigin + wanderingDelta
	return wanderingDestination
end

function BehaviorWander:_DetermineWanderOrigin()
	-- This should maybe be a different behavior since it branches...
	local nearestTarget = HVHDogUtils:FindNearestTarget(self.unit)
	if HVHDogUtils:IsTargetValid(nearestTarget) and nearestTarget:IsInvisible() then
		self.unit._WanderingOrigin = nearestTarget:GetAbsOrigin()
	else
		self.unit._WanderingOrigin = self.unit:GetAbsOrigin()
	end
end