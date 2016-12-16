--------------------------------------------------------------------------------------------------------
-- Phoenix AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	-- preview pane is now spawning creatures in it, as of ~7.00
	if not IsServer() then return end

	thisEntity:SetContextThink("Think", Think, 0.25)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorSupernova(thisEntity, DESIRE_MAX+1),
		BehaviorSunRayMove(thisEntity, DESIRE_MAX),
		BehaviorSunRay(thisEntity, DESIRE_HIGH),
		BehaviorTravel(thisEntity, DESIRE_MEDIUM),
		BehaviorChooseNextDestination(thisEntity, DESIRE_LOW+1),
		BehaviorAddNewDestination(thisEntity, DESIRE_LOW, RANGE_TYPICAL_MIN)
	})
end

-- deactivate the behavior system as soon as phoenix gains the supernova buff
function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() or thisEntity:IsCommandRestricted() then
		--print("Destroying phoenix's brain")
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end