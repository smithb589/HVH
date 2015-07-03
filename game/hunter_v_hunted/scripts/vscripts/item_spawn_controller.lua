

if HVHItemSpawnController == nil then
	HVHItemSpawnController = class({})
	HVHItemSpawnController._GoodGuyItems = {}
	HVHItemSpawnController._GoodGuyItems[0] = "item_force_staff"
	HVHItemSpawnController._GoodGuyItems[1] = "item_sphere"
	HVHItemSpawnController._GoodGuyItems[2] = "item_lotus_orb"
	HVHItemSpawnController._GoodGuyItems[3] = "item_black_king_bar"
	HVHItemSpawnController._GoodGuyItems[4] = "item_ward_observer"
  	HVHItemSpawnController._GoodGuyItems[5] = "item_ward_sentry"

	HVHItemSpawnController._BadGuyItems = {}
	HVHItemSpawnController._BadGuyItems[0] = "item_force_staff"
	HVHItemSpawnController._BadGuyItems[1] = "item_blink"
	HVHItemSpawnController._BadGuyItems[2] = "item_invis_sword"
	HVHItemSpawnController._BadGuyItems[3] = "item_sheepstick"

	HVHItemSpawnController._Spawners = {}
	HVHItemSpawnController._Spawners[0] = "hvh_item_spawn_north"
	HVHItemSpawnController._Spawners[1] = "hvh_item_spawn_south"
	HVHItemSpawnController._Spawners[2] = "hvh_item_spawn_east"
	HVHItemSpawnController._Spawners[3] = "hvh_item_spawn_west"

	HVHItemSpawnController._ThinkInterval = 0.1

	HVHItemSpawnController._WasDayTimeLastThink = false

	HVHItemSpawnController._ItemsPerCycle = 2

	HVHItemSpawnController._SpawnedItems = {}
  --[[TODO:
   hunters: timber chain
   NS: pudge hook, shackle, dagon]]--
end

require("item_utils")
require("lib/util")
require("hvh_utils")

function HVHItemSpawnController:Setup()
	local spawnCoordinator = Entities:FindByName(nil, "hvh_item_spawn_coordinator")
	spawnCoordinator:SetContextThink("HVHItemSpawnController", Dynamic_Wrap(HVHItemSpawnController, "Think"), self._ThinkInterval)

	self:_UpdateDayNightState()
end

function HVHItemSpawnController:Think()
	if HVHItemSpawnController:DidDayNightStateChange() then
		HVHItemSpawnController:RemoveUnclaimedItems()
		HVHItemSpawnController:SpawnItemsForCycle()
	end

	HVHItemSpawnController:_UpdateDayNightState()
	-- Returning this sets the next think time.
	return HVHItemSpawnController._ThinkInterval
end

function HVHItemSpawnController:GetAvailableItemClasses()
	local availableItemClasses = {}
	if GameRules:IsDaytime() then
		availableItemClasses = self._GoodGuyItems
	else 
		availableItemClasses = self._BadGuyItems
	end
	return availableItemClasses
end

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

function HVHItemSpawnController:AddSpawnedItem(spawnedItem)
	if spawnedItem then
	    table.insert(self._SpawnedItems, spawnedItem)
	else
		print("No item to add.")
	end
end

function HVHItemSpawnController:SpawnRandomItem(availableItems, location)
	local spawnedItem = nil
	if availableItems and location then
		local maxItemIndex = table.getn(availableItems)
		if maxItemIndex >= 0 then
			local itemIndex = RandomInt(0, maxItemIndex - 1)
			spawnedItem = HVHItemUtils:SpawnItem(availableItems[itemIndex], location)
		end
	end

	return spawnedItem
end

function HVHItemSpawnController:DidDayNightStateChange()
	local isDaytime = GameRules:IsDaytime()
	return (isDaytime and not self._WasDayTimeLastThink) or (not isDaytime and self._WasDayTimeLastThink)
end

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

function HVHItemSpawnController:_UpdateDayNightState()
	self._WasDayTimeLastThink = GameRules:IsDaytime()
end

function HVHItemSpawnController:_GetRandomSpawnLocations(numLocations)
	local spawnerClone = DeepCopy(self._Spawners)
	local spawnLocations = {}

	-- This uses the clone to remove an item from the possible choices.
	for locationCounter=1,numLocations do
		local randomSpawnerIndex = RandomInt(0, table.getn(spawnerClone) - 1)
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