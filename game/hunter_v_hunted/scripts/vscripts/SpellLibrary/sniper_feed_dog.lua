
function Feed(keys)
	local targets = keys.target_entities
	for index,entity in pairs(targets) do
		if entity.Feed then
			entity:Feed(keys.feedDuration)
		end
	end
end