

if HVHItemSpawnController == nil then
	HVHItemSpawnController = class({})
	HVHItemSpawnController._GoodGuyItems = {}
	HVHItemSpawnController._GoodGuyItems[1] = "item_treasure_chest_good_guys"
	--[[
	HVHItemSpawnController._GoodGuyItems[0] = "item_force_staff"
	HVHItemSpawnController._GoodGuyItems[1] = "item_sphere"
	HVHItemSpawnController._GoodGuyItems[2] = "item_lotus_orb"
	HVHItemSpawnController._GoodGuyItems[3] = "item_black_king_bar"
	HVHItemSpawnController._GoodGuyItems[4] = "item_ward_observer"
  	HVHItemSpawnController._GoodGuyItems[5] = "item_ward_sentry"
  	]]

	HVHItemSpawnController._BadGuyItems = {}
	HVHItemSpawnController._BadGuyItems[1] = "item_treasure_chest_bad_guys"
	--[[
	HVHItemSpawnController._BadGuyItems[0] = "item_force_staff"
	HVHItemSpawnController._BadGuyItems[1] = "item_blink"
	HVHItemSpawnController._BadGuyItems[2] = "item_meat_hook"
	HVHItemSpawnController._BadGuyItems[3] = "item_sheepstick"
	]]

	HVHItemSpawnController._Spawners = {}
	HVHItemSpawnController._Spawners[1] = "hvh_item_spawn_north"
	HVHItemSpawnController._Spawners[2] = "hvh_item_spawn_south"
	HVHItemSpawnController._Spawners[3] = "hvh_item_spawn_east"
	HVHItemSpawnController._Spawners[4] = "hvh_item_spawn_west"

	HVHItemSpawnController._ThinkInterval = 0.1

	HVHItemSpawnController._WasDayTimeLastThink = false

	HVHItemSpawnController._ItemsPerCycle = 2

	HVHItemSpawnController._SpawnedItems = {}
  --[[TODO:
   hunters: timber chain
   NS: shackle, dagon]]--
end

require("item_utils")
require("lib/util")
require("hvh_utils")

-- Needs to be called during game mode initialization.
function HVHItemSpawnController:Setup()
	local spawnCoordinator = Entities:FindByName(nil, "hvh_item_spawn_coordinator")
	spawnCoordinator:SetContextThink("HVHItemSpawnController", Dynamic_Wrap(HVHItemSpawnController, "Think"), self._ThinkInterval)

	self:_UpdateDayNightState()
end

-- Think method that is called to determine when to spawn items.
function HVHItemSpawnController:Think()
	if HVHItemSpawnController:DidDayNightStateChange() then
		HVHItemSpawnController:RemoveUnclaimedItems()
		HVHItemSpawnController:SpawnItemsForCycle()
	end

	HVHItemSpawnController:_UpdateDayNightState()
	-- Returning this sets the next think time.
	return HVHItemSpawnController._ThinkInterval
end

-- Gets the available item classes depending on the day/night state.
function HVHItemSpawnController:GetAvailableItemClasses()
	local availableItemClasses = {}
	if GameRules:IsDaytime() then
		availableItemClasses = self._GoodGuyItems
	else 
		availableItemClasses = self._BadGuyItems
	end
	return availableItemClasses
end

-- Spawns all items necessary for the current day/night cycle.
function HVHItemSpawnController:SpawnItemsForCycle()
	local availableItems = self:GetAvailableItemClasses()
	local spawnLocations = self:_GetRandomSpawnLocations(self._ItemsPerCycle)
	if spawnLocations then
		for key,location in pairs(spawnLocations) do
			local spawnedItem = self:SpawnRandomItem(availableItems, location)
			self:AddSpawnedItem(spawnedItem)
		end
	else
		print("No valid locations to spawn items.")
	end
end

-- Adds an item to the spawned item cache so that they can be reclaimed later.
function HVHItemSpawnController:AddSpawnedItem(spawnedItem)
	if spawnedItem then
	    table.insert(self._SpawnedItems, spawnedItem)
	else
		print("No item to add.")
	end
end

-- spawns a random item at the indicated location.
function HVHItemSpawnController:SpawnRandomItem(availableItems, location)
	local spawnedItem = nil
	if availableItems and location then
		local maxItemIndex = table.getn(availableItems)
		if maxItemIndex >= 0 then
			local itemIndex = RandomInt(1, maxItemIndex)
			spawnedItem = HVHItemUtils:SpawnItem(availableItems[itemIndex], location)
		end
	end

	return spawnedItem
end

-- Indicates if the day/night cycle changes since the last think.
function HVHItemSpawnController:DidDayNightStateChange()
	local isDaytime = GameRules:IsDaytime()
	return (isDaytime and not self._WasDayTimeLastThink) or (not isDaytime and self._WasDayTimeLastThink)
end

-- Removes all unclaimed items created by the spawner.
function HVHItemSpawnController:RemoveUnclaimedItems()
	for index,item in pairs(self._SpawnedItems) do
		--print(string.format("Attempting to remove item %s", item:GetName()))

		-- If the item was picked up, the world entity has been removed already
		-- and checking the item handle for null catches this.
		if not item:IsNull() then
			UTIL_Remove(item)
		end
	end

	self._SpawnedItems = {}
end

-- Updates the day/night cycle for this think.
function HVHItemSpawnController:_UpdateDayNightState()
	self._WasDayTimeLastThink = GameRules:IsDaytime()
end

-- Gets n random spawn locations.
function HVHItemSpawnController:_GetRandomSpawnLocations(numLocations)
	local spawnerClone = DeepCopy(self._Spawners)
	local spawnLocations = {}

	-- This uses the clone to remove an item from the possible choices.
	for locationCounter=1,numLocations do
		local randomSpawnerIndex = RandomInt(1, table.getn(spawnerClone))
		local spawner = Entities:FindByName(nil, spawnerClone[randomSpawnerIndex])
		if spawner then
			table.insert(spawnLocations, spawner:GetAbsOrigin())
		else
			print("No spawner to create item at.")
		end
		table.remove(spawnerClone, randomSpawnerIndex)
	end

	return spawnLocations
end