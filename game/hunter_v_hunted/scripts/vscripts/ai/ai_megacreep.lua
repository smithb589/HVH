
function Spawn( entityKeyValues )
	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorTravel,
		BehaviorDespawn
	})
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