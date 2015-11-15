function CreateAssassinateItem(keys)
	local hero = keys.caster
	hero:AddItemByName("item_assassinate")
    Timers:CreateTimer(SINGLE_FRAME_TIME, function()
		HVHItemUtils:DropStashItems(hero)
   	end)

	local voiceStrings = {
		"sniper_snip_bottle_01", "sniper_snip_bottle_02", "sniper_snip_bottle_03",
		"sniper_snip_kill_arrow_07", "sniper_snip_kill_arrow_08",
		"sniper_snip_rare_01", "sniper_snip_rare_02",
		"sniper_snip_rare_03", "sniper_snip_rare_04",
		"sniper_snip_tf2_06", "sniper_snip_tf2_08", "sniper_snip_cast_01",
		"sniper_snip_happy_01",	"sniper_snip_happy_02",	"sniper_snip_happy_03",
		"sniper_snip_purch_01",	"sniper_snip_purch_02",	"sniper_snip_purch_03"
	}

	local r = RandomInt(1, #voiceStrings)
	EmitSoundOn(voiceStrings[r], hero)
end