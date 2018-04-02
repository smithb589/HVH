--------------------------------------------------------------------------------------------------------
-- Sleep behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorSleep == nil then
	BehaviorSleep = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_LOW
		Behavior.init(self)
	end)
end

function BehaviorSleep:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	self.order.AbilityIndex = nil -- FIX LATER
end

-- Stop moving at night if there's nothing better to do
function BehaviorSleep:Evaluate()
	local sleepPriority = DESIRE_NONE
	if not GameRules:IsDaytime() then
		sleepPriority = self.desire --DESIRE_LOW
	end

	return sleepPriority
end

function BehaviorSleep:Begin()
	--print("Begin sleep")
	local sleepAbility = self.unit:FindAbilityByName("dog_sleep")
	local fade_delay = sleepAbility:GetSpecialValueFor("fade_delay")
	self.order.AbilityIndex = sleepAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_HOLD_POSITION

	StartAnimation(self.unit, {duration=fade_delay, activity=ACT_DOTA_IDLE_RARE, rate=1.0})
	sleepAbility:ApplyDataDrivenModifier(self.unit, self.unit, "modifier_sleep_fade", {})

	self.endTime = GameRules:GetGameTime() + fade_delay
end

function BehaviorSleep:Continue()
	-- Without this, the animation will keep restarting similar to 
	-- spamming hold position on a hero.
	--print("Continue sleep")
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorSleep:End()
	--print("Remove sleep")
	self.order.OrderType = DOTA_UNIT_ORDER_HOLD_POSITION
	
	if self.unit:HasModifier("modifier_sleep") then
		self.unit:RemoveModifierByName("modifier_sleep")
	end
end

function BehaviorSleep:Think(dt)
end