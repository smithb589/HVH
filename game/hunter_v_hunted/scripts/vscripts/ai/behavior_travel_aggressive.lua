--------------------------------------------------------------------------------------------------------
-- TravelAggressive behavior
-- Attack-Move from Point A to Point B
--------------------------------------------------------------------------------------------------------
if BehaviorTravelAggressive == nil then
	BehaviorTravelAggressive = DeclareClass(BehaviorTravel, function(self, entity, desire, min_range)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		self.min_range = min_range or 400.0		
		Behavior.init(self)
	end)
end

function BehaviorTravelAggressive:Setup()
	self.name = "TravelAggressive"
	self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE
	self.order.Position  = nil
end

-- inherits from BehaviorTravel