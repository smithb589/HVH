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
	self.order.Position  = nil -- This will be filled in later
end

function BehaviorTravel:Evaluate()
	local range = 100.0

	if self.order.Position ~= nil and Length2DBetweenVectors(self.unit:GetAbsOrigin(), self.order.Position) < range then
		return DESIRE_NONE
	else
		return self.desire --DESIRE_HIGH
	end
end

function BehaviorTravel:Begin()
	self.order.Position = self.unit.destinationLoc -- determined in HVHNeutralCreeps
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorTravel:Continue()
end

function BehaviorTravel:End()
end

function BehaviorTravel:Think(dt)
end