

if HVHItemSpawnController == nil then
	HVHItemSpawnController = class({})
	HVHItemSpawnController._HunterItems = {}
	HVHItemSpawnController._HunterItems[0] = "item_force_staff"
	HVHItemSpawnController._HunterItems[1] = "item_sphere"
	HVHItemSpawnController._HunterItems[2] = "item_lotus_orb"
	HVHItemSpawnController._HunterItems[3] = "item_black_king_bar"
	HVHItemSpawnController._HunterItems[4] = "item_ward_observer"
  	HVHItemSpawnController._HunterItems[5] = "item_ward_sentry"

	HVHItemSpawnController._HuntedItems = {}
	HVHItemSpawnController._HuntedItems[0] = "item_force_staff"
	HVHItemSpawnController._HuntedItems[1] = "item_blink"
	HVHItemSpawnController._HuntedItems[2] = "item_invis_sword"
	HVHItemSpawnController._HuntedItems[3] = "item_sheepstick"

	HVHItemSpawnController._Spawners = {}
	HVHItemSpawnController._Spawners[0] = "hvh_item_spawn_north"
	HVHItemSpawnController._Spawners[1] = "hvh_item_spawn_south"
	HVHItemSpawnController._Spawners[2] = "hvh_item_spawn_east"
	HVHItemSpawnController._Spawners[3] = "hvh_item_spawn_west"

	HVHItemSpawnController._ThinkInterval = 0.1

	HVHItemSpawnController._WasDayTimeLastThink = false
  --[[TODO:
   hunters: timber chain
   NS: pudge hook, shackle, dagon]]--
end

require("item_utils")
require("lib/util")

function HVHItemSpawnController:Setup()
	local spawnCoordinator = Entities:FindByName(nil, "hvh_item_spawn_coordinator")
	spawnCoordinator:SetContextThink("HVHItemSpawnController", Dynamic_Wrap(HVHItemSpawnController, "Think"), self._ThinkInterval)

	self:_UpdateDayNightState()
end

function HVHItemSpawnController:Think()
	if HVHItemSpawnController:DidDayNightStateChange() then
		HVHItemSpawnController:RemoveUnclaimedItems()
		local availableItems = HVHItemSpawnController:GetAvailableItemClasses()
		HVHItemSpawnController:SpawnRandomItem(availableItems)
	end

	HVHItemSpawnController:_UpdateDayNightState()
	-- Returning this sets the next think time.
	return HVHItemSpawnController._ThinkInterval
end

function HVHItemSpawnController:GetAvailableItemClasses()
	local availableItemClasses = {}
	if GameRules:IsDaytime() then
		availableItemClasses = self._HunterItems
	else 
		availableItemClasses = self._HuntedItems
	end
	return availableItemClasses
end

function HVHItemSpawnController:SpawnRandomItem(availableItems)
	print("Attempting to spawn item from table.")
	if availableItems then
		local maxItemIndex = table.getn(availableItems)
		local itemIndex = RandomInt(0, maxItemIndex)
		local spawnLocation = self:_GetRandomSpawnLocation()
		if spawnLocation then
			HVHItemUtils:SpawnItem(availableItems[itemIndex], spawnLocation)
		end
	end
end

function HVHItemSpawnController:DidDayNightStateChange()
	local isDaytime = GameRules:IsDaytime()
	return (isDaytime and not self._WasDayTimeLastThink) or (not isDaytime and self._WasDayTimeLastThink)
end

function HVHItemSpawnController:RemoveUnclaimedItems()

end

function HVHItemSpawnController:_UpdateDayNightState()
	self._WasDayTimeLastThink = GameRules:IsDaytime()
end

function HVHItemSpawnController:_GetRandomSpawnLocation()
	local randomSpawnerIndex = RandomInt(0, table.getn(self._Spawners))
	local spawner = Entities:FindByName(nil, self._Spawners[randomSpawnerIndex])
	local spawnLocation = nil
	if spawner then
		spawnLocation = spawner:GetAbsOrigin()
	else
		print("No spawner to create item at.")
	end

	return spawnLocation
end