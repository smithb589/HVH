
require("utils/item_utils")

-- Hooks up the constructor call.
if HVHWorldChest == nil then
	HVHWorldChest = {}
	HVHWorldChest.__index = HVHWorldChest
	setmetatable(HVHWorldChest, {
		__call = function (chest, ...)
			return chest.new(...)
		end,
	})
end

function HVHWorldChest.new()
	local self = setmetatable({}, HVHWorldChest)

	self._spawnedChest = nil
	self._visionEntities = {}
	-- NS chests during day, sniper chests at night
	self._visionUnitDay   = "npc_chest_vision_dummy_ns"
	self._visionUnitNight = "npc_chest_vision_dummy_snipers"
	self._visionRange = 200

	return self
end

function HVHWorldChest:Spawn(location, chestType)
	self._spawnedChest = self:_CreateChest(location, chestType)
	self:_CreateVisionEntity(location, DOTA_TEAM_GOODGUYS)
	self:_CreateVisionEntity(location, DOTA_TEAM_BADGUYS)
end

function HVHWorldChest:Remove()
	self:_RemoveChest()
	self:_RemoveVisionEntities()
end

function HVHWorldChest:GetLocation()
	local location = nil
	if not self._spawnedChest:IsNull() then
		location = self._spawnedChest:GetAbsOrigin()
	end
	return location
end

function HVHWorldChest:IsContainedItem(item)
	local isSameChest = false

	if item and self._spawnedChest and not self._spawnedChest:IsNull() then
		local itemIndex = item:GetEntityIndex()
		local spawnedItemIndex = self._spawnedChest:GetContainedItem():GetEntityIndex()
		isSameChest = itemIndex == spawnedItemIndex
		HVHDebugPrint(string.format("Checking for contained item with indices: item=%d, spawendItem=%d", itemIndex, spawnedItemIndex))
	end

	return isSameChest
end

function HVHWorldChest:DoesSpawnedChestExist()
	return (not self._spawnedChest:IsNull())
end

function HVHWorldChest:_CreateChest(location, chestType)
	local spawnedChest = HVHItemUtils:SpawnItem(chestType, location)
	if spawnedChest then
		HVHDebugPrint(string.format("Created chest %s with index %d at (x=%f,y=%f).", chestType, spawnedChest:GetEntityIndex(), location.x, location.y))
	end
	return spawnedChest
end

function HVHWorldChest:_RemoveChest()
	if self._spawnedChest and not self._spawnedChest:IsNull() then
		UTIL_Remove(self._spawnedChest)
	end
end

function HVHWorldChest:_RemoveVisionEntities()
	for _,visionEntity in pairs(self._visionEntities) do
		if not visionEntity:IsNull() then
			UTIL_Remove(visionEntity)
		end
	end

	self._visionEntities = {}
end

function HVHWorldChest:_CreateVisionEntity(location, team)
	local visionUnit = self:_SelectVisionUnitForThisCycle()
	local visionEntity = CreateUnitByName(visionUnit, location, false, nil, nil, team)
	visionEntity:SetAbsOrigin(location)
	visionEntity.visionrange = self._visionRange

	table.insert(self._visionEntities, visionEntity)
end

function HVHWorldChest:_SelectVisionUnitForThisCycle()
	if GameRules:IsDaytime() then
		return self._visionUnitDay
	else
		return self._visionUnitNight
	end
end