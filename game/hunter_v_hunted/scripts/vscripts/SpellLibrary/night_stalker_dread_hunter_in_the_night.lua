---------------------------------- creates auto-following vision dummy
function VisionThinker(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()

	if not GameRules:IsDaytime() and caster:IsRealHero() then
		local dummy = nil
		if caster.VisionDummyEntIndex == nil then
			dummy = CreateVisionDummy(keys)
		else
			dummy = EntIndexToHScript(caster.VisionDummyEntIndex)
		end

		dummy:SetOrigin(pos)
	end
end

function CreateVisionDummy(keys)
	local caster  = keys.caster
	local ability = keys.ability
	local pos  = caster:GetAbsOrigin()
	local team = caster:GetTeam()
	local vision_dummy_str = keys.vision_dummy_str
	local nv_radius     = ability:GetSpecialValueFor("night_vision_radius")
	local nv_pulse_freq = ability:GetSpecialValueFor("night_vision_pulse_frequency")
	local nv_pulse_dur  = ability:GetSpecialValueFor("night_vision_pulse_duration")

	local dummy = CreateUnitByName(vision_dummy_str, pos, false, nil, nil, team)
	dummy:SetNightTimeVisionRange(nv_radius)
	caster.VisionDummyEntIndex = dummy:entindex()

	-- pulse throbber
	Timers:CreateTimer(nv_pulse_freq, function()
		VisionPulse(caster, dummy, nv_pulse_dur, nv_radius)
		return nv_pulse_freq
	end)

	return dummy
end

function VisionPulse(caster, dummy, duration, radius)
	if caster:IsAlive() then
		dummy:SetNightTimeVisionRange(radius)
		Timers:CreateTimer(duration, function()
			dummy:SetNightTimeVisionRange(0)
			return nil
		end)
	else
		dummy:SetNightTimeVisionRange(0)
	end
end

-- vision pulsing

---------------------------------- applies speed
function SpeedThinker(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_speed = keys.mod_speed

	if GameRules:IsDaytime() and caster:HasModifier(mod_speed) then
		caster:NotifyWearablesOfModelChange(true)
		caster:RemoveModifierByName(mod_speed)
	elseif not GameRules:IsDaytime() and not caster:HasModifier(mod_speed) then
		caster:NotifyWearablesOfModelChange(true)
		ability:ApplyDataDrivenModifier(caster, caster, mod_speed, {})
	end

end

--------------------------------- applies invis

function OnAttackLanded(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local delay = keys.delay

	ResetInvisDelay(caster, ability, mod_invis, delay)
end

function OnAbilityExecuted(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local delay = keys.delay

	ResetInvisDelay(caster, ability, mod_invis, delay)
end

function OnUnitMoved(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local delay = keys.delay

	if GameRules:IsDaytime() then
		ResetInvisDelay(caster, ability, mod_invis, delay)
	end
end

function OnTakeDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis
	local delay = keys.delay
	local attack_damage = keys.attack_damage
	local minimum_dmg_to_break_invis = keys.minimum_dmg_to_break_invis

	if attack_damage >= minimum_dmg_to_break_invis then
		ResetInvisDelay(caster, ability, mod_invis, delay)
	end
end

function ResetInvisDelay(caster, ability, mod_invis, delay)
	if caster:HasModifier(mod_invis) then
		caster:RemoveModifierByName(mod_invis)
	end

	local timerName = "NSInvisDelay" .. caster:entindex()
	Timers:RemoveTimer(timerName)
    Timers:CreateTimer(timerName, {
      useGameTime = true,
      endTime = delay,
      callback = function()
      	ability:ApplyDataDrivenModifier(caster, caster, mod_invis, {})
	  end
	})
end