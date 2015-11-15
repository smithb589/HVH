function InitializeAssassinate(keys)
	local hero = keys.caster
	local ability = keys.ability
	local target = keys.target

	-- grants vision, but must be forcibly removed if cancelled early
	target:AddNewModifier(hero, ability, "modifier_sniper_assassinate", {duration=4.0})

	-- sound effects
	local loadString = "Ability.AssassinateLoad"
	local voiceStrings = { "sniper_snip_ability_assass_05", "sniper_snip_ability_assass_06", "sniper_snip_ability_assass_07",
		"sniper_snip_ability_assass_08", "sniper_snip_ability_assass_09", "sniper_snip_ability_assass_10",
		"sniper_snip_ability_assass_11", "sniper_snip_attack_03", "sniper_snip_attack_04", "sniper_snip_attack_05",
		"sniper_snip_attack_07", "sniper_snip_attack_09", "sniper_snip_attack_10", "sniper_snip_attack_12",
		"sniper_snip_cast_01", "sniper_snip_cast_02" }
	EmitSoundOn(loadString, hero)
	Timers:CreateTimer(0.5, function()
		local r = RandomInt(1, #voiceStrings)
		EmitSoundOn(voiceStrings[r], hero)
	end)
end