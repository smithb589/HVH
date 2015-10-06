--------------------------------------------------------------------------------------------------------
-- Sprint behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorSprint == nil then
	BehaviorSprint = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorSprint:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET
	self.order.AbilityIndex = nil -- TODO: FIX
end

-- If isDaytime/isFed/isOutsideMinRange(unused)/canCastSprint, then use Sprint ability
function BehaviorSprint:Evaluate()
	self.sprintAbility = self.unit:FindAbilityByName("dog_sprint")
	self.order.AbilityIndex = self.sprintAbility:entindex()
	local sprintDesire = DESIRE_NONE

	if self:CanSprint() then
		sprintDesire = self.desire --DESIRE_MAX
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
	local isFed = self.unit:IsFed()
	local isOutsideMinRange = self:IsOutsideMinRange()
	local canCastSprint = self.sprintAbility:IsFullyCastable() and (self.unit:FindModifierByName("modifier_dog_sprint") == nil)

	return isDaytime and isFed and isOutsideMinRange and canCastSprint
end

function BehaviorSprint:IsOutsideMinRange()
	local range = 0
	local pursuitTarget = HVHDogUtils:FindNearestTarget(self.unit)

	if HVHDogUtils:IsTargetValid(pursuitTarget) then
		range = self.unit:GetRangeToUnit(pursuitTarget)
	end

	return range > self.sprintAbility:GetSpecialValueFor("min_range")
end