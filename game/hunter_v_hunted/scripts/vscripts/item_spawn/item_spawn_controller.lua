require("item_spawn/hvh_chest_model")
require("item_spawn/hvh_location_collection")
require("item_spawn/hvh_world_chest")

require("custom_events/hvh_rejected_chest_pickup_event")

if HVHItemSpawnController == nil then
  HVHItemSpawnController = class({})

  HVHItemSpawnController._thinkInterval = 1.0 -- //0.1
  HVHItemSpawnController._wasDayTimeLastThink = false

  HVHItemSpawnController._spawnLocations = nil
  HVHItemSpawnController._spawnedChests = {}

  HVHItemSpawnController._goodGuyChestDataModel = HVHChestModel("scripts/npc/kv/good_guy_chests.kv")
  HVHItemSpawnController._badGuyChestDataModel = HVHChestModel("scripts/npc/kv/bad_guy_chests.kv")
  HVHItemSpawnController._currentChestDataModel = nil

  -- stat collection
  HVHItemSpawnController._ggTotalItemsSpawned = 0
  HVHItemSpawnController._bgTotalItemsSpawned = 0
  HVHItemSpawnController._ggUnclaimedItems = 0
  HVHItemSpawnController._bgUnclaimedItems = 0
  HVHItemSpawnController._ggClaimedItems = 0
  HVHItemSpawnController._bgClaimedItems = 0
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
  local chestTeam = self._currentChestDataModel:GetChestTeam()
  local spawnLocations = self._spawnLocations:GetRandomLocations(self._currentChestDataModel:GetItemsPerCycle())

  if spawnLocations then
    self:IncrementTotalItems(chestTeam, #spawnLocations) -- stat collection
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
    -- stat collection
    if worldChest:DoesSpawnedChestExist() then
      local chestTeam = self._currentChestDataModel:GetChestTeam()
      self:IncrementUnclaimedItems(chestTeam)    
    end

    worldChest:Remove()
  end

  --print("GG Unclaimed: " .. HVHItemSpawnController._ggUnclaimedItems)
  --print("BG Unclaimed: " .. HVHItemSpawnController._bgUnclaimedItems)
  self._spawnedChests = {}
end

-- Updates the day/night cycle for this think.
function HVHItemSpawnController:_UpdateDayNightState()
  self._wasDayTimeLastThink = GameRules:IsDaytime()
end

-- Handles a unit picking up a chest and either granting an item or rejecting the pickup
function HVHItemSpawnController:_OnItemPickedUp(keys)
  local itemName = keys.itemname
  -- Note that for a chest this is the chest item that is INSIDE the world chest entity
  local pickedUpItem = EntIndexToHScript(keys.ItemEntityIndex)
  local unit = EntIndexToHScriptNillable(keys.HeroEntityIndex)

  if unit then
	  if self:_CanGrantGoodGuyItem(itemName, unit) then
	    self:_GrantItem(self._goodGuyChestDataModel:GetRandomItemName(), unit, pickedUpItem)
	  elseif self:_CanGrantBadGuyItem(itemName, unit) then
	    self:_GrantItem(self._badGuyChestDataModel:GetRandomItemName(), unit, pickedUpItem)
	  elseif self:_IsChestItem(itemName) then
	    self:_RejectPickup(unit, itemName, pickedUpItem)
	  end
	else
		self:_RejectPickup(pickedUpItem:GetAbsOrigin(), itemName, pickedUpItem)
	end
end

function HVHItemSpawnController:_IsChestItem(itemName)
  return self._goodGuyChestDataModel:IsChestItemName(itemName) or self._badGuyChestDataModel:IsChestItemName(itemName)
end

function HVHItemSpawnController:_CanGrantGoodGuyItem(itemName, unit)
	local isGoodGuyChest = self._goodGuyChestDataModel:IsChestItemName(itemName)
	local isOnGoodGuyTeam = unit:GetTeamNumber() == DOTA_TEAM_GOODGUYS
	local hasInventory = unit:HasInventory()
  return hasInventory and isGoodGuyChest and isOnGoodGuyTeam
end

function HVHItemSpawnController:_CanGrantBadGuyItem(itemName, unit)
	local isBadGuyChest = self._badGuyChestDataModel:IsChestItemName(itemName)
	local isOnBadGuyTeam = unit:GetTeamNumber() == DOTA_TEAM_BADGUYS
	local hasInventory = unit:HasInventory()
  return hasInventory and isBadGuyChest and isOnBadGuyTeam
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
function HVHItemSpawnController:_GrantItem(itemName, unit, chestItem)
  if itemName and unit then
    unit:AddItemByName(itemName)
    Timers:CreateTimer(SINGLE_FRAME_TIME, function()
      HVHItemUtils:DropStashItems(unit)
    end)

    if unit:GetTeam() == DOTA_TEAM_GOODGUYS then
      HVHCycles:SunShardPickup(unit)
    else
      HVHCycles:MoonRockPickup(unit)
    end
    -- stat collection
    unit.ClaimedItems = unit.ClaimedItems + 1
  else
    HVHDebugPrint(string.format("Could not grant item %s to unit %d.", itemName, unit:GetEntityIndex()))
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
function HVHItemSpawnController:_RejectPickup(unitOrOriginalLocation, chestType, itemInChest)
  self:_CleanupWorldChestForContainedItem(itemInChest)
  local nearestSpawnLocation = unitOrOriginalLocation
  if unitOrOriginalLocation.GetAbsOrigin then
		nearestSpawnLocation = self:_FindNearestSpawnLocation(unitOrOriginalLocation:GetAbsOrigin())
	else
		nearestSpawnLocation = self:_FindNearestSpawnLocation(unitOrOriginalLocation)
	end
  local replacedChest = HVHWorldChest()
  replacedChest:Spawn(nearestSpawnLocation, chestType)
  self:_AddSpawnedItem(replacedChest)
  if unitOrOriginalLocation.GetPlayerID then
  	self:_SendRejectedPickupEvent(PlayerResource:GetPlayer(unitOrOriginalLocation:GetPlayerID()))
  end
end

function HVHItemSpawnController:_SendRejectedPickupEvent(player)
  local event = HVHRejectedChestPickupEvent(HVHRejectedChestPickupEvent.RejectReason_WrongTeam)
  Notifications:ClearTop(player)
  Notifications:Top(player, event:ConvertToPayload())
  EmitSoundOnClient("General.InvalidTarget_Shop", player)
end

-- Finds the nearest spawner in a small radius.
function HVHItemSpawnController:_FindNearestSpawnLocation(position)
  local nearest = self._spawnLocations:GetNearestLocation(position)
  return nearest
end

-----------------------------
-- STAT COLLECTION FUNCTIONS
-----------------------------
function HVHItemSpawnController:IncrementTotalItems(team, amount)
  local amount = amount or 1

  if team == DOTA_TEAM_GOODGUYS then
    self._ggTotalItemsSpawned = self._ggTotalItemsSpawned + amount
  elseif team == DOTA_TEAM_BADGUYS then
    self._bgTotalItemsSpawned = self._bgTotalItemsSpawned + amount
  end
end

function HVHItemSpawnController:IncrementUnclaimedItems(team)
  if team == DOTA_TEAM_GOODGUYS then
    self._ggUnclaimedItems = self._ggUnclaimedItems + 1
  elseif team == DOTA_TEAM_BADGUYS then
    self._bgUnclaimedItems = self._bgUnclaimedItems + 1
  end
end
