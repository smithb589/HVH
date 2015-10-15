--------------------------------------------------------------------------------------------------------
-- AttackTarget behavior
-- Attack a previously declared target, ignoring targets along the way
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
	self.order.Position = nil
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
	self.order.Position = target:GetAbsOrigin()
	--self:AttackAlongTheWay()
	--self.endTime = GameRules:GetGameTime() + 1.0
end

BehaviorAttackTarget.Continue = BehaviorAttackTarget.Begin

function BehaviorAttackTarget:End()
	self.order.Position = nil
	self.order.TargetIndex = nil
end

function BehaviorAttackTarget:Think(dt)
end