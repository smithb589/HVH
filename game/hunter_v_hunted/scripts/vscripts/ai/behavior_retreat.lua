--------------------------------------------------------------------------------------------------------
-- Retreat behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorRetreat == nil then
	BehaviorRetreat = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorRetreat:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_NONE
end

function BehaviorRetreat:Evaluate()
	local desire = DESIRE_NONE
	local radius = self.unit:GetCurrentVisionRange()

	if AICore:AreEnemiesInRange(self.unit, radius, 1) then
		desire = self.desire

	return desire
end

function BehaviorRetreat:Begin()
	local enemies = AICore:GetEnemiesInRange(self.unit, radius)
	local retreaterOrigin = self.unit:GetAbsOrigin()
	local closestEnemyOrigin = enemies[1]:GetAbsOrigin()

	local midVector = retreaterOrigin - closestEnemyOrigin
	local oppositeVector = -1 * midVector

	-- (Normalize(Vt - Vb) x 500) + Vt

end

function BehaviorRetreat:Continue()
end

function BehaviorRetreat:End()
end

function BehaviorRetreat:Think(dt)
end