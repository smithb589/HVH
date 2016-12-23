--------------------------------------------------------------------------------------------------------
-- AttackTargetAggressive behavior
-- Attack a previously declared target, attacking other enemy targets along the way
-- Will stop pursuing non-declared targets when out of vision range
--------------------------------------------------------------------------------------------------------
if BehaviorAttackTargetAggressive == nil then
	BehaviorAttackTargetAggressive = DeclareClass(BehaviorAttackTarget, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		Behavior.init(self)
	end)
end

function BehaviorAttackTargetAggressive:Setup()
	self.name = "AttackTargetAggressive"
	self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE
	self.order.Position = nil
	self.order.TargetIndex  = nil -- set later
end