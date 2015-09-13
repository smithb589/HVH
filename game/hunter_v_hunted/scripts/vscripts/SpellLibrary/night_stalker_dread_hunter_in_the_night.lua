---------------------------------- creates auto-following vision dummy
function VisionThinker(keys)
	local caster = keys.caster
	local trailModifierName = keys.trail_mod_name
	local pulseFrequency = keys.pulse_frequency
	local pulseDuration = keys.pulse_duration
	if not GameRules:IsDaytime() then
		local pos = caster:GetAbsOrigin()
		local targets = GetVisionTargets(pos)

		for targetIndex = 1, #targets do
			local target = targets[targetIndex]
			target:MakeVisibleToTeam(caster:GetTeam(), pulseDuration)
			AddTrailModifier(caster, target, keys.ability, trailModifierName)
		end
	end
end

function ShouldPulseVision(caster, pulseFrequency)
	local shouldPulseVision = caster.lastVisionPulseTime == nil

	if not shouldPulseVision then
		local currentGameTime = GameRules:GetGameTime()
		shouldPulseVision = currentGameTime >= (caster.lastVisionPulseTime + pulseFrequency)
		caster.lastVisionPulseTime = currentGameTime
	end
	return shouldPulseVision
end

function AddTrailModifier(caster, target, ability, trailModifierName)
	if not caster:HasModifier(trailModifierName) then
		ability:ApplyDataDrivenModifier(caster, target, trailModifierName, nil)
	end
end

function GetVisionTargets(position)
	local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
																		position,
																		nil,
																		2400,
																		DOTA_UNIT_TARGET_TEAM_FRIENDLY,
																		DOTA_UNIT_TARGET_HERO,
																		DOTA_UNIT_TARGET_FLAG_NONE,
																		FIND_UNITS_EVERYWHERE,
																		false)
	return targets
end

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