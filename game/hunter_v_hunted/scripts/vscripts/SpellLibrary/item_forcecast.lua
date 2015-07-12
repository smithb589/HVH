function ForceCast( keys )
	local caster = keys.caster
	local item = keys.ability
	--local casterLocation = caster:GetAbsOrigin()

	local abilityName = keys.abilityName
	local maxDuration = keys.maxDuration

	caster:AddAbility(abilityName)
	local ability = caster:FindAbilityByName(abilityName)
	ability:SetHidden(true)
	ability:SetLevel(ability:GetMaxLevel())
	ability:EndCooldown()
	ability:OnSpellStart()
	Timers:CreateTimer(maxDuration, function()
		caster:RemoveAbility(abilityName)
	end)
end
