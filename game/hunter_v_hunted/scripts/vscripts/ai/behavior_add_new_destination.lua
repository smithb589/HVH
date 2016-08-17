--------------------------------------------------------------------------------------------------------
-- AddNewDestination behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorAddNewDestination == nil then
	BehaviorAddNewDestination = DeclareClass(Behavior, function(self, entity, desire, min_range, max_range)
		self.unit = entity
		self.desire = desire or DESIRE_LOW
		self.min_range = min_range or 400.0
		self.max_range = max_range or 99999.0
		Behavior.init(self)
	end)
end

function BehaviorAddNewDestination:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
end

function BehaviorAddNewDestination:Evaluate()
	local desire = DESIRE_NONE

	-- if the current destination is within minimum range, then we are ready for a new one
	if HVHNeutralCreeps:HasDestination(self.unit) then
		local destination = HVHNeutralCreeps:GetDestination(self.unit)		
		if AICore:IsVectorInRange(self.unit, destination, 0, self.min_range) then
			desire = self.desire --DESIRE_LOW
		end
	end

	--print(desire .. ": add new destination")
	return desire
end

function BehaviorAddNewDestination:Begin()
	--print("Adding new destination")
	HVHNeutralCreeps:AddDestination(self.unit, self.min_range, self.max_range)
end

function BehaviorAddNewDestination:Continue()
end

function BehaviorAddNewDestination:End()
end

function BehaviorAddNewDestination:Think(dt)
end