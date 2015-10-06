--------------------------------------------------------------------------------------------------------
-- Warn behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorWarn == nil then
	BehaviorWarn = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		Behavior.init(self)
	end)
end

function BehaviorWarn:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.warnDuration = 1.0
	self.delayBetweenWarns = 4.0 --2.0
end

-- (Day/night) Howl if invisible target is near and you haven't howled recently
function BehaviorWarn:Evaluate()
	local target = HVHDogUtils:FindNearestTarget(self.unit)
	local warnDesire = DESIRE_NONE
	if HVHDogUtils:IsInvisibleTargetInWanderRange(self.unit, target) and self:_CanWarn() then
		warnDesire = self.desire --DESIRE_HIGH
	end

	return warnDesire
end

function BehaviorWarn:Begin()
	self:_DoWarn()

	self.endTime = GameRules:GetGameTime() + self.warnDuration
end

function BehaviorWarn:Continue()
	self:_DoWarn()

	self.endTime = GameRules:GetGameTime() + self.warnDuration
end

function BehaviorWarn:End()
end

function BehaviorWarn:_DoWarn()
	self.unit:Stop()
	--self.unit:StartGesture(ACT_DOTA_ATTACK)
	
	Timers:CreateTimer(SINGLE_FRAME_TIME, function()
		StartAnimation(self.unit, {duration=self.warnDuration, activity=ACT_DOTA_OVERRIDE_ABILITY_1, rate=1.0})
		self.unit:EmitSound("Lycan_Wolf.PreAttack")
	end)
	
	self.unit._LastWarnTime = GameRules:GetGameTime()
end

function BehaviorWarn:_CanWarn()
	-- Only try to warn every few seconds.
	return self.unit._LastWarnTime < (GameRules:GetGameTime() - self.delayBetweenWarns)
end