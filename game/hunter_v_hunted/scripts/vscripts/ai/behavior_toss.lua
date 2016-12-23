--------------------------------------------------------------------------------------------------------
-- Toss behavior
-- Approaching enemies are tossed in a random direction at an invisible dummy
-- BUG: Deals no damage, possibly due to bizarre tiny_toss and neutral unit interactions
--------------------------------------------------------------------------------------------------------
if BehaviorToss == nil then
	BehaviorToss = DeclareClass(Behavior, function(self, entity, desire)
		self.unit = entity
		self.desire = desire or DESIRE_MAX
		Behavior.init(self)
	end)
end

function BehaviorToss:Setup()
	self.name = "Toss"
	self.tossAbility = self.unit:FindAbilityByName("tiny_toss")
	self.order.AbilityIndex = self.tossAbility:entindex()
	--BUGGED: self.grab_radius = self.tossAbility:GetSpecialValueFor("grab_radius")

	self.order.OrderType = DOTA_UNIT_ORDER_NONE -- This will be filled in later
	self.order.TargetIndex = nil -- This will be filled in later
	self.dummyIndex = nil -- This will be filled in later

	-- small delay needed after unit spawn or grab_radius = 0
	Timers:CreateTimer(SINGLE_FRAME_TIME, function()
		self.grab_radius = self.tossAbility:GetSpecialValueFor("grab_radius")
	end)
end

function BehaviorToss:Evaluate()
	local tossDesire = DESIRE_NONE

	if AICore:AreEnemiesInRange(self.unit, self.grab_radius, 1) and self.tossAbility:IsFullyCastable() then
		tossDesire = self.desire --DESIRE_MAX
	end

	return tossDesire
end

function BehaviorToss:Begin()
	--print("Toss begin")
	self.dummyIndex = self:CreateDummyTarget(self.unit)	
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_TARGET
	self.order.TargetIndex = self.dummyIndex
	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorToss:Continue()
	--print("Toss continue")
end

function BehaviorToss:End()
	--print("Toss end")
	self.order.OrderType = DOTA_UNIT_ORDER_NONE

	local dummy = EntIndexToHScript(self.dummyIndex)
	if dummy then
		dummy:ForceKill(false)
		--print("Destroying dummy unit " .. self.dummyIndex)
		self.dummyIndex = nil
	end
end

function BehaviorToss:Think(dt)
	-- Nothing to do
end

function BehaviorToss:CreateDummyTarget(unit)
	local shrinkMaxRangeBy = 250.0 -- to avoid throwing at a space you're moving away from
	local pos = unit:GetAbsOrigin() + RandomVector(self.tossAbility:GetCastRange() - shrinkMaxRangeBy)
    local dummy = CreateUnitByName("npc_dummy_toss", pos, true, nil, nil, self.unit:GetTeam())
    --print("Created dummy unit " .. dummy:entindex())

    --Timers:CreateTimer(3.0, function()
    --	if dummy then dummy:ForceKill(false) end
    --end)

    return dummy:entindex()
end
