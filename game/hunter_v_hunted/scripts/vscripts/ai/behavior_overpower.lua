--------------------------------------------------------------------------------------------------------
-- Overpower behavior
--------------------------------------------------------------------------------------------------------
if BehaviorOverpower == nil then
	BehaviorOverpower = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorOverpower:Setup()
	self.name = "Overpower"
	self.overpowerAbility = self.unit:FindAbilityByName("ursa_overpower")
	self.order.AbilityIndex  = self.overpowerAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET
end

function BehaviorOverpower:Evaluate()
	local desire = DESIRE_NONE
	local radius = 800.0

	if AICore:AreEnemiesInRange(self.unit, radius, 1) and self.overpowerAbility:IsFullyCastable() then
		desire = self.desire --DESIRE_MAX
	end

	return desire
end

function BehaviorOverpower:Begin()
	--print("begin/continue")
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorOverpower:Continue()
end

function BehaviorOverpower:End()
	-- nothing to do
end

function BehaviorOverpower:Think(dt)
	-- Nothing to do
end