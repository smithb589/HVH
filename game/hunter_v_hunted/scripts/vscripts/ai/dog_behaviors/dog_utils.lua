if HVHDogUtils == nil then
	HVHDogUtils = class({})
end

-- finds nearest enemy hero, optionally only visible heroes
function HVHDogUtils:FindNearestTarget(entity, fow_visible)
	local fow_visible = fow_visible or false -- overloaded

	local flags = DOTA_UNIT_TARGET_FLAG_NONE
	if fow_visible then
		flags = DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE
	end

	local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
								 	entity:GetAbsOrigin(),
									nil,
									FIND_UNITS_EVERYWHERE,
									DOTA_UNIT_TARGET_TEAM_FRIENDLY,
									DOTA_UNIT_TARGET_HERO,
									flags,
									FIND_CLOSEST,
									false)
	return units[1]
end

function HVHDogUtils:IsTargetValid(target)
	return target and not target:IsNull() and target:IsAlive()
end

function HVHDogUtils:IsInvisibleTargetInWanderRange(unit, target)
	local targetInWanderRange = false
	local targetValid = self:IsTargetValid(target)

	if targetValid then
		local rangeToTarget = unit:GetRangeToUnit(target)
		targetInWanderRange = rangeToTarget < unit._MaxWanderingDistance
	end
	
	return targetValid and targetInWanderRange and target:IsInvisible()
end

function HVHDogUtils:RemoveLoyaltyBuff(target)
	target:RemoveModifierByName("modifier_feed_dog_loyalty")
end

-- todo: this is written quite retardedly
function HVHDogUtils:ApplyLoyaltyBuff(target, dog)
	local ability = target:FindAbilityByName("sniper_feed_dog")
	local buff = "modifier_feed_dog_loyalty"
	local dur = dog._LoyaltyDuration
	ability:ApplyDataDrivenModifier(dog, target, buff, { duration = dur })
end