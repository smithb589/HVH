
function Feed(keys)
	local targets = keys.target_entities
	for index,entity in pairs(targets) do
		if entity.FedBy then
			entity:FedBy(keys.caster, keys.feedDuration, keys.loyaltyDuration)
		end
	end
end