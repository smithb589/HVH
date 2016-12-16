--------------------------------------------------------------------------------------------------------
-- Roshan AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	-- preview pane is now spawning creatures in it, as of ~7.00
	if not IsServer() then return end
	
	Timers:CreateTimer(150.0, function()
		if AICore:IsTargetValid(thisEntity) then
			thisEntity:ForceKill(false)
			--print("Destroying tower for inactivity")
		end
	end)

	thisEntity:SetContextThink("Think", Think, 1.0)
	thisEntity.behaviorSystem = AICore:CreateBehaviorSystem({
		BehaviorSlam(thisEntity, DESIRE_MAX),
		BehaviorWait(thisEntity, DESIRE_NONE+1)
	})
end

function Think()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return thisEntity.behaviorSystem:Think()
end