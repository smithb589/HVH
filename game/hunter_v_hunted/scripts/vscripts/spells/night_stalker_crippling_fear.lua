--[[Author: Pizzalol
	Date: 11.01.2015.
	It applies a different modifier depending on the time of day]]
function CripplingFear( keys )
	local ability = keys.ability
	local target = keys.target

	target:TriggerSpellReflect(ability)

	-- TODO: reintroduce linken park spheres without passive component
	--if target:HasModifier("modifier_item_sphere_target") then
	--	target:TriggerSpellAbsorb(ability)
	--	return
	--end

	ApplyAppropriateCripple(keys, target)
end

function CripplingFearAOE ( keys )
	local caster = keys.caster
	local ability = keys.ability
	local targetLocation = keys.target_points[1]
	local radius = ability:GetSpecialValueFor("radius")

	local unitsToTarget = FindUnitsInRadius(caster:GetTeam(), targetLocation, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_NONE, 0, false)
	for _,target in ipairs(unitsToTarget) do
		ApplyAppropriateCripple(keys, target)
	end
end

function ApplyAppropriateCripple(keys, target)
	local caster = keys.caster
	local ability = keys.ability
	local modifier_day = keys.modifier_day
	local modifier_night = keys.modifier_night
	local modifier_dog = keys.modifier_dog

	if target:GetUnitName() == "npc_dota_good_guy_dog" then
		ability:ApplyDataDrivenModifier(caster, target, modifier_dog, {})
	elseif GameRules:IsDaytime() then
		ability:ApplyDataDrivenModifier(caster, target, modifier_day, {})
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier_night, {})
	end
end