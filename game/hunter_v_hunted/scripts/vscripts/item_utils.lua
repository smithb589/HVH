
if HVHItemUtils == nil then
  HVHItemUtils = class({})
end

-- Takes the item class name of the item to spawn and the vector position to spawn the item at.
function HVHItemUtils:SpawnItem(itemName, position)
	local droppedItem = nil
	local item = CreateItem(itemName, nil, nil)
	return self:DropItem(item, position)
end

function HVHItemUtils:DropItem(item, position)
	local droppedItem = nil
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

function HVHItemUtils:IsChargedItem(item)
	itemName = item:GetName()
	if  (itemName == "item_ward_sentry") or
		(itemName == "item_ward_observer") or
		(itemName == "item_flask") or
		(itemName == "item_tango") or
		(itemName == "item_tango_single") or
		(itemName == "item_smoke_of_deceit") or
		(itemName == "item_dust") or
		(itemName == "item_diffusal_blade") or
		(itemName == "item_urn_of_shadows")	then
		return false -- hack fix to ignore these items and let Valve subtract charges normally
	end
	
	return (item:GetInitialCharges() ~= 0)
end

-- could not find LUA for this simple function
function HVHItemUtils:ExpendCharge(item)

	-- hack fix for magic stick not deleting on use
    local remove = 0
    if item:GetName() == "item_magic_stick" then
    	remove = 1
    end

    local hero = item:GetOwner()
    local newCharges = item:GetCurrentCharges() - 1
    item:SetCurrentCharges(newCharges)
    if newCharges <= 0 or remove == 1 then
		Timers:CreateTimer(SINGLE_FRAME_TIME, function()
	    	hero:RemoveItem(item)
	    end
	  	)
    end
    
end

--[[
function HVHItemUtils:HeroHasRoomForItem(hero, itemName)
	local hasRoom = hero:GetNumItemsInInventory() <= 6
	local tempItem = CreateItem(itemName, nil, nil)

	-- Handle charged items
	if not hasRoom then
		hasRoom = hero:HasItemInInventory(itemName) and self:IsChargedItem(tempItem)
	end

	-- Handle stackable items
	if not hasRoom then
		hasRoom = hero:HasItemInInventory(itemName) and tempItem:IsStackable()
	end

	return hasRoom
end
]]