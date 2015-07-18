
require("internal/item_randomizer")
require("internal/hvh_item_chest")
require("internal/hvh_location_collection")

if HVHItemSpawnController == nil then
	HVHItemSpawnController = class({})
	HVHItemSpawnController._Spawners = {}

	HVHItemSpawnController._ThinkInterval = 1.0 -- //0.1
	HVHItemSpawnController._WasDayTimeLastThink = false

	HVHItemSpawnController._SpawnLocations = nil
	HVHItemSpawnController._SpawnedItems = {}

	HVHItemSpawnController._GoodGuyItemChest = HVHItemChest("scripts/vscripts/kv/good_guy_items.kv")
	HVHItemSpawnController._BadGuyItemChest = HVHItemChest("scripts/vscripts/kv/bad_guy_items.kv")
	HVHItemSpawnController._CurrentItemChest = nil
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

	HVHItemSpawnController._SpawnLocations = HVHLocationCollection("dota_item_spawner")

	self:_UpdateDayNightState()
end

-- Think method that is called to determine when to spawn items.
function HVHItemSpawnController:Think()
	if HVHItemSpawnController:_DidDayNightStateChange() then
		HVHItemSpawnController:_RemoveUnclaimedItems()
		HVHItemSpawnController:_UpdateCurrentItemChest()
		HVHItemSpawnController:SpawnChestsForCycle()
	end

	HVHItemSpawnController:_UpdateDayNightState()
	-- Returning this sets the next think time.
	return HVHItemSpawnController._ThinkInterval
end

-- Spawns all items necessary for the current day/night cycle.
function HVHItemSpawnController:SpawnChestsForCycle()
	local availableChest = self._CurrentItemChest:GetChestName()
	local spawnLocations = self._SpawnLocations:GetRandomLocations(self._CurrentItemChest:GetItemsPerCycle())

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

function HVHItemSpawnController:_UpdateCurrentItemChest()
	if GameRules:IsDaytime() then
		self._CurrentItemChest = self._BadGuyItemChest
	else
		self._CurrentItemChest = self._GoodGuyItemChest
	end
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

-- Handles a hero picking up a chest and either granting an item or rejecting the pickup
function HVHItemSpawnController:_OnItemPickedUp(keys)
	local itemName = keys.itemname
	local chestItem = EntIndexToHScript(keys.ItemEntityIndex)
	local hero = EntIndexToHScript(keys.HeroEntityIndex)

	if self:_CanGrantGoodGuyItem(itemName, hero) then
		self:_GrantItem(self._GoodGuyItemChest:GetRandomItemName(), hero, chestItem)
	elseif self:_CanGrantBadGuyItem(itemName, hero) then
		self:_GrantItem(self._BadGuyItemChest:GetRandomItemName(), hero, chestItem)
	elseif self:_IsChestItem(itemName) then
		self:_RejectPickup(chestItem, itemName)
	end
end

function HVHItemSpawnController:_IsChestItem(itemName)
	return self._GoodGuyItemChest:IsChestItemName(itemName) or self._BadGuyItemChest:IsChestItemName(itemName)
end

function HVHItemSpawnController:_CanGrantGoodGuyItem(itemName, hero)
	return self._GoodGuyItemChest:IsChestItemName(itemName) and (hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS)
end

function HVHItemSpawnController:_CanGrantBadGuyItem(itemName, hero)
	return self._BadGuyItemChest:IsChestItemName(itemName) and (hero:GetTeamNumber() == DOTA_TEAM_BADGUYS)
end

-- Grants an item from the available items to the hero.
function HVHItemSpawnController:_GrantItem(itemName, hero, chestItem)
	if itemName and hero then
		hero:AddItemByName(itemName)
		Timers:CreateTimer(SINGLE_FRAME_TIME, function()
			self:_DropStashItems(hero)
		end)
	else
		HVHDebugPrint("No item randomizer to grant item with.")
	end
end

-- Prevents expending the chest by replacing it with another.
function HVHItemSpawnController:_RejectPickup(chest, chestType)
	local nearestSpawnLocation = self:_FindNearestSpawnLocation(chest:GetAbsOrigin())
	if not nearestSpawnLocation then nearestSpawnLocation = chest:GetAbsOrigin() end
	local replacedChest = HVHItemUtils:SpawnItem(chestType, nearestSpawnLocation)
	self:_AddSpawnedItem(replacedChest)
end

-- Forces items from a hero's stash to be dropped at the hero's location.
function HVHItemSpawnController:_DropStashItems(hero)
	local hasItemsInStash = hero:GetNumItemsInStash() > 0
	if hasItemsInStash then
		for stashSlot=DOTA_STASH_SLOT_1,DOTA_STASH_SLOT_6 do
			local stashItem = hero:GetItemInSlot(stashSlot)
			self:_DropItemFromStash(stashItem, hero)
		end
	end
end

-- Drops an item from a hero's stash at the hero's current location.
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