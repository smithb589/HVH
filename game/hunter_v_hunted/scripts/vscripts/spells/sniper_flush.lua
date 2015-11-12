
function OnSpellStart(keys)
	local caster  = keys.caster
	local flushAbility   = keys.ability
	local flushDuration = flushAbility:GetSpecialValueFor("duration")

	local feedAbility = caster:FindAbilityByName("sniper_feed_dog")
	local feedDuration = feedAbility:GetSpecialValueFor("feed_duration")
	local loyaltyDuration = feedAbility:GetSpecialValueFor("loyalty_duration")

	-- find all hounds
	local creatureList = Entities:FindAllByClassname("npc_dota_creature")
	local houndList = {}
	for _,creature in pairs(creatureList) do
		if creature:GetUnitName() == "npc_dota_good_guy_dog" then
			table.insert(houndList, creature)
		end
	end

	-- apply flush modifier and create loyalty to houndmaster
	for _,hound in pairs(houndList) do
		flushAbility:ApplyDataDrivenModifier(caster, hound, "modifier_flush", { duration = flushDuration })
		hound:FedBy(caster, feedDuration, loyaltyDuration)

		-- add and remove gem for truesight vision
		hound:AddItemByName("item_gem")
		Timers:CreateTimer(flushDuration, function()
			if HVHDogUtils:IsTargetValid(hound) then
				local gem = HVHItemUtils:GetItemByName(hound, "item_gem")
				UTIL_Remove(gem)
			end
		end)

	end

end