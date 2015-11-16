--------------------------------------------------------------------------------------------------------
-- Blackhole behavior
--------------------------------------------------------------------------------------------------------
if BehaviorBlackhole == nil then
	BehaviorBlackhole = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		Behavior.init(self)
	end)
end

function BehaviorBlackhole:Setup()
	self.blackholeAbility = self.unit:FindAbilityByName("enigma_black_hole")
	self.order.AbilityIndex  = self.blackholeAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE -- changed later
	self.order.Position = nil -- calculated later

	-- small delay needed after unit spawn or radius = 0
	Timers:CreateTimer(SINGLE_FRAME_TIME, function()
		self.radius = self.blackholeAbility:GetSpecialValueFor("far_radius")
		self.range = self.blackholeAbility:GetCastRange()
		self.maxRange = self.range + self.radius
		self.channelTime = self.blackholeAbility:GetChannelTime()
	end)	
end

function BehaviorBlackhole:Evaluate()
	local desire = DESIRE_NONE
	--print("Blackhole Evaluate")

	if AICore:AreEnemiesInRange(self.unit, self.maxRange, 2) and self.blackholeAbility:IsFullyCastable() and not self.unit:IsChanneling() then
		--print("1. At least two enemies in range and spell fully castable.")
		local targets = AICore:GetEnemiesInRange(self.unit, self.maxRange)
		local t1 = targets[1]
		local t2 = targets[2]
		local distanceBetweenClosestTargets = t1:GetRangeToUnit(t2)
		if distanceBetweenClosestTargets <= self.radius * 2 then
			--print("2. Closest 2 targets can fit in diameter of black hole.")
			local midpoint_loc = self:FindMidPoint(t1, t2)
			local enigma_loc = self.unit:GetAbsOrigin()
			if AICore:IsVectorInRange(self.unit, midpoint_loc, self.range) then
				--print("3. Midpoint close enough to target.")
				self.order.Position = midpoint_loc
				desire = self.desire --DESIRE_MAX
			else
				--print("FAILED: Enigma is too lazy to move into attack range")
			end
		else
			--print("FAILED: Closest 2 targets too far apart!!")
		end
	end

	return desire
end

function BehaviorBlackhole:Begin()
	--print("Blackhole BEGIN")
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_POSITION
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorBlackhole:Continue()
	--print("Blackhole CONTINUE")
	--self.order.OrderType = DOTA_UNIT_ORDER_NONE -- channeling
	--self.endTime = GameRules:GetGameTime() + self.channelTime + 1.0 -- extra leeway for turn time
end

function BehaviorBlackhole:End()
	--print("Blackhole END")
	--self.order.OrderType = DOTA_UNIT_ORDER_NONE -- changed later
	--self.order.Position = nil -- calculated later
end

function BehaviorBlackhole:Think(dt)
	-- Nothing to do
end

function BehaviorBlackhole:FindMidPoint(unit1, unit2)
	local v1 = unit1:GetAbsOrigin()
	local v2 = unit2:GetAbsOrigin()

	local mid = (v1+v2) / 2

	return mid
end