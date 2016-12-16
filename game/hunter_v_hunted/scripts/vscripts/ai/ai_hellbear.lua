--------------------------------------------------------------------------------------------------------
-- Tiny AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	-- preview pane is now spawning creatures in it, as of ~7.00
	if not IsServer() then return end
	
	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorClap(thisEntity, DESIRE_MAX),
		--BehaviorDespawnWhenUnseen(thisEntity, DESIRE_HIGH),
		BehaviorTravel(thisEntity, DESIRE_MEDIUM),
		BehaviorChooseNextDestination(thisEntity, DESIRE_LOW),
		BehaviorDespawnForced(thisEntity, DESIRE_NONE+1)
	})
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end