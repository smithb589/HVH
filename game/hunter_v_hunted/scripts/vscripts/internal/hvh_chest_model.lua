--[[
This script represents a chest conceptually as an item that returns
another random item.
]]

require("internal/item_randomizer")

-- Hooks up the constructor call.
if HVHChestModel == nil then
	HVHChestModel = {}
	HVHChestModel.__index = HVHChestModel
	setmetatable(HVHChestModel, {
		__call = function (itemChest, ...)
			return itemChest.new(...)
		end,
	})
end

-- constructor
function HVHChestModel.new(itemConfigFilename)
	local self = setmetatable({}, HVHChestModel)

	self:_LoadItemFile(itemConfigFilename)

	return self
end

function HVHChestModel:GetRandomItemName()
	local item = self._itemRandomizer:GetRandomValue()
	return item
end

function HVHChestModel:GetChestName()
	return self._chestName
end

function HVHChestModel:GetItemsPerCycle()
	return self._itemsPerCycle
end

function HVHChestModel:IsChestItemName(itemName)
	return itemName == self._chestName
end

function HVHChestModel:DisplayChestProbabilties()
	if self._itemRandomizer then
		self._itemRandomizer:DisplayProbabilties()
	end
end

-- Parses out relevant information from the items kv file.
function HVHChestModel:_LoadItemFile(itemConfigFilename)
	local itemConfig = LoadKeyValues(itemConfigFilename)

	self._itemsPerCycle = itemConfig["items_per_cycle"]
	self._chestName = itemConfig["chest_name"]
	self._itemRandomizer = HVHRandomizer(itemConfig["items"])
end

