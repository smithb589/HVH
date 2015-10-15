--------------------------------------------------------------------------------------------------------
-- TravelAggressive behavior
-- Move from Point A to Point B
--------------------------------------------------------------------------------------------------------
if BehaviorTravelAggressive == nil then
	BehaviorTravelAggressive = DeclareClass(BehaviorTravel, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		Behavior.init(self)
	end)
end

function BehaviorTravelAggressive:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE
	self.order.Position  = nil
end