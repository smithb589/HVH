--------------------------------------------------------------------------------------------------------
-- Earthshock behavior
--------------------------------------------------------------------------------------------------------
if BehaviorEarthshock == nil then
	BehaviorEarthshock = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorEarthshock:Setup()
	self.name = "Earthshock"
	self.earthshockAbility = self.unit:FindAbilityByName("ursa_earthshock")
	self.order.AbilityIndex  = self.earthshockAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET

	-- small delay needed after unit spawn or radius = 0
	Timers:CreateTimer(SINGLE_FRAME_TIME, function()
		self.radius = self.earthshockAbility:GetSpecialValueFor("shock_radius")
	end)	
end

function BehaviorEarthshock:Evaluate()
	local desire = DESIRE_NONE

	if self.unit.killedRoshan then
		if AICore:AreEnemiesInRange(self.unit, self.radius, 1) and self.earthshockAbility:IsFullyCastable() then
			desire = self.desire --DESIRE_MAX
		end
	end

	return desire
end

function BehaviorEarthshock:Begin()
	--print("begin/continue")
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorEarthshock:Continue()
end

function BehaviorEarthshock:End()
	-- nothing to do
end

function BehaviorEarthshock:Think(dt)
	-- Nothing to do
end