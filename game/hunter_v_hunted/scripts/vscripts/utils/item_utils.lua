
if HVHItemUtils == nil then
  HVHItemUtils = class({})

  MAX_INVENTORY_ITEMS = 6
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
		(itemName == "item_urn_of_shadows")	or
		(itemName == "item_sun_shard_hvh") then
		return false -- hack fix to ignore these items and let Valve subtract charges normally
	end
	
	return (item:GetInitialCharges() ~= 0)
end

-- could not find LUA for this simple function
function HVHItemUtils:ExpendCharge(item)
    local hero = item:GetOwner()
    local newCharges = item:GetCurrentCharges() - 1
    item:SetCurrentCharges(newCharges)

	Timers:CreateTimer(0.25, function() -- SINGLE_FRAME_TIME too short for item_manta
		if item:GetCurrentCharges() <= 0 then -- recheck in case the charge was refunded
	    	hero:RemoveItem(item)
	    end
    end)
    
end

function HVHItemUtils:RefundCharge(hero, item_name)
	local item = self:GetItemByName(hero, item_name)
    local newCharges = item:GetCurrentCharges() + 1
    item:SetCurrentCharges(newCharges)
end

function HVHItemUtils:GetItemByName(caster, item_name)
  for i=DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
    local item = caster:GetItemInSlot(i)
    if item and item:GetAbilityName() == item_name then
      return item
    end
  end
end

-- Forces items from a unit's stash to be dropped at the unit's location.
function HVHItemUtils:DropStashItems(unit)
  local hasItemsInStash = unit:GetNumItemsInStash() > 0
  if hasItemsInStash then
    for stashSlot=DOTA_STASH_SLOT_1,DOTA_STASH_SLOT_6 do
      local stashItem = unit:GetItemInSlot(stashSlot)
      self:DropItemFromStash(stashItem, unit)
    end
  end
end

-- Drops an item from a unit's stash at the unit's current location.
function HVHItemUtils:DropItemFromStash(stashItem, unit)
  if stashItem and unit then
    local itemName = stashItem:GetName()
    unit:RemoveItem(stashItem)
    self:SpawnItem(itemName, unit:GetAbsOrigin())
  end
end

-- add item to unit's inventory; if full, launch it
-- returns a handle to the item
function HVHItemUtils:AddItemOrLaunchIt(unit, itemName)
	local totalItems = unit:GetNumItemsInInventory()
	
	-- stack matching sun shards, or check if total items < max
	if (itemName == "item_sun_shard_hvh" and unit:HasItemInInventory("item_sun_shard_hvh")) or
	  totalItems < MAX_INVENTORY_ITEMS then
	
		return unit:AddItemByName(itemName)
	
	-- otherwise launch it
	else
	    local pos = unit:GetAbsOrigin()
		local item = CreateItem(itemName, nil, nil)
		local drop = CreateItemOnPositionForLaunch(pos, item)
	    local pos_launch = pos + RandomVector(RandomFloat(150,200))
	    item:LaunchLoot(false, 200, 0.75, pos_launch)

	    return item
	end
end