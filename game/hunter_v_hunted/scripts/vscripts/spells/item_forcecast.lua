function ForceCast( keys )
	local caster = keys.caster
	local abilityName = keys.abilityName
	local maxDuration = keys.maxDuration
	DoForceCast(caster, abilityName, maxDuration)
end