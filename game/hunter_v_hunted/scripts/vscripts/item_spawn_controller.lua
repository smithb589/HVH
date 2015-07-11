

if HVHItemSpawnController == nil then
	HVHItemSpawnController = class({})
	HVHItemSpawnController._Spawners = {
		"hvh_item_spawn_north",
		"hvh_item_spawn_south",
		"hvh_item_spawn_east",
		"hvh_item_spawn_west"
	}

	HVHItemSpawnController._ThinkInterval = 1.0 -- //0.1
	HVHItemSpawnController._WasDayTimeLastThink = false
	HVHItemSpawnController._ItemsPerCycle = 4
	HVHItemSpawnController._SpawnedItems = {}

	HVHItemSpawnController._GoodGuyChest = "item_treasure_chest_good_guys"
	HVHItemSpawnController._GoodGuyItems = {
		"item_flask", -- healing salve
		"item_dust",
		"item_tango",
		"item_ward_observer",
		"item_ward_sentry",
		"item_force_staff",
		--"item_sphere", --TODO: removed until i know what to do with it
		"item_lotus_orb",
		"item_black_king_bar",
		"item_urn_of_shadows",
		"item_crimson_guard",
		--"item_solar_crest", -- disabling broken items that need to be customized probably
		"item_pipe",
		"item_buckler",
		"item_ghost",
		"item_mekansm",
		--"item_medallion_of_courage",
		"item_manta",
		"item_cyclone"
	}

	HVHItemSpawnController._BadGuyChest = "item_treasure_chest_bad_guys"
	HVHItemSpawnController._BadGuyItems = {
		"item_smoke_of_deceit",
		"item_quelling_blade",
		"item_magic_stick",
		"item_force_staff",
		"item_blink",
		"item_meat_hook",
		"item_sheepstick",
		"item_invis_sword",
		"item_veil_of_discord",
		"item_dagon",
		"item_abyssal_blade",
		"item_blade_mail",
		"item_manta",
		--"item_satanic",
		"item_mask_of_madness",
		"item_mjollnir",
		"item_diffusal_blade"
	}

  --[[TODO:
   hunters: timber chain
   NS: shackle, dagon]]--
end

require("item_utils")
require("lib/util")
require("hvh_utils")
require("lib/timers")
require("hvh_constants")

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
	if not GameRules:IsDaytime() then
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
	local chestItem = EntIndexToHScript(keys.ItemEntityIndex)
	local hero = EntIndexToHScript(keys.HeroEntityIndex)

	-- Ignore non-chest items.
	if (itemName == self._GoodGuyChest) or (itemName == self._BadGuyChest) then
		if (itemName == self._GoodGuyChest) and (hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS) then
			local availableItems = self:_GetAvailableItemClasses(itemName)
			self:_GrantItem(availableItems, hero, chestItem)
		elseif (itemName == self._BadGuyChest) and (hero:GetTeamNumber() == DOTA_TEAM_BADGUYS) then
			local availableItems = self:_GetAvailableItemClasses(itemName)
			self:_GrantItem(availableItems, hero, chestItem)
		else
			self:_RejectPickup(chestItem, itemName)
		end
	end
end

-- Grants an item from the available items to the hero.
function HVHItemSpawnController:_GrantItem(availableItems, hero, chestItem)
	local itemName = self:_GetRandomItemName(availableItems)

	if itemName and hero then
		hero:AddItemByName(itemName)
		Timers:CreateTimer(SINGLE_FRAME_TIME, function()
			self:_DropStashItems(hero)
		end)
	end
end

-- Prevents expending the chest by replacing it with another.
function HVHItemSpawnController:_RejectPickup(chest, chestType)
	local nearestSpawnLocation = self:_FindNearestSpawnLocation(chest:GetAbsOrigin())
	if not nearestSpawnLocation then nearestSpawnLocation = chest:GetAbsOrigin() end
	local replacedChest = HVHItemUtils:SpawnItem(chestType, nearestSpawnLocation)
	self:_AddSpawnedItem(replacedChest)
end

function HVHItemSpawnController:_DropStashItems(hero)
	local hasItemsInStash = hero:GetNumItemsInStash() > 0
	if hasItemsInStash then
		for stashSlot=DOTA_STASH_SLOT_1,DOTA_STASH_SLOT_6 do
			local stashItem = hero:GetItemInSlot(stashSlot)
			self:_DropItemFromStash(stashItem, hero)
		end
	end
end

function HVHItemSpawnController:_DropItemFromStash(stashItem, hero)
	if stashItem and hero then
		local itemName = stashItem:GetName()
		hero:RemoveItem(stashItem)
		HVHItemUtils:SpawnItem(itemName, hero:GetAbsOrigin())
	end
end

-- Finds the nearest spawner in a small radius.
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