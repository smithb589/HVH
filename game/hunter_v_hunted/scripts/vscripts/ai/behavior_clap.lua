--------------------------------------------------------------------------------------------------------
-- Hellbear Thunder Clap behavior
--------------------------------------------------------------------------------------------------------
if BehaviorClap == nil then
	BehaviorClap = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorClap:Setup()
	self.name = "Clap"
	self.clapAbility = self.unit:FindAbilityByName("polar_furbolg_ursa_warrior_thunder_clap")
	self.order.AbilityIndex  = self.clapAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET

	-- small delay needed after unit spawn or radius = 0
	Timers:CreateTimer(SINGLE_FRAME_TIME, function()
		self.radius = self.clapAbility:GetSpecialValueFor("radius")
	end)	
end

function BehaviorClap:Evaluate()
	local desire = DESIRE_NONE

	--if AICore:AreEnemiesInRange(self.unit, self.radius, 3) and self.clapAbility:IsFullyCastable() then
	if self.clapAbility:IsFullyCastable() then
		desire = self.desire --DESIRE_MAX
	end

	return desire
end

function BehaviorClap:Begin()
	--print("begin/continue")
	self.endTime = GameRules:GetGameTime() + self.clapAbility:GetCastPoint()
end

function BehaviorClap:Continue()
end

function BehaviorClap:End()
	-- nothing to do
end

function BehaviorClap:Think(dt)
	-- Nothing to do
end