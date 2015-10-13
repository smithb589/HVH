--------------------------------------------------------------------------------------------------------
-- Wait behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorWait == nil then
	BehaviorWait = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_NONE+1
		Behavior.init(self)
	end)
end

function BehaviorWait:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
end

function BehaviorWait:Evaluate()
	return self.desire
end

function BehaviorWait:Begin()
end

function BehaviorWait:Continue()
end

function BehaviorWait:End()
end

function BehaviorWait:Think(dt)
end