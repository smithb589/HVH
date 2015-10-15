--------------------------------------------------------------------------------------------------------
-- Enrage behavior
--------------------------------------------------------------------------------------------------------
if BehaviorEnrage == nil then
	BehaviorEnrage = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorEnrage:Setup()
	self.enrageAbility = self.unit:FindAbilityByName("ursa_enrage")
	self.order.AbilityIndex  = self.enrageAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET
end

function BehaviorEnrage:Evaluate()
	local desire = DESIRE_NONE
	local radius = 300.0

	if self.unit.killedRoshan then
		if AICore:AreEnemiesInRange(self.unit, radius, 1) and self.enrageAbility:IsFullyCastable() then
			desire = self.desire --DESIRE_MAX
		end
	end

	return desire
end

function BehaviorEnrage:Begin()
	--print("begin/continue")
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorEnrage:Continue()
end

function BehaviorEnrage:End()
	-- nothing to do
end

function BehaviorEnrage:Think(dt)
	-- Nothing to do
end