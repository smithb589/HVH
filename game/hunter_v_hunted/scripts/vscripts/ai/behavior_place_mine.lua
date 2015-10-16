--------------------------------------------------------------------------------------------------------
-- PlaceMine behavior
--------------------------------------------------------------------------------------------------------
if BehaviorPlaceMine == nil then
	BehaviorPlaceMine = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorPlaceMine:Setup()
	self.mineAbility = self.unit:FindAbilityByName("techies_land_mines")
	self.order.AbilityIndex  = self.mineAbility:entindex()
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_POSITION
	self.order.Position = nil -- filled in later
end

function BehaviorPlaceMine:Evaluate()
	local desire = DESIRE_NONE

	if HVHNeutralCreeps:HasDestination(self.unit) and
	   self.mineAbility:IsFullyCastable() and
	   HVHNeutralCreeps:CountTechiesMines(self.unit) < TECHIES_MAX_MINES then
		desire = self.desire --DESIRE_MAX
	end

	return desire
end

function BehaviorPlaceMine:Begin()
	--PrintTable(HVHNeutralCreeps:GetDestinationList(self.unit))
	self.order.Position = HVHNeutralCreeps:GetDestination(self.unit)
	self.endTime = GameRules:GetGameTime() + 2.0
end

function BehaviorPlaceMine:Continue()
	self.endTime = GameRules:GetGameTime() + 2.0
end

function BehaviorPlaceMine:End()
	self.order.Position = nil
	HVHNeutralCreeps:AddDestination(self.unit, RANGE_TECHIES_MIN, RANGE_TECHIES_MAX)
end

function BehaviorPlaceMine:Think(dt)
	-- Nothing to do
end