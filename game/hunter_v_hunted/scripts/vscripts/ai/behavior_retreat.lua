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
	self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION
end

function BehaviorRetreat:Evaluate()
	local desire = DESIRE_NONE
	local visionRadius = self.unit:GetCurrentVisionRange()
	local enemy = AICore:GetClosestVisibleEnemyInRange(self.unit, visionRadius)

	if enemy and AICore:CanSeeTarget(self.unit, enemy) then
		desire = self.desire
	end

	return desire
end

function BehaviorRetreat:Begin()
	-- current destination is invalid, so move to next (may need to AddNewDestination)
	HVHNeutralCreeps:NextDestination(self.unit)
	self.endTime = GameRules:GetGameTime()
end

function BehaviorRetreat:Continue()
	local visionRadius = self.unit:GetCurrentVisionRange()
	local enemy = AICore:GetClosestVisibleEnemyInRange(self.unit, visionRadius)

	local retreaterOrigin = self.unit:GetAbsOrigin()
	local closestEnemyOrigin = enemy:GetAbsOrigin()
	local magnitude = 1200.0

	-- retreat for X seconds before re-evaluating order/pathing
	local orderDuration = 3.0
	self.endTime = GameRules:GetGameTime() + orderDuration

	-- subtraction makes the vectors relative to one another
	-- normalizing reduces to magnitude to 1
	-- multiplying by magnitude to set an exact length of the vector, relative to origin
	-- adding at the end makes it relative to original position
	-- ..... I think. In other words, we find a vector opposite the enemy's direction, at distance (magnitude)
	-- Normalize( Vector_Techies - Vector_Enemy ) x Magnitude + Vector_Techies
	local destinationVector = (retreaterOrigin - closestEnemyOrigin):Normalized() * magnitude + retreaterOrigin

	if GridNav:CanFindPath(retreaterOrigin, destinationVector) then
		self.order.Position = destinationVector
		--self:DebugDraw(retreaterOrigin, destinationVector, 0, 255, 0, orderDuration)
	else
		-- create a dummy at the destination using bFindClearSpace to find a better position
		local dummy = CreateUnitByName("npc_dummy", destinationVector, true, nil, nil, DOTA_TEAM_NEUTRALS)
		local dummyVector = dummy:GetAbsOrigin()
		self.order.Position = dummyVector

		Timers:CreateTimer(0.1, function()
			dummy:ForceKill(false)
		end)

		--self:DebugDraw(retreaterOrigin, destinationVector, 255, 0, 0, orderDuration)
		--self:DebugDraw(retreaterOrigin, dummyVector, 0, 255, 0, orderDuration)
	end
end

function BehaviorRetreat:End()
	self.order.Position = nil
end

function BehaviorRetreat:Think(dt)
end

function BehaviorRetreat:DebugDraw(start_vec, end_vec, r, g, b, duration)
	DebugDrawCircle(end_vec, Vector(r,g,b), 50.0, 50.0, true, duration)
	DebugDrawLine(start_vec, end_vec, r, g, b, true, duration)
	--local canFindPath = GridNav:CanFindPath(start_vec, end_vec)
	--local isBlocked = GridNav:IsBlocked(end_vec)
	--local isTraversable = GridNav:IsTraversable(end_vec)
	--print(string.format("CanFindPath: %s, IsBlocked: %s, IsTraversable: %s", tostring(canFindPath), tostring(isBlocked), tostring(isTraversable)))
end