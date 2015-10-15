--------------------------------------------------------------------------------------------------------
-- Ursa AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorBlink(					thisEntity,	DESIRE_MAX+5),
		BehaviorEarthshock(				thisEntity,	DESIRE_MAX+3), -- only after beating Roshan
		BehaviorOverpower(				thisEntity,	DESIRE_MAX+2),
		BehaviorEnrage(					thisEntity,	DESIRE_MAX+1), -- only after beating Roshan
		BehaviorAttackTargetAggressive(	thisEntity,	DESIRE_MAX),
		--BehaviorDespawnWhenUnseen(thisEntity, DESIRE_HIGH),
		BehaviorTravelAggressive(		thisEntity, DESIRE_MEDIUM),
		BehaviorChooseNextDestination(	thisEntity, DESIRE_LOW),
		BehaviorDespawnForced(			thisEntity,	DESIRE_NONE+1)
	})
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end