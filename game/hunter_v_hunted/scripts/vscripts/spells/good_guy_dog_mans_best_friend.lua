
function ManageAura(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier

	if GameRules:IsDaytime() and not caster:HasModifier(modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	elseif not GameRules:IsDaytime() and caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
	end
end