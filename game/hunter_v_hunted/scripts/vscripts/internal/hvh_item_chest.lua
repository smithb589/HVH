
require("internal/item_randomizer")

-- Hooks up the constructor call.
if HVHItemChest == nil then
	HVHItemChest = {}
	HVHItemChest.__index = HVHItemChest
	setmetatable(HVHItemChest, {
		__call = function (itemChest, ...)
			return itemChest.new(...)
		end,
	})
end

-- constructor
function HVHItemChest.new(itemConfigFilename)
	local self = setmetatable({}, HVHItemChest)

	self:_LoadItemFile(itemConfigFilename)

	return self
end

function HVHItemChest:GetRandomItemName()
	local item = self._itemRandomizer:GetRandomValue()
	return item
end

function HVHItemChest:GetChestName()
	return self._chestName
end

function HVHItemChest:GetItemsPerCycle()
	return self._itemsPerCycle
end

function HVHItemChest:IsChestItemName(itemName)
	return itemName == self._chestName
end

-- Parses out relevant information from the items kv file.
function HVHItemChest:_LoadItemFile(itemConfigFilename)
	local itemConfig = LoadKeyValues(itemConfigFilename)

	self._itemsPerCycle = itemConfig["items_per_cycle"]
	self._chestName = itemConfig["chest_name"]
	self._itemRandomizer = HVHRandomizer(itemConfig["items"])
end

