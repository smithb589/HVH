--------------------------------------------------------------------------------------------------------
-- Travel behavior
-- Move from Point A to Point B
--------------------------------------------------------------------------------------------------------
if BehaviorTravel == nil then
	BehaviorTravel = DeclareClass(Behavior, function(self, entity, desire, min_range)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		self.min_range = min_range or 400.0
		Behavior.init(self)
	end)
end

function BehaviorTravel:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION
	self.order.Position  = nil
end

function BehaviorTravel:Evaluate()
	local desire = DESIRE_NONE

	if HVHNeutralCreeps:HasDestination(self.unit) then 
		local destination = HVHNeutralCreeps:GetDestination(self.unit)
		if AICore:IsVectorInRange(self.unit, destination, self.min_range) then
			desire = self.desire --DESIRE_HIGH
		end
	end

	--print(desire .. ": travel")
	return desire
end

function BehaviorTravel:Begin()
	self.order.Position = HVHNeutralCreeps:GetDestination(self.unit)
	--AICore:DebugDraw(self.unit:GetAbsOrigin(), self.order.Position, Vector(0,0,255), 10.0)	
	--self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorTravel:Continue()
end

function BehaviorTravel:End()
end

function BehaviorTravel:Think(dt)
end