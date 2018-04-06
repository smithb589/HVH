--------------------------------------------------------------------------------------------------------
-- Phoenix Supernova
--------------------------------------------------------------------------------------------------------
if BehaviorSupernova == nil then
	BehaviorSupernova = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorSupernova:Setup()
	self.name = "Supernova"
	self.supernovaAbility = self.unit:FindAbilityByName("phoenix_supernova_hvh")
	self.order.AbilityIndex  = self.supernovaAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_TOGGLE
end

function BehaviorSupernova:Evaluate()
	local desire = DESIRE_NONE
	local toggled =  self.supernovaAbility:GetToggleState()

	if toggled and GameRules:IsDaytime() then
		desire = self.desire --DESIRE_MAX
	elseif not toggled and not GameRules:IsDaytime() then
		desire = self.desire --DESIRE_MAX
	end

	return desire
end

function BehaviorSupernova:Begin()
	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorSupernova:Continue()

end

function BehaviorSupernova:End()
end

function BehaviorSupernova:Think(dt)
end