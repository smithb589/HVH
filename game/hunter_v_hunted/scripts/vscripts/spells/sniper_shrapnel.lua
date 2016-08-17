--[[
	CHANGELIST:
	09.01.2015 - Remove ReleaseParticleIndex( .. )
]]
function shrapnel_on_upgrade( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_shrapnel_stack_counter_datadriven"

	if not caster.ShrapnelStackManager then
		caster.ShrapnelStackManager = ModifierStackManager(caster, ability, modifierName)
	end

	caster.ShrapnelStackManager:OnUpgrade()
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Main: Check/Reduce charge, spawn dummy and cast the actual ability
]]
function shrapnel_fire( keys )
	-- Reduce stack if more than 0 else refund mana
	--if keys.caster.shrapnel_charges > 0 then
		-- variables
		local caster = keys.caster
		local target = keys.target_points[1]
		local ability = keys.ability
		local casterLoc = caster:GetAbsOrigin()
		local dummyModifierName = "modifier_shrapnel_dummy_datadriven"
		local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
		local delay = ability:GetLevelSpecialValueFor( "delay", ( ability:GetLevel() - 1 ) ) + 0.1
		local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
		local launch_sound_name = "Hero_Sniper.ShrapnelShoot"
		local shatter_sound_name = "Hero_Sniper.ShrapnelShatter"
	
		caster.ShrapnelStackManager:ExpendCharge()

		-- Create particle at caster
		local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )
		StartSoundEvent( launch_sound_name, caster )
		StartSoundEventFromPosition( shatter_sound_name, target )

		-- Apply debuff
		shrapnel_debuff( caster, ability, target, delay, dummyModifierName, dummy_duration )
	--else
	--	keys.ability:RefundManaCost()
	--end
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Main: Create dummy to apply debuff
]]
function shrapnel_debuff( caster, ability, target, delay, dummyModifierName, dummy_duration )
	Timers:CreateTimer( delay, function()
			-- create dummy to apply debuff modifier
			local dummy = CreateUnitByName( "npc_dummy_blank", target, false, caster, caster, caster:GetTeamNumber() )
			ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )
			Timers:CreateTimer( dummy_duration, function()
				dummy:ForceKill( true )
				return nil
			end)

			disableTechiesMines(ability, target)

			return nil
		end
	)
end

-- Mines within the radius are temporarily disabled and become visible to all
function disableTechiesMines(ability, location)
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel())
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel())

	local mines = Entities:FindAllByClassnameWithin("npc_dota_techies_mines", location, radius)
	for _,mine in pairs(mines) do
		--print("Disabling a mine.")
		mine:RemoveModifierByName("modifier_techies_land_mine")
		local caster = mine:GetOwnerEntity()
		local ability = caster:FindAbilityByName("techies_land_mines")
		Timers:CreateTimer(duration, function()
			if not mine:IsNull() then
				mine:AddNewModifier(caster, ability, "modifier_techies_land_mine", {})
			end
		end)
	end
end