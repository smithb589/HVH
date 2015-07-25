function ForceCast( keys )
	local caster = keys.caster
	local item = keys.ability
	--local casterLocation = caster:GetAbsOrigin()

	local abilityName = keys.abilityName
	local maxDuration = keys.maxDuration

	if caster:HasAbility(abilityName) then
		print(caster:GetName() .. " already has " .. abilityName)
		return
	end

	caster:AddAbility(abilityName)
	local ability = caster:FindAbilityByName(abilityName)
	ability:SetHidden(true)
	ability:SetLevel(ability:GetMaxLevel())
	ability:EndCooldown()
	ability:OnSpellStart()
	Timers:CreateTimer(maxDuration, function()
		if caster:HasAbility(abilityName) then
			caster:RemoveAbility(abilityName)
		end
	end)
end

-- unused for now
function LearnTempAbility ( caster, abilityName, maxDuration )
	print("learned " .. abilityName)
	caster:AddAbility(abilityName)
	local ability = caster:FindAbilityByName(abilityName)
	ability:SetHidden(true)
	ability:SetLevel(ability:GetMaxLevel())
	Timers:CreateTimer(maxDuration+1, function()
		caster:RemoveAbility(abilityName)
		print("forgot " .. abilityName)
	end)
end