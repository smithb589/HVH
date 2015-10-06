--------------------------------------------------------------------------------------------------------
-- Slam behavior
--------------------------------------------------------------------------------------------------------
if BehaviorSlam == nil then
	BehaviorSlam = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorSlam:Setup()
	self.slamAbility = self.unit:FindAbilityByName("polar_furbolg_ursa_warrior_thunder_clap")
	self.order.AbilityIndex  = self.slamAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET

	-- small delay needed after unit spawn or radius = 0
	Timers:CreateTimer(SINGLE_FRAME_TIME, function()
		self.radius = self.slamAbility:GetSpecialValueFor("radius")
	end)	
end

function BehaviorSlam:Evaluate()
	local slamDesire = DESIRE_NONE

	if AICore:AreEnemiesInRange(self.unit, self.radius, 3) and self.slamAbility:IsFullyCastable() then
		slamDesire = self.desire --DESIRE_MAX
	end

	return slamDesire
end

function BehaviorSlam:Begin()
	--print("begin/continue")
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorSlam:Continue()
end

function BehaviorSlam:End()
	-- nothing to do
end

function BehaviorSlam:Think(dt)
	-- Nothing to do
end