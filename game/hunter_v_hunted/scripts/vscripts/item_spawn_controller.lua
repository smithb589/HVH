
require("internal/item_randomizer")
require("internal/hvh_chest_model")
require("internal/hvh_location_collection")
require("internal/hvh_world_chest")

if HVHItemSpawnController == nil then
	HVHItemSpawnController = class({})
	HVHItemSpawnController._Spawners = {}

	HVHItemSpawnController._ThinkInterval = 1.0 -- //0.1
	HVHItemSpawnController._WasDayTimeLastThink = false

	HVHItemSpawnController._SpawnLocations = nil
	HVHItemSpawnController._SpawnedChests = {}

	HVHItemSpawnController._GoodGuyChestModel = HVHChestModel("scripts/vscripts/kv/good_guy_items.kv")
	HVHItemSpawnController._BadGuyChestModel = HVHChestModel("scripts/vscripts/kv/bad_guy_items.kv")
	HVHItemSpawnController._CurrentChestModel = nil
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

	-- This is a bit of a cheat to force spawns immediately.
	self:Think()
end

-- Think method that is called to determine when to spawn items.
function HVHItemSpawnController:Think()
	if HVHItemSpawnController:_DidDayNightStateChange() then
		HVHItemSpawnController:_RemoveUnclaimedItems()
		HVHItemSpawnController:_UpdateCurrentChestModel()
		HVHItemSpawnController:SpawnChestsForCycle()
	end

	HVHItemSpawnController:_UpdateDayNightState()
	-- Returning this sets the next think time.
	return HVHItemSpawnController._ThinkInterval
end

-- Spawns all items necessary for the current day/night cycle.
function HVHItemSpawnController:SpawnChestsForCycle()
	local availableChest = self._CurrentChestModel:GetChestName()
	local spawnLocations = self._SpawnLocations:GetRandomLocations(self._CurrentChestModel:GetItemsPerCycle())

	if spawnLocations then
		for _,location in pairs(spawnLocations) do
			local spawnedChest = HVHWorldChest()
			spawnedChest:Spawn(location, availableChest)
			self:_AddSpawnedItem(spawnedChest)
		end
	else
		HVHDebugPrint("No valid locations to spawn items.")
	end
end

-- Adds an item to the spawned item cache so that they can be reclaimed later.
function HVHItemSpawnController:_AddSpawnedItem(spawnedItem)
	if spawnedItem then
	    table.insert(self._SpawnedChests, spawnedItem)
	else
		HVHDebugPrint("No item to add.")
	end
end

-- Sets the current item chest to either the good guy or bad guy chest
function HVHItemSpawnController:_UpdateCurrentChestModel()
	if GameRules:IsDaytime() then
		self._CurrentChestModel = self._BadGuyChestModel
	else
		self._CurrentChestModel = self._GoodGuyChestModel
	end
end

-- Indicates if the day/night cycle changes since the last think.
function HVHItemSpawnController:_DidDayNightStateChange()
	local isDaytime = GameRules:IsDaytime()
	return (isDaytime and not self._WasDayTimeLastThink) or (not isDaytime and self._WasDayTimeLastThink)
end

-- Removes all unclaimed items created by the spawner.
function HVHItemSpawnController:_RemoveUnclaimedItems()
	HVHDebugPrint(string.format("Attempting to remove %d items.", table.getn(self._SpawnedChests)))
	for _,worldChest in pairs(self._SpawnedChests) do
		worldChest:Remove()
	end

	self._SpawnedChests = {}
end

-- Updates the day/night cycle for this think.
function HVHItemSpawnController:_UpdateDayNightState()
	self._WasDayTimeLastThink = GameRules:IsDaytime()
end

-- Handles a hero picking up a chest and either granting an item or rejecting the pickup
function HVHItemSpawnController:_OnItemPickedUp(keys)
	local itemName = keys.itemname
	-- Note that for a chest this is the chest item that is INSIDE the world chest entity
	local pickedUpItem = EntIndexToHScript(keys.ItemEntityIndex)
	local hero = EntIndexToHScript(keys.HeroEntityIndex)

	if self:_CanGrantGoodGuyItem(itemName, hero) then
		self:_GrantItem(self._GoodGuyChestModel:GetRandomItemName(), hero, pickedUpItem)
	elseif self:_CanGrantBadGuyItem(itemName, hero) then
		self:_GrantItem(self._BadGuyChestModel:GetRandomItemName(), hero, pickedUpItem)
	elseif self:_IsChestItem(itemName) then
		self:_RejectPickup(pickedUpItem, itemName)
	end
end

function HVHItemSpawnController:_IsChestItem(itemName)
	return self._GoodGuyChestModel:IsChestItemName(itemName) or self._BadGuyChestModel:IsChestItemName(itemName)
end

function HVHItemSpawnController:_CanGrantGoodGuyItem(itemName, hero)
	return self._GoodGuyChestModel:IsChestItemName(itemName) and (hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS)
end

function HVHItemSpawnController:_CanGrantBadGuyItem(itemName, hero)
	return self._BadGuyChestModel:IsChestItemName(itemName) and (hero:GetTeamNumber() == DOTA_TEAM_BADGUYS)
end

-- Looks up a world chest from the spawned chests using the entity index
function HVHItemSpawnController:_GetWorldChest(containedItem)
	local worldChest = nil

	for _,chest in pairs(self._SpawnedChests) do
		if chest:IsContainedItem(containedItem) then
			worldChest = chest
			break
		end
	end

	return worldChest
end

-- Grants an item from the available items to the hero.
function HVHItemSpawnController:_GrantItem(itemName, hero, chestItem)
	if itemName and hero then
		hero:AddItemByName(itemName)
		Timers:CreateTimer(SINGLE_FRAME_TIME, function()
			self:_DropStashItems(hero)
		end)
	else
		HVHDebugPrint(string.format("Could not grant item %s to hero %d.", itemName, hero:GetEntityIndex()))
	end

	-- Note that the world chest here is likely not the same entity index that we have stored.
	self:_CleanupWorldChestForContainedItem(chestItem)
end

function HVHItemSpawnController:_CleanupWorldChestForContainedItem(containedItem)
	local worldChest = self:_GetWorldChest(containedItem)
	DoScriptAssert(worldChest ~= nil, "No chest found for cleanup.")

    if worldChest then
    	worldChest:Remove()
    end
end

-- Prevents expending the chest by replacing it with another.
function HVHItemSpawnController:_RejectPickup(chest, chestType)
	local nearestSpawnLocation = self:_FindNearestSpawnLocation(chest:GetLocation())
	if not nearestSpawnLocation then nearestSpawnLocation = chest:GetLocation() end
	local replacedChest = HVHWorldChest()
	replacedChest:Spawn(nearestSpawnLocation, chestType)
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