--------------------------------------------------------------------------------------------------------
-- Tiny AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorTravel(thisEntity),
		BehaviorDespawn(thisEntity, DESIRE_MEDIUM),
		BehaviorToss(thisEntity)
	})
	thisEntity.behaviorSystem.thinkDuration = 0.25 -- faster reactions so Toss works better
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end