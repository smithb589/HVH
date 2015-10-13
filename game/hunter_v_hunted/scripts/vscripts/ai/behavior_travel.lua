--------------------------------------------------------------------------------------------------------
-- Travel behavior
-- Move from Point A to Point B
--------------------------------------------------------------------------------------------------------
if BehaviorTravel == nil then
	BehaviorTravel = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		Behavior.init(self)
	end)
end

function BehaviorTravel:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION
	self.order.Position  = nil
end

function BehaviorTravel:Evaluate()
	local range = 400.0
	local desire = DESIRE_NONE

	if HVHNeutralCreeps:HasDestination(self.unit) and
 	  Length2DBetweenVectors(self.unit:GetAbsOrigin(), HVHNeutralCreeps:GetDestination(self.unit)) > range
 	  then
		desire = self.desire --DESIRE_HIGH
	end

	return desire
end

function BehaviorTravel:Begin()
	print("Travel BEGIN")
	self.order.Position = HVHNeutralCreeps:GetDestination(self.unit)
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorTravel:Continue()
end

function BehaviorTravel:End()
end

function BehaviorTravel:Think(dt)
end