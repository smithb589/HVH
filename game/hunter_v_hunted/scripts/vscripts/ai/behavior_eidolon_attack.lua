--------------------------------------------------------------------------------------------------------
-- AttackBlackholeTargets behavior
--------------------------------------------------------------------------------------------------------
if BehaviorAttackBlackholeTargets == nil then
	BehaviorAttackBlackholeTargets = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorAttackBlackholeTargets:Setup()
	self.name = "AttackBlackholeTargets"
	self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
	self.order.TargetIndex = nil
	self.targetsInBlackhole = {}
end

function BehaviorAttackBlackholeTargets:Evaluate()
	local desire = DESIRE_NONE
	local range = 3000.0
	local targets = AICore:GetEnemiesInRange(self.unit, range)

	-- check for nearby targets in blackhole
	self.targetsInBlackhole = {}
	for _,target in pairs(targets) do
		if target:HasModifier("modifier_enigma_black_hole_pull") then
			table.insert(self.targetsInBlackhole, target)
		end
	end

	-- if there's at least one, attacking is a good idea
	if self.targetsInBlackhole[1] then
		desire = self.desire
	end

	return desire
end

function BehaviorAttackBlackholeTargets:Begin()
	-- choose random target
	local r = RandomInt(1, #self.targetsInBlackhole)
	self.order.TargetIndex = self.targetsInBlackhole[r]:entindex()
end

function BehaviorAttackBlackholeTargets:Continue()
end

function BehaviorAttackBlackholeTargets:End()
	self.order.TargetIndex = nil
	self.targetsInBlackhole = {}
end

function BehaviorAttackBlackholeTargets:Think(dt)
	-- Nothing to do
end