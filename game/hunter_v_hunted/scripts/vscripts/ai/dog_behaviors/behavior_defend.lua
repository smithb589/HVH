--------------------------------------------------------------------------------------------------------
-- Defend behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorDefend == nil then
	BehaviorDefend = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		Behavior.init(self)
	end)
end

function BehaviorDefend:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.order.TargetIndex = nil
end

-- During the night, attack nearest visible enemy
function BehaviorDefend:Evaluate()
	local defendDesire = DESIRE_NONE
	local target = HVHDogUtils:FindNearestTarget(self.unit, true)

	if not GameRules:IsDaytime() and self:CanDefendAgainst(target) then
		defendDesire = self.desire --DESIRE_HIGH
	end

	return defendDesire
end

function BehaviorDefend:Begin()
	--print("Begin/continue defend")
	local target = HVHDogUtils:FindNearestTarget(self.unit, true)

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
	return self.unit:GetRangeToUnit(target) <= self.unit._MaxDefendRange
end

function BehaviorDefend:CanSeeTarget(target)
	return self.unit:CanEntityBeSeenByMyTeam(target)
end

function BehaviorDefend:CanDefendAgainst(target)
	return HVHDogUtils:IsTargetValid(target) and self:CanSeeTarget(target) and self:IsTargetInDefendRange(target)
end
