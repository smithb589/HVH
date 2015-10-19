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


-- Borrowed from DotaCraft
-- https://github.com/MNoya/DotaCraft/blob/master/game/dota_addons/dotacraft/scripts/vscripts/units/nightelf/mountain_giant.lua
function GrowModel( caster )
	Timers:CreateTimer(function() 
	    local model = caster:FirstMoveChild()
	    while model ~= nil do
	        if model:GetClassname() == "dota_item_wearable" then
	        	if not string.match(model:GetModelName(), "tree") then
	            	local new_model_name = string.gsub(model:GetModelName(),"1","4")
	            	model:SetModel(new_model_name)
	            else
	            	model:SetParent(caster, "attach_attack1")
	            	model:AddEffects(EF_NODRAW)
	            end
	        end
	        model = model:NextMovePeer()
	    end
	end)
end