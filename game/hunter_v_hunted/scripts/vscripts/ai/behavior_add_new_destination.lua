--------------------------------------------------------------------------------------------------------
-- AddNewDestination behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorAddNewDestination == nil then
	BehaviorAddNewDestination = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_LOW
		Behavior.init(self)
	end)
end

function BehaviorAddNewDestination:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
end

function BehaviorAddNewDestination:Evaluate()
	local desire = DESIRE_NONE

	if not HVHNeutralCreeps:HasDestination(self.unit) then
		desire = self.desire --DESIRE_LOW
	end

	return desire
end

function BehaviorAddNewDestination:Begin()
	--print("Adding new destination")
	HVHNeutralCreeps:AddDestination(self.unit, RANGE_TECHIES_MIN, RANGE_TECHIES_MAX)
end

function BehaviorAddNewDestination:Continue()
end

function BehaviorAddNewDestination:End()
end

function BehaviorAddNewDestination:Think(dt)
end