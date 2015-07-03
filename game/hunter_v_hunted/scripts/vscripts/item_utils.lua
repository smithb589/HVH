
if HVHItemUtils == nil then
  HVHItemUtils = class({})
end

-- Takes the item class name of the item to spawn and the vector position to spawn the item at.
function HVHItemUtils:SpawnItem(itemName, position)
	local droppedItem = nil
	local item = CreateItem(itemName, nil, nil)
	if item then
		droppedItem = CreateItemOnPositionSync(position, item)
		if droppedItem then
			droppedItem:SetContainedItem(item)
		else
			print(string.format("Failed to drop item: %s.", itemName))
		end
	else
		print(string.format("Item %s not created.", itemName))
	end

	return droppedItem
end