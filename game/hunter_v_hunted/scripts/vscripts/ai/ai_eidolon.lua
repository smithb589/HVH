--------------------------------------------------------------------------------------------------------
-- Eidolon AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	-- force the ambient eidolon effects
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_eidolon_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
	ParticleManager:SetParticleControl(particle, 0, thisEntity:GetAbsOrigin())

	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorTravel(thisEntity, DESIRE_MEDIUM),
		BehaviorDespawn(thisEntity, DESIRE_LOW),
		BehaviorAttackBlackholeTargets(thisEntity, DESIRE_MAX)
	})
	thisEntity.behaviorSystem.thinkDuration = 0.5 -- faster reactions
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end