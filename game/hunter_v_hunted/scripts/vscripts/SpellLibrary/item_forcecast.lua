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

--[[ Issues

item_black_hole		nofx, nofx while channeling
item_land_mines		no dmg after ability is gone
item_walrus_punch	does nothing

]]

--[[ Future

--SNIPERS
battle_trance
chilling_touch
cold_embrace
cold_snap
disruption
glimpse
mist_coil
suicide_squad
surge
walrus_kick

--NS
avalanche/toss
bane_brain_sap
bloodseeker_blood_rite
conjure_image
crypt_swarm
decay
fatal_bonds
fissure
frozen_sigil
gust
ice_wall
paralyzing_cask
plasma_field
sunder
--]]