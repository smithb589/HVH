-- activates on spawn too
function Supernova_OnUpgrade(keys)
	Timers:CreateTimer(0.1, function()
		-- particle effect on birth
		local phoenix = keys.caster

		-- apply stun to enemies in range
		local supernova = phoenix:FindAbilityByName("phoenix_supernova_hvh")
		local enemiesList = AICore:GetEnemiesInRange(phoenix, supernova:GetSpecialValueFor("aura_radius"), false)
		for _,enemy in pairs(enemiesList) do
			supernova:ApplyDataDrivenModifier(phoenix, enemy, "modifier_supernova_explode_stun_hvh", {})
		end

		local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
		local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN, phoenix )
		--ParticleManager:SetParticleControlEnt( pfx, 0, phoenix, PATTACH_POINT_FOLLOW, "attach_hitloc", phoenix:GetAbsOrigin(), true )
		--ParticleManager:SetParticleControlEnt( pfx, 1, phoenix, PATTACH_POINT_FOLLOW, "attach_hitloc", phoenix:GetAbsOrigin(), true )

		local phoenixVis = VisionDummy(phoenix, "npc_dummy_reveal_phoenix")
		EmitSoundOnLocationWithCaster(phoenix:GetAbsOrigin(), "Hero_Phoenix.SuperNova.Explode", phoenix)
	end)
end

function Supernova_OnToggleOn( keys )
	local phoenix = keys.caster
	local ability = keys.ability

	phoenix:Stop()
	phoenix:SetOriginalModel("models/heroes/phoenix/phoenix_egg.vmdl")
	phoenix:SetModel("models/heroes/phoenix/phoenix_egg.vmdl")
	ability:ApplyDataDrivenModifier(phoenix, phoenix, "modifier_supernova_egg_form_hvh", {})

	local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_egg.vpcf"
	local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN, phoenix )

	StartSoundEventFromPositionReliable("Hero_Phoenix.Begin", phoenix:GetAbsOrigin() )
	StartSoundEventFromPositionReliable("Hero_Phoenix.Cast", phoenix:GetAbsOrigin() )
	--StartSoundEventFromPositionReliable("Hero_Phoenix.IdleLoop", phoenix:GetAbsOrigin() )

	-- TODO: can't figure out why the sound won't play
	--Timers:CreateTimer(0.1, function()
		--EmitSoundOn("Hero_Phoenix.Begin", phoenix)
		--EmitSoundOn("Hero_Phoenix.Cast", phoenix)
		--EmitSoundOnLocationWithCaster(phoenix:GetAbsOrigin(), "Hero_Phoenix.IdleLoop", phoenix)
	--end)
end

function Supernova_OnToggleOff( keys )
	local phoenix = keys.caster
	phoenix:ForceKill(false)
	phoenix:AddNoDraw()
	HVHPhoenix:Setup(phoenix:GetAbsOrigin())
end

function Supernova_CreateVisionDummy(keys)
	local phoenix = keys.caster	
	VisionDummy(phoenix, "npc_dummy_reveal_phoenix") -- egg vision
end