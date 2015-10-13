--------------------------------------------------------------------------------------------------------
-- AttackTarget behavior
-- Attack a target single-mindedly
--------------------------------------------------------------------------------------------------------
if BehaviorAttackTarget == nil then
	BehaviorAttackTarget = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		Behavior.init(self)
	end)
end

function BehaviorAttackTarget:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
	self.order.TargetIndex  = nil -- set later
end

function BehaviorAttackTarget:Evaluate()
	local desire = DESIRE_NONE

	local target = HVHNeutralCreeps:GetTarget(self.unit)
	if AICore:IsTargetValid(target) then
		desire = self.desire --DESIRE_HIGH
	end

	return desire
end

function BehaviorAttackTarget:Begin()
	local target = HVHNeutralCreeps:GetTarget(self.unit)
	self.order.TargetIndex = target:entindex()
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorAttackTarget:Continue()
end

function BehaviorAttackTarget:End()
end

function BehaviorAttackTarget:Think(dt)
end