--------------------------------------------------------------------------------------------------------
-- Follow behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorFollow == nil then
	BehaviorFollow = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MEDIUM+1
		Behavior.init(self)
	end)
end

function BehaviorFollow:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET
	self.order.TargetIndex = nil
end

-- If it's night and someone fed the dog recently, then follow that man
-- (The "last feeder" is the Sniper who most recently fed the dog)
function BehaviorFollow:Evaluate()
	local followDesire = DESIRE_NONE
	local lastFeeder = self.unit._LastFeeder

	if not GameRules:IsDaytime() and HVHDogUtils:IsTargetValid(lastFeeder) and self:IsStillLoyalTo(lastFeeder) then
		followDesire = self.desire --DESIRE_MEDIUM + 1 -- takes priority over invis-wandering
	end

	return followDesire
end

function BehaviorFollow:Begin()
	--print("Begin follow")
	local lastFeeder = self.unit._LastFeeder
	self.order.TargetIndex = lastFeeder:GetEntityIndex()

	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorFollow:Continue()
	--print("Continue follow @" .. GameRules:GetGameTime())
	local lastFeeder = self.unit._LastFeeder
	local lastFeederIndex = lastFeeder:GetEntityIndex()

	-- if the last feeder is no longer our move-to target, then switch feeder
	if lastFeederIndex ~= self.order.TargetIndex then
		self:SwitchFeeder(lastFeederIndex)
	end

	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorFollow:End()
	self.order.TargetIndex = nil
end

function BehaviorFollow:Think(dt)
end

-- update target of move-to command and reset loyalty timer
function BehaviorFollow:SwitchFeeder(newTargetIndex)
	--print("SWITCH FEEDER")
	self.order.TargetIndex = newTargetIndex
	--self.unit._LoyaltyEndsAt = GameRules:GetGameTime() + self.unit._LoyaltyDuration
end

function BehaviorFollow:IsStillLoyalTo(target)
	return GameRules:GetGameTime() <= self.unit._LoyaltyEndsAt
end