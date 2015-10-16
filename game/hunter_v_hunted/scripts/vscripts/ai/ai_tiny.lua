--------------------------------------------------------------------------------------------------------
-- Tiny AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorToss(thisEntity, DESIRE_MAX),
		--BehaviorDespawnWhenUnseen(thisEntity, DESIRE_HIGH),
		BehaviorTravel(thisEntity, DESIRE_MEDIUM),
		BehaviorChooseNextDestination(thisEntity, DESIRE_LOW),
		BehaviorDespawnForced(thisEntity, DESIRE_NONE+1)
	})
	thisEntity.behaviorSystem.thinkDuration = 0.25 -- faster reactions so Toss works better
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end