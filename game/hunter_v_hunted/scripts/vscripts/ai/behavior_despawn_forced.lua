--------------------------------------------------------------------------------------------------------
-- DespawnForced behavior
--------------------------------------------------------------------------------------------------------
if BehaviorDespawnForced == nil then
	BehaviorDespawnForced = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_NONE+1
		Behavior.init(self)
	end)
end

function BehaviorDespawnForced:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.killAfter = 0.1
end

function BehaviorDespawnForced:Evaluate()
	return self.desire -- DESIRE_NONE+1
end

function BehaviorDespawnForced:Begin()
	self.endTime = GameRules:GetGameTime() + self.killAfter
end

function BehaviorDespawnForced:Continue()
	--print("Forced despawn")
	self.unit:ForceKill(false)
end

function BehaviorDespawnForced:End()
end

function BehaviorDespawnForced:Think(dt)
end
