
function Spawn( entityKeyValues )
	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorTravel,
		BehaviorDespawn,
		BehaviorToss
	})
	thisEntity.behaviorSystem.thinkDuration = 0.1

end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end

--------------------------------------------------------------------------------------------------------
-- Travel behavior

BehaviorTravel = 
{
	order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = nil
	}
}

function BehaviorTravel:Evaluate()
	local range = 100.0
	if self.order.Position ~= nil and Length2DBetweenVectors(thisEntity:GetAbsOrigin(), self.order.Position) < range then
		return DESIRE_NONE
	else
		return DESIRE_HIGH
	end
end

function BehaviorTravel:Begin()
	self.order.Position = thisEntity.destinationLoc
	self.endTime = GameRules:GetGameTime() + 1.0
end

function BehaviorTravel:Continue()
end

function BehaviorTravel:End()
end

function BehaviorTravel:Think(dt)
end

--------------------------------------------------------------------------------------------------------
-- Despawn behavior

BehaviorDespawn = 
{
	order =
	{
		OrderType = DOTA_UNIT_ORDER_NONE,
		UnitIndex = thisEntity:entindex(),
		AbilityIndex = nil -- This will be filled in later
	},

	killAfter = 1.0
}

function BehaviorDespawn:Evaluate()
	return DESIRE_MEDIUM
end

function BehaviorDespawn:Begin()
	self.endTime = GameRules:GetGameTime() + self.killAfter
	--local fadeParticle = ParticleManager:CreateParticle("particles/generic_hero_status/status_invisibility_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
	--ParticleManager:SetParticleControl(fadeParticle, 1, thisEntity:GetAb
end

function BehaviorDespawn:Continue()
	--thisEntity:AddNewModifier(thisEntity, nil, "modifier_invisible", {})
	thisEntity:ForceKill(false)
end

function BehaviorDespawn:End()
end

function BehaviorDespawn:Think(dt)
end

--------------------------------------------------------------------------------------------------------
-- Toss behavior

BehaviorToss = 
{
	order = 
	{
		OrderType = DOTA_UNIT_ORDER_NONE,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = nil,
		AbilityIndex = nil -- This will be filled in later
	},

	tossAbility = nil,
	dummyIndex = nil
}

function BehaviorToss:CreateDummyTarget(unit)
	local shrinkMaxRangeBy = 250.0 -- to avoid throwing at a space you're moving away from
	local pos = unit:GetAbsOrigin() + RandomVector(self.tossAbility:GetCastRange() - shrinkMaxRangeBy)
    local dummy = CreateUnitByName("npc_dummy_toss", pos, true, nil, nil, DOTA_TEAM_NEUTRALS)
    print("Created dummy unit " .. dummy:entindex())

    --Timers:CreateTimer(3.0, function()
    --	if dummy then dummy:ForceKill(false) end
    --end)

    return dummy:entindex()
end

function BehaviorToss:Evaluate()
	self.tossAbility = thisEntity:FindAbilityByName("tiny_toss")
	self.order.AbilityIndex = self.tossAbility:entindex()
	local tossDesire = DESIRE_NONE

	local grab_radius = self.tossAbility:GetSpecialValueFor("grab_radius")
	if AICore:AreEnemiesInRange(thisEntity, grab_radius, 1) and self.tossAbility:IsFullyCastable() then
		tossDesire = DESIRE_MAX
	end

	print("Toss desire: " .. tossDesire)
	return tossDesire
end

function BehaviorToss:Begin()
	print("Toss begin")
	self.dummyIndex = self:CreateDummyTarget(thisEntity)	
	self.order.OrderType = DOTA_UNIT_ORDER_CAST_TARGET
	self.order.TargetIndex = self.dummyIndex
	self.endTime = GameRules:GetGameTime() + 0.1
end

function BehaviorToss:Continue()
	print("Toss continue")
end

function BehaviorToss:End()
	print("Toss end")
	self.order.OrderType = DOTA_UNIT_ORDER_NONE

	local dummy = EntIndexToHScript(self.dummyIndex)
	if dummy then
		dummy:ForceKill(false)
		print("Destroying dummy unit " .. self.dummyIndex)
		self.dummyIndex = nil
	end
end

function BehaviorToss:Think(dt)
	-- Nothing to do
end