--------------------------------------------------------------------------------------------------------
-- BlackholeChannel behavior
--------------------------------------------------------------------------------------------------------
if BehaviorBlackholeChannel == nil then
	BehaviorBlackholeChannel = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorBlackholeChannel:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
end

function BehaviorBlackholeChannel:Evaluate()
	local desire = DESIRE_NONE
	--print("BlackholeChannel Evaluate")

	if self.unit:IsChanneling() then
		desire = self.desire
	end

	return desire
end

function BehaviorBlackholeChannel:Begin()
	--print("Channel BEGIN")
	local blackholeAbility = self.unit:FindAbilityByName("enigma_black_hole")
	local channelTime = blackholeAbility:GetChannelTime()
	self.endTime = GameRules:GetGameTime() + channelTime + 1.0
end

function BehaviorBlackholeChannel:Continue()
	--print("Channel CONTINUE")
end

function BehaviorBlackholeChannel:End()
	--print("Channel END")
end

function BehaviorBlackholeChannel:Think(dt)
end