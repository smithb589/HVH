
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

-- Might need a whitelist to prevent default charged items from breaking
function HVHItemUtils:IsChargedItem(item)
	itemName = item:GetName()
	if (itemName == "item_ward_sentry") or (itemName =="item_ward_observer") then
		return false -- hack fix to ignore them
	end
	
	return (item:GetInitialCharges() ~= 0)
end

function HVHItemUtils:ExpendCharge(item)
    -- could not find LUA for this simple function
    local hero = item:GetOwner()
    local newCharges = item:GetCurrentCharges() - 1
    item:SetCurrentCharges(newCharges)
    if newCharges <= 0 then
      hero:RemoveItem(item)
    end
end