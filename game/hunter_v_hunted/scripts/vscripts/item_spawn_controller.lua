

if HVHItemSpawnController == nil then
	HVHItemSpawnController = class({})

	HVHItemSpawnController._GoodGuyChest = "item_treasure_chest_good_guys"
	HVHItemSpawnController._GoodGuyItems = {}
	HVHItemSpawnController._GoodGuyItems[1] = "item_force_staff"
	HVHItemSpawnController._GoodGuyItems[2] = "item_sphere"
	HVHItemSpawnController._GoodGuyItems[3] = "item_lotus_orb"
	HVHItemSpawnController._GoodGuyItems[4] = "item_black_king_bar"
	HVHItemSpawnController._GoodGuyItems[5] = "item_ward_observer"
  	HVHItemSpawnController._GoodGuyItems[6] = "item_ward_sentry"

	HVHItemSpawnController._BadGuyChest = "item_treasure_chest_bad_guys"
	HVHItemSpawnController._BadGuyItems = {}
	HVHItemSpawnController._BadGuyItems[1] = "item_force_staff"
	HVHItemSpawnController._BadGuyItems[2] = "item_blink"
	HVHItemSpawnController._BadGuyItems[3] = "item_meat_hook"
	HVHItemSpawnController._BadGuyItems[4] = "item_sheepstick"

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
	spawnCoordinator:SetContextThink("HVHItemSpawnController", Dynamic_Wrap(self, "Think"), self._ThinkInterval)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(self, "_OnItemPickedUp"), self) 

	self:_UpdateDayNightState()
end

-- Think method that is called to determine when to spawn items.
function HVHItemSpawnController:Think()
	if HVHItemSpawnController:_DidDayNightStateChange() then
		HVHItemSpawnController:_RemoveUnclaimedItems()
		HVHItemSpawnController:SpawnChestsForCycle()
	end

	HVHItemSpawnController:_UpdateDayNightState()
	-- Returning this sets the next think time.
	return HVHItemSpawnController._ThinkInterval
end

-- Spawns all items necessary for the current day/night cycle.
function HVHItemSpawnController:SpawnChestsForCycle()
	local availableChest = self:_GetAvailableChestClass()
	local spawnLocations = self:_GetRandomSpawnLocations(self._ItemsPerCycle)
	if spawnLocations then
		for key,location in pairs(spawnLocations) do
			local spawnedChest = HVHItemUtils:SpawnItem(availableChest, location)
			self:_AddSpawnedItem(spawnedChest)
		end
	else
		HVHDebugPrint("No valid locations to spawn items.")
	end
end

-- Adds an item to the spawned item cache so that they can be reclaimed later.
function HVHItemSpawnController:_AddSpawnedItem(spawnedItem)
	if spawnedItem then
	    table.insert(self._SpawnedItems, spawnedItem)
	else
		HVHDebugPrint("No item to add.")
	end
end

-- Creates a random item.
function HVHItemSpawnController:_GetRandomItemName(availableItems)
	local item = nil
	if availableItems then
		local maxItemIndex = table.getn(availableItems)
		if maxItemIndex >= 0 then
			local itemIndex = RandomInt(1, maxItemIndex)
			item = availableItems[itemIndex]
		end
	end

	return item
end

-- Indicates if the day/night cycle changes since the last think.
function HVHItemSpawnController:_DidDayNightStateChange()
	local isDaytime = GameRules:IsDaytime()
	return (isDaytime and not self._WasDayTimeLastThink) or (not isDaytime and self._WasDayTimeLastThink)
end

-- Removes all unclaimed items created by the spawner.
function HVHItemSpawnController:_RemoveUnclaimedItems()
	HVHDebugPrint(string.format("Attempting to remove %d items.", table.getn(self._SpawnedItems)))
	for index,item in pairs(self._SpawnedItems) do
		-- If the item was picked up, the world entity has been removed already
		-- and checking the item handle for null catches this.
		if not item:IsNull() then
			print(string.format("Attempting to remove item %s", item:GetName()))
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
			HVHDebugPrint("No spawner to create item at.")
		end
		table.remove(spawnerClone, randomSpawnerIndex)
	end

	return spawnLocations
end

-- Gets the available item classes depending on the chest type.
function HVHItemSpawnController:_GetAvailableItemClasses(chestType)
	local availableItemClasses = {}
	if chestType == self._GoodGuyChest then
		availableItemClasses = self._GoodGuyItems
	elseif chestType == self._BadGuyChest then
		availableItemClasses = self._BadGuyItems
	else
		HVHDebugPrint(string.format("Invalid chest type: %s", chestType))
	end
	return availableItemClasses
end

-- Gets the chest class depending on the time of day.
function HVHItemSpawnController:_GetAvailableChestClass()
	local availableChestClass = nil
	if GameRules:IsDaytime() then
		availableChestClass = self._GoodGuyChest
	else
		availableChestClass = self._BadGuyChest
	end

	return availableChestClass
end

-- Handles a hero picking up a chest and either granting an item or rejecting the pickup
function HVHItemSpawnController:_OnItemPickedUp(keys)
	local itemName = keys.itemname
	--local playerID = keys.PlayerID
	local item = EntIndexToHScript(keys.ItemEntityIndex)
	local hero = EntIndexToHScript(keys.HeroEntityIndex)

	if (itemName == self._GoodGuyChest) and (hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
		local availableItems = self:_GetAvailableItemClasses(itemName)
		self:_GrantItem(availableItems, hero)
	elseif (itemName == self._BadGuyChest) and (hero:GetTeamNumber() == DOTA_TEAM_BADGUYS) then
		local availableItems = self:_GetAvailableItemClasses(itemName)
		self:_GrantItem(availableItems, hero)
	else
		self:_RejectPickup(item, itemName)
	end
end

function HVHItemSpawnController:_GrantItem(availableItems, hero)
	local item = self:_GetRandomItemName(availableItems)

	if item and hero then
		hero:AddItemByName(item)
	end
end

function HVHItemSpawnController:_RejectPickup(chest, chestType)
	local nearestSpawnLocation = self:_FindNearestSpawnLocation(chest:GetAbsOrigin())
	if not nearestSpawnLocation then nearestSpawnLocation = chest:GetAbsOrigin() end
	local replacedChest = HVHItemUtils:SpawnItem(chestType, nearestSpawnLocation)
	self:_AddSpawnedItem(replacedChest)
end

function HVHItemSpawnController:_FindNearestSpawnLocation(position)
	local nearest = nil
	for index,spawnerName in pairs(self._Spawners) do
		local spawner = Entities:FindByNameNearest(spawnerName, position, 600)
		if spawner then
			nearest = spawner:GetAbsOrigin()
		end
	end
	return nearest
end