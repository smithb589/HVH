--------------------------------------------------------------------------------------------------------
-- Pursue behavior
-- 
--------------------------------------------------------------------------------------------------------
if BehaviorPursue == nil then
	BehaviorPursue = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_LOW
		Behavior.init(self)
	end)
end

function BehaviorPursue:Setup()
	self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION -- changes to ATTACK when close
	self.order.Position  = self.unit:GetAbsOrigin()
	self.order.TargetIndex = nil -- filled in later
end

-- During the day, pursue the nearest valid enemy target
function BehaviorPursue:Evaluate()
	local target = HVHDogUtils:FindNearestTarget(self.unit)
	local pursueDesire = DESIRE_NONE
	if GameRules:IsDaytime() and HVHDogUtils:IsTargetValid(target) then
		pursueDesire = self.desire --DESIRE_LOW
	end

	return pursueDesire
end

function BehaviorPursue:Begin()
	local pursuitTarget = HVHDogUtils:FindNearestTarget(self.unit)

	if HVHDogUtils:IsTargetValid(pursuitTarget) then
		self.order.TargetIndex = pursuitTarget:GetEntityIndex()
		self.order.Position = pursuitTarget:GetAbsOrigin()
	end

	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorPursue:Continue()
	-- important to constantly re-evaluate the closest target (illusions, etc.)
	local pursuitTarget = HVHDogUtils:FindNearestTarget(self.unit)

	if HVHDogUtils:IsTargetValid(pursuitTarget) then
		self.order.TargetIndex = pursuitTarget:GetEntityIndex()
		self.order.Position = pursuitTarget:GetAbsOrigin()

		-- mostly fixes error 27 (Invalid order: Target is invisible and is not on the unit's team.)
		if not self.unit:CanEntityBeSeenByMyTeam(pursuitTarget) then
			self.order.OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION
		else
			self.order.OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
		end
	end

	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorPursue:End()
	self.order.TargetIndex = nil
end

function BehaviorPursue:Think(dt)
	-- No longer a valid target, so end this behavior.
	local pursuitTarget = EntIndexToHScript(self.order.TargetIndex)
	if not HVHDogUtils:IsTargetValid(pursuitTarget) then
		self.endTime = GameRules:GetGameTime()
	end
end