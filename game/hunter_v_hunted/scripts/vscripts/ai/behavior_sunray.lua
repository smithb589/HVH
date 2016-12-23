--------------------------------------------------------------------------------------------------------
-- Phoenix Sun Ray
--------------------------------------------------------------------------------------------------------
if BehaviorSunRay == nil then
	BehaviorSunRay = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorSunRay:Setup()
	self.name = "SunRay"
	self.sunRayAbility = self.unit:FindAbilityByName("phoenix_sun_ray")
	self.order.AbilityIndex  = self.sunRayAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_POSITION
	self.order.Position = nil
end

function BehaviorSunRay:Evaluate()
	local desire = DESIRE_NONE

	if self.sunRayAbility:IsFullyCastable() and not self.sunRayAbility:IsHidden() then
		desire = self.desire --DESIRE_MAX
	end

	--print(desire .. ": sunray")
	return desire
end

function BehaviorSunRay:Begin()
    local origin = self.unit:GetAbsOrigin()
    local fv = self.unit:GetForwardVector()
    local distance = 300.0
    -- Gets the vector facing *distance* units away from the origin
	self.order.Position = origin + fv * distance
	self.endTime = GameRules:GetGameTime() + 0.1
	--AICore:DebugDraw(origin, self.order.Position, Vector(255,0,0), 10.0)
end

function BehaviorSunRay:Continue()
end

function BehaviorSunRay:End()
end

function BehaviorSunRay:Think(dt)
	-- Nothing to do
end