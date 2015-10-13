--------------------------------------------------------------------------------------------------------
-- Roshan AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	--thisEntity:SetContextThink("Think", Think, 1.0)
	--thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
	--	BehaviorAttackTarget(thisEntity, DESIRE_HIGH),
		--BehaviorDespawn(thisEntity, DESIRE_MEDIUM)
	--})
	--thisEntity.behaviorSystem.thinkDuration = 0.25 -- faster reactions so Toss works better
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end