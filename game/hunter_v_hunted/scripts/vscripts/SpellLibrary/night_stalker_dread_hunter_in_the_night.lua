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

	ResetInvisDelay(caster, ability, mod_invis)
end

function OnAbilityExecuted(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis

	ResetInvisDelay(caster, ability, mod_invis)
end

function OnUnitMoved(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_invis = keys.mod_invis

	if GameRules:IsDaytime() then
		ResetInvisDelay(caster, ability, mod_invis)
	end
end

function ResetInvisDelay(caster, ability, mod_invis)
	if caster:HasModifier(mod_invis) then
		caster:RemoveModifierByName(mod_invis)
	end

	local timerName = "NSInvisDelay" .. caster:entindex()
	Timers:RemoveTimer(timerName)
    Timers:CreateTimer(timerName, {
      useGameTime = true,
      endTime = ability:GetSpecialValueFor("invis_delay"),
      callback = function()
      	ability:ApplyDataDrivenModifier(caster, caster, mod_invis, {})
	  end
	})
	
end