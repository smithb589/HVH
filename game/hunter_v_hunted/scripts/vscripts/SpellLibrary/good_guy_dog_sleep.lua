
function GoToSleep(keys)
	local caster = keys.caster
	local ability = keys.ability
	local mod_fade = keys.mod_fade
	local mod_sleep = keys.mod_sleep
	local delay = keys.delay

	-- apply mod_fade at night (which becomes mod_sleep)
	if not GameRules:IsDaytime() then
		if not caster:HasModifier(mod_fade) and not caster:HasModifier(mod_sleep) then
			StartAnimation(caster, {duration=delay, activity=ACT_DOTA_IDLE_RARE, rate=1.0})
			ability:ApplyDataDrivenModifier(caster, caster, mod_fade, {})
		end
	-- remove mod_sleep during day
	elseif caster:HasModifier(mod_sleep) then
		caster:RemoveModifierByName(mod_sleep)
	end
end