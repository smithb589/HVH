
require("internal/hvh_chest_model")
require("internal/hvh_location_collection")
require("internal/hvh_world_chest")

require("lib/timers")
require("lib/util")

require("item_utils")
require("hvh_utils")
require("hvh_constants")

if HVHItemSpawnController == nil then
	HVHItemSpawnController = class({})

	HVHItemSpawnController._thinkInterval = 1.0 -- //0.1
	HVHItemSpawnController._wasDayTimeLastThink = false

	HVHItemSpawnController._spawnLocations = nil
	HVHItemSpawnController._spawnedChests = {}

	HVHItemSpawnController._goodGuyChestDataModel = HVHChestModel("scripts/vscripts/kv/good_guy_chests.kv")
	HVHItemSpawnController._badGuyChestDataModel = HVHChestModel("scripts/vscripts/kv/bad_guy_chests.kv")
	HVHItemSpawnController._currentChestDataModel = nil
end

-- Needs to be called during game mode initialization.
function HVHItemSpawnController:Setup()
	local spawnCoordinator = Entities:FindByName(nil, "hvh_item_spawn_coordinator")
	spawnCoordinator:SetContextThink("HVHItemSpawnController", Dynamic_Wrap(self, "Think"), self._thinkInterval)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(self, "_OnItemPickedUp"), self) 

	HVHItemSpawnController._spawnLocations = HVHLocationCollection("dota_item_spawner")

	-- This is a bit of a cheat to force spawns immediately.
	self:Think()
end

-- Think method that is called to determine when to spawn items.
function HVHItemSpawnController:Think()
	if HVHItemSpawnController:_DidDayNightStateChange() then
		HVHItemSpawnController:_RemoveUnclaimedItems()
		HVHItemSpawnController:_UpdateCurrentChestModel()
		HVHItemSpawnController:SpawnChestsForCycle()
		HVHItemSpawnController._currentChestDataModel:ResetItemsRemainingThisCycle()
	end

	HVHItemSpawnController:_UpdateDayNightState()
	-- Returning this sets the next think time.
	return HVHItemSpawnController._thinkInterval
end

-- Spawns all items necessary for the current day/night cycle.
function HVHItemSpawnController:SpawnChestsForCycle()
	local availableChest = self._currentChestDataModel:GetChestName()
	local spawnLocations = self._spawnLocations:GetRandomLocations(self._currentChestDataModel:GetItemsPerCycle())

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

function HVHItemSpawnController:DisplayChestProbabilties()
	self._goodGuyChestDataModel:DisplayChestProbabilties()
	self._badGuyChestDataModel:DisplayChestProbabilties()
end

function HVHItemSpawnController:RunTestCycle()
	local itemsToGet = self._currentChestDataModel:GetItemsPerCycle()
	print(string.format("Running test for %d items.", itemsToGet))
	for itemCount=1, itemsToGet do
		local itemName = self._currentChestDataModel:GetRandomItemName()
	end

	self._currentChestDataModel:ResetItemsRemainingThisCycle()
end

-- Adds an item to the spawned item cache so that they can be reclaimed later.
function HVHItemSpawnController:_AddSpawnedItem(spawnedItem)
	if spawnedItem then
	    table.insert(self._spawnedChests, spawnedItem)
	else
		HVHDebugPrint("No item to add.")
	end
end

-- Sets the current item chest to either the good guy or bad guy chest
function HVHItemSpawnController:_UpdateCurrentChestModel()
	if GameRules:IsDaytime() then
		self._currentChestDataModel = self._badGuyChestDataModel
	else
		self._currentChestDataModel = self._goodGuyChestDataModel
	end
end

-- Indicates if the day/night cycle changes since the last think.
function HVHItemSpawnController:_DidDayNightStateChange()
	local isDaytime = GameRules:IsDaytime()
	return (isDaytime and not self._wasDayTimeLastThink) or (not isDaytime and self._wasDayTimeLastThink)
end

-- Removes all unclaimed items created by the spawner.
function HVHItemSpawnController:_RemoveUnclaimedItems()
	HVHDebugPrint(string.format("Attempting to remove %d items.", table.getn(self._spawnedChests)))
	for _,worldChest in pairs(self._spawnedChests) do
		worldChest:Remove()
	end

	self._spawnedChests = {}
end

-- Updates the day/night cycle for this think.
function HVHItemSpawnController:_UpdateDayNightState()
	self._wasDayTimeLastThink = GameRules:IsDaytime()
end

-- Handles a hero picking up a chest and either granting an item or rejecting the pickup
function HVHItemSpawnController:_OnItemPickedUp(keys)
	local itemName = keys.itemname
	-- Note that for a chest this is the chest item that is INSIDE the world chest entity
	local pickedUpItem = EntIndexToHScript(keys.ItemEntityIndex)
	local hero = EntIndexToHScript(keys.HeroEntityIndex)

	if self:_CanGrantGoodGuyItem(itemName, hero) then
		self:_GrantItem(self._goodGuyChestDataModel:GetRandomItemName(), hero, pickedUpItem)
	elseif self:_CanGrantBadGuyItem(itemName, hero) then
		self:_GrantItem(self._badGuyChestDataModel:GetRandomItemName(), hero, pickedUpItem)
	elseif self:_IsChestItem(itemName) then
		self:_RejectPickup(hero:GetAbsOrigin(), itemName, pickedUpItem)
	end
end

function HVHItemSpawnController:_IsChestItem(itemName)
	return self._goodGuyChestDataModel:IsChestItemName(itemName) or self._badGuyChestDataModel:IsChestItemName(itemName)
end

function HVHItemSpawnController:_CanGrantGoodGuyItem(itemName, hero)
	return self._goodGuyChestDataModel:IsChestItemName(itemName) and (hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS)
end

function HVHItemSpawnController:_CanGrantBadGuyItem(itemName, hero)
	return self._badGuyChestDataModel:IsChestItemName(itemName) and (hero:GetTeamNumber() == DOTA_TEAM_BADGUYS)
end

-- Looks up a world chest from the spawned chests using the entity index
function HVHItemSpawnController:_GetWorldChest(containedItem)
	local worldChest = nil

	for _,chest in pairs(self._spawnedChests) do
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

-- Removes the world chest that contains the passed in item.
function HVHItemSpawnController:_CleanupWorldChestForContainedItem(containedItem)
	local worldChest = self:_GetWorldChest(containedItem)
	HVHAssert(worldChest ~= nil, "No chest found for cleanup.")

    if worldChest then
    	worldChest:Remove()
    end
end

-- Prevents expending the chest by replacing it with another.
function HVHItemSpawnController:_RejectPickup(location, chestType, itemInChest)
	self:_CleanupWorldChestForContainedItem(itemInChest)
	local nearestSpawnLocation = self:_FindNearestSpawnLocation(location)
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
	local nearest = self._spawnLocations:GetNearestLocation(position)
	return nearest
end
