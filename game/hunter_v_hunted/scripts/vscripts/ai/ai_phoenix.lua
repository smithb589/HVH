--------------------------------------------------------------------------------------------------------
-- Phoenix AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	thisEntity:SetContextThink("Think", Think, 0.25)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorSupernova(thisEntity, DESIRE_MAX+1),
		BehaviorSunRayMove(thisEntity, DESIRE_MAX),
		BehaviorSunRay(thisEntity, DESIRE_HIGH),
		BehaviorTravel(thisEntity, DESIRE_MEDIUM),
		BehaviorChooseNextDestination(thisEntity, DESIRE_LOW+1),
		BehaviorAddNewDestination(thisEntity, DESIRE_LOW, RANGE_TYPICAL_MIN),
	})
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end