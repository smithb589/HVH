--------------------------------------------------------------------------------------------------------
-- ChooseNextDestination behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorChooseNextDestination == nil then
	BehaviorChooseNextDestination = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MEDIUM
		Behavior.init(self)
	end)
end

function BehaviorChooseNextDestination:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
end

function BehaviorChooseNextDestination:Evaluate()
	local desire = DESIRE_NONE

	if HVHNeutralCreeps:HasDestination(self.unit) and
	   HVHNeutralCreeps:IsNextDestinationValid(self.unit) then
		desire = self.desire --DESIRE_MEDIUM
	else
		-- ran out of destinations
	end

	return desire
end

function BehaviorChooseNextDestination:Begin()
	HVHNeutralCreeps:NextDestination(self.unit)
end

function BehaviorChooseNextDestination:Continue()
end

function BehaviorChooseNextDestination:End()
end

function BehaviorChooseNextDestination:Think(dt)
end