--------------------------------------------------------------------------------------------------------
-- Eidolon AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	-- preview pane is now spawning creatures in it, as of ~7.00
	if not IsServer() then return end

	-- force the ambient eidolon effects
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_eidolon_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, thisEntity)
	ParticleManager:SetParticleControl(particle, 0, thisEntity:GetAbsOrigin())

	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorAttackBlackholeTargets(thisEntity, DESIRE_MAX),
		--BehaviorDespawnWhenUnseen(thisEntity, DESIRE_HIGH),
		BehaviorTravel(thisEntity, DESIRE_MEDIUM),
		BehaviorChooseNextDestination(thisEntity, DESIRE_LOW),
		BehaviorDespawnForced(thisEntity, DESIRE_NONE+1)
	})
	thisEntity.behaviorSystem.thinkDuration = 0.5 -- faster reactions
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end