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


--[[ Issues
item_black_hole			nofx, nofx while channeling
item_land_mines		no dmg after ability is gone
item_tether			can't target friendlies
item_walrus_punch	does nothing
]]