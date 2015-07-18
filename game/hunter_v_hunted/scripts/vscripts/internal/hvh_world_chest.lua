
require("item_utils")

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
	self._visionUnit = "npc_chest_vision_dummy"
	self._visionRange = 200

	return self
end

function HVHWorldChest:Spawn(location, chestType)
	self._spawnedChest = self:_CreateChest(location, chestType)
	self:_CreateVisionEntity(location)
	if self._spawnedChest then
		HVHDebugPrint(string.format("Created chest %s with index %d.", chestType, self._spawnedChest:GetEntityIndex()))
	else
		HVHDebugPrint(string.format("Failed to created %s.", chestType))
	end
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

function HVHWorldChest:IsSameChest(chest)
	local isSameChest = false

	if chest and chest.hvhUniqueChestName and self._spawnedChest then
		isSameChest = chest.hvhUniqueChestName == self._spawnedChest.hvhUniqueChestName
	end

	return isSameChest
end

function HVHWorldChest:_CreateChest(location, chestType)
	local spawnedChest = HVHItemUtils:SpawnItem(chestType, location)
	spawnedChest.hvhUniqueChestName = DoUniqueString("")
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

function HVHWorldChest:_CreateVisionEntity(location)
	local visionEntity = CreateUnitByName(self._visionUnit, location, false, nil, nil, DOTA_TEAM_GOODGUYS)
	visionEntity:SetAbsOrigin(location)
	visionEntity.visionrange = self._visionRange

	table.insert(self._visionEntities, visionEntity)
end

