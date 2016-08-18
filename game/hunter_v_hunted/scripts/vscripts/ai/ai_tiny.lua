--------------------------------------------------------------------------------------------------------
-- Tiny AI
--------------------------------------------------------------------------------------------------------
function Spawn( entityKeyValues )
	GrowModel(thisEntity)

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


-- BUG: tree no longer appearing.

-- Borrowed from DotaCraft
-- https://github.com/MNoya/DotaCraft/blob/master/game/dota_addons/dotacraft/scripts/vscripts/units/nightelf/mountain_giant.lua
function GrowModel( caster )
    Timers:CreateTimer(function()
        local wearables = caster:GetChildren()
        for _,wearable in pairs(wearables) do
            if wearable:GetClassname() == "dota_item_wearable" then
                if not wearable:GetModelName():match("tree") then
                    local new_model_name = string.gsub(wearable:GetModelName(),"1","4")
                    wearable:SetModel(new_model_name)
                else
                	--caster.tree = wearable
                	wearable:AddEffects(EF_NODRAW) 
                end
            end
        end
        return false
    end)
end