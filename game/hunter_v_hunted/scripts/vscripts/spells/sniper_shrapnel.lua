--[[
	CHANGELIST:
	09.01.2015 - Remove ReleaseParticleIndex( .. )
]]


function shrapnel_on_upgrade( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_shrapnel_stack_counter_datadriven"

	-- Only start charging at level 1
	if ability:GetLevel() == 1 then
		shrapnel_start_charge(keys)
	else
		caster.shrapnel_charges = caster.shrapnel_charges + 1
		caster:SetModifierStackCount( modifierName, caster, caster.shrapnel_charges)
		caster.maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
		ability:EndCooldown()
	end
end

--[[
	Author: kritth
	Date: 7.1.2015.
	Init: Create a timer to start charging charges
]]
function shrapnel_start_charge( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_shrapnel_stack_counter_datadriven"
	local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
	local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
	
	-- Initialize stack
	caster:SetModifierStackCount( modifierName, caster, 0 )
	caster.shrapnel_charges = maximum_charges
	caster.maximum_charges = maximum_charges
	caster.start_charge = false
	caster.shrapnel_cooldown = 0.0
	
	ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
	caster:SetModifierStackCount( modifierName, caster, caster.maximum_charges )
	
	-- create timer to restore stack
	Timers:CreateTimer( function()
			-- Restore charge
			if caster.start_charge and caster.shrapnel_charges < caster.maximum_charges then
				-- Calculate stacks
				local next_charge = caster.shrapnel_charges + 1
				caster:RemoveModifierByName( modifierName )
				if next_charge ~= caster.maximum_charges then
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
					shrapnel_start_cooldown( caster, charge_replenish_time )
				else
					ability:ApplyDataDrivenModifier( caster, caster, modifierName, {} )
					caster.start_charge = false
				end
				caster:SetModifierStackCount( modifierName, caster, next_charge )
				
				-- Update stack
				caster.shrapnel_charges = next_charge
			end
			
			-- Check if max is reached then check every 0.5 seconds if the charge is used
			if caster.shrapnel_charges ~= caster.maximum_charges then
				caster.start_charge = true
				return charge_replenish_time
			else
				return 0.5
			end
		end
	)
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Helper: Create timer to track cooldown
]]
function shrapnel_start_cooldown( caster, charge_replenish_time )
	caster.shrapnel_cooldown = charge_replenish_time
	Timers:CreateTimer( function()
			local current_cooldown = caster.shrapnel_cooldown - 0.1
			if current_cooldown > 0.1 then
				caster.shrapnel_cooldown = current_cooldown
				return 0.1
			else
				return nil
			end
		end
	)
end

--[[
	Author: kritth
	Date: 6.1.2015.
	Main: Check/Reduce charge, spawn dummy and cast the actual ability
]]
function shrapnel_fire( keys )
	-- Reduce stack if more than 0 else refund mana
	if keys.caster.shrapnel_charges > 0 then
		-- variables
		local caster = keys.caster
		local target = keys.target_points[1]
		local ability = keys.ability
		local casterLoc = caster:GetAbsOrigin()
		local modifierName = "modifier_shrapnel_stack_counter_datadriven"
		local dummyModifierName = "modifier_shrapnel_dummy_datadriven"
		local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
		local maximum_charges = ability:GetLevelSpecialValueFor( "maximum_charges", ( ability:GetLevel() - 1 ) )
		local charge_replenish_time = ability:GetLevelSpecialValueFor( "charge_replenish_time", ( ability:GetLevel() - 1 ) )
		local dummy_duration = ability:GetLevelSpecialValueFor( "duration", ( ability:GetLevel() - 1 ) ) + 0.1
		local delay = ability:GetLevelSpecialValueFor( "delay", ( ability:GetLevel() - 1 ) ) + 0.1
		local launch_particle_name = "particles/units/heroes/hero_sniper/sniper_shrapnel_launch.vpcf"
		local launch_sound_name = "Hero_Sniper.ShrapnelShoot"
		local shatter_sound_name = "Hero_Sniper.ShrapnelShatter"
	
		-- Deplete charge
		local next_charge = caster.shrapnel_charges - 1
		if caster.shrapnel_charges == maximum_charges then
			caster:RemoveModifierByName( modifierName )
			ability:ApplyDataDrivenModifier( caster, caster, modifierName, { Duration = charge_replenish_time } )
			shrapnel_start_cooldown( caster, charge_replenish_time )
		end
		caster:SetModifierStackCount( modifierName, caster, next_charge )
		caster.shrapnel_charges = next_charge
		
		-- Check if stack is 0, display ability cooldown
		if caster.shrapnel_charges == 0 then
			-- Start Cooldown from caster.shrapnel_cooldown
			ability:StartCooldown( caster.shrapnel_cooldown )
		else
			ability:EndCooldown()
		end
		
		-- Create particle at caster
		local fxLaunchIndex = ParticleManager:CreateParticle( launch_particle_name, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( fxLaunchIndex, 0, casterLoc )
		ParticleManager:SetParticleControl( fxLaunchIndex, 1, Vector( casterLoc.x, casterLoc.y, 800 ) )
		StartSoundEvent( launch_sound_name, caster )
		StartSoundEventFromPosition( shatter_sound_name, target )

		-- Apply debuff
		shrapnel_debuff( caster, ability, target, delay, dummyModifierName, dummy_duration )
	else
		keys.ability:RefundManaCost()
	end
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