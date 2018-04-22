
function DoForceCast(caster, abilityName, maxDuration, spellLevel, position)
	if caster:HasAbility(abilityName) then
		print(caster:GetName() .. " already has " .. abilityName)
		return
	end

	caster:AddAbility(abilityName)
	local ability = caster:FindAbilityByName(abilityName)
	local level = spellLevel or ability:GetMaxLevel()
	local position = position or nil
	ability:SetHidden(true)
	ability:SetLevel(level)
	ability:EndCooldown()

	if position then
		caster:SetCursorPosition(position)
	end

	ability:OnSpellStart()

	Timers:CreateTimer(maxDuration, function()
		if caster:HasAbility(abilityName) then
			caster:RemoveAbility(abilityName)
		end
	end)

	-- exceptions
	if abilityName == "wisp_tether" then
		WispTetherBreak(caster, delay)
	end

end

function WispTetherBreak(caster, delay)
	Timers:CreateTimer(delay, function()
		if caster:HasModifier("modifier_wisp_tether") then
			caster:RemoveModifierByNameAndCaster("modifier_wisp_tether", caster)
		end
	end)	
end

function PrintAbilities(hero)
	for i=0,hero:GetAbilityCount()-1 do
		ability = hero:GetAbilityByIndex(i)
		if ability then
			print(ability:GetAbilityIndex() .. ": " .. ability:GetName())
		end
	end
end
