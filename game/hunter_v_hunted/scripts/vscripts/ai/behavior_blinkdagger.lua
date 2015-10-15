--------------------------------------------------------------------------------------------------------
-- Blink behavior
-- Use blink dagger toward nearby enemies
--------------------------------------------------------------------------------------------------------
if BehaviorBlink == nil then
	BehaviorBlink = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_HIGH
		Behavior.init(self)
	end)
end

function BehaviorBlink:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_POSITION
	self.order.AbilityIndex = nil
	self.order.Position  = nil -- set later
	self.target = nil
end

function BehaviorBlink:Evaluate()
	local desire = DESIRE_NONE
	local range = 1200
	local maxBlink = 960.0
	local minBlink = 300.0
	local targets = AICore:GetEnemiesInRange(self.unit, range)
	local closestTarget = targets[1]
	local blinkDagger = HVHItemUtils:GetItemByName(self.unit, "item_blink")

	-- Blink dagger ready, CD ready, target valid, enemy range within parameters
	if blinkDagger and blinkDagger:IsFullyCastable() and AICore:IsTargetValid(closestTarget) then

		if AICore:IsTargetInRange(self.unit, closestTarget, minBlink, maxBlink) and
		   AICore:CanSeeTarget(self.unit, closestTarget) then
			
			self.target = closestTarget
			desire = self.desire --DESIRE_HIGH
		end
	end

	return desire
end



function BehaviorBlink:Begin()
	-- calculate position
 	local blinkDagger = HVHItemUtils:GetItemByName(self.unit, "item_blink")
	local targetPos = self.target:GetAbsOrigin()
	local randomDerivation = Vector(math.random(-128, 128), math.random(-128, 128), 0)

	self.order.AbilityIndex = blinkDagger:entindex()
	self.order.Position = targetPos + randomDerivation
	self.endTime = GameRules:GetGameTime()
end

function BehaviorBlink:Continue()
end

function BehaviorBlink:End()
	self.order.Position = nil
	self.target = nil
end

function BehaviorBlink:Think(dt)
end